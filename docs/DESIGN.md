# 配置管理功能设计

配置管理工具核心功能的方案设计。

## 功能一：配置漂移检测 (Config Drift Detection)

### 需求场景

用户可能在日常使用中手动修改了软链接指向的配置文件（如直接编辑 ~/.vimrc），导致仓库版本与本地实际配置不一致。需要检测这种"漂移"并提醒用户。

### 技术方案

**核心逻辑：**

1. 扫描家目录下的所有软链接
2. 筛选出指向本仓库的链接
3. 对比链接目标与仓库源文件的差异
4. 生成漂移报告

**实现细节：**

```bash
# lib/bin/drift.sh

# 检测单个文件的漂移
function check_file_drift() {
    local source_file="$1"  # 仓库中的源文件
    local link_file="$2"    # 用户目录中的软链接

    if [ ! -L "$link_file" ]; then
        echo "MISSING_LINK"
        return
    fi

    # 读取软链接指向的实际路径
    local actual_target=$(readlink "$link_file")

    # 如果指向的不是我们的仓库，标记为外部管理
    if [[ "$actual_target" != *"$KS_PROJECT_DIR"* ]]; then
        echo "EXTERNAL"
        return
    fi

    # 对比文件内容差异
    if ! diff -q "$source_file" "$link_file" > /dev/null 2>&1; then
        echo "MODIFIED"
        return
    fi

    echo "SYNCED"
}

# 主检测流程
function detect_all_drift() {
    local drift_count=0

    # 定义需要检查的配置映射
    declare -A config_map=(
        ["$KS_PROJECT_DIR/modules/vim/.vimrc"]="$HOME/.vimrc"
        ["$KS_PROJECT_DIR/modules/vim/.vim"]="$HOME/.vim"
        ["$KS_PROJECT_DIR/modules/git/.gitmessage.txt"]="$HOME/.gitmessage.txt"
        ["$KS_PROJECT_DIR/modules/tmux/.tmux.conf"]="$HOME/.tmux.conf"
        ["$KS_PROJECT_DIR/modules/npm/.npmrc"]="$HOME/.npmrc"
    )

    for source in "${!config_map[@]}"; do
        local target="${config_map[$source]}"
        local status=$(check_file_drift "$source" "$target")

        case "$status" in
            "MODIFIED")
                print_warn "$(basename $target) has local modifications"
                show_diff_preview "$source" "$target"
                ((drift_count++))
                ;;
            "MISSING_LINK")
                print_warn "$(basename $target) link is missing or broken"
                ;;
            "EXTERNAL")
                print_info "$(basename $target) is managed externally"
                ;;
        esac
    done

    return $drift_count
}

# 显示差异预览
function show_diff_preview() {
    local source="$1"
    local target="$2"

    echo "  Diff preview (first 5 lines):"
    diff -u "$source" "$target" 2>/dev/null | head -n 5 | sed 's/^/    /'
}
```

### 命令行接口

```bash
# 基础检测
$HOME/.ks-config/lib/bin/drift.sh

# 详细报告
$HOME/.ks-config/lib/bin/drift.sh --verbose

# 自动修复（用仓库版本覆盖）
$HOME/.ks-config/lib/bin/drift.sh --fix
```

### 受影响文件

- **新增**: `lib/bin/drift.sh`
- **修改**: `lib/bin/main.sh` - 添加 drift 选项到帮助菜单

## 功能二：更新命令 (Config Update)

### 需求场景

用户需要一键从 GitHub 拉取最新配置，并在保留本地修改或备份的前提下重新建立软链接。

### 技术方案

**核心逻辑：**

1. 进入仓库目录执行 git pull
2. 检测配置漂移（调用 drift.sh）
3. 根据用户选择处理漂移
4. 重新建立软链接

**实现细节：**

```bash
# lib/bin/update.sh

readonly UPDATE_BACKUP_DIR="$KS_PROJECT_DIR/.backup/update-$(date +%Y%m%d-%H%M%S)"

function update_configs() {
    print_info "Starting configuration update..."

    # 1. 检查是否在 git 仓库中
    if [ ! -d "$KS_PROJECT_DIR/.git" ]; then
        print_err "Not a git repository. Cannot update."
        exit 1
    fi

    cd "$KS_PROJECT_DIR"

    # 2. 获取远程更新
    print_info "Fetching updates from remote..."
    if ! git pull origin master; then
        print_err "Failed to pull updates. Please resolve conflicts manually."
        exit 1
    fi

    # 3. 检测漂移
    print_info "Checking for configuration drift..."
    source "$KS_PROJECT_DIR/lib/bin/drift.sh"

    local drifted_configs=()
    detect_drift_array drifted_configs

    # 4. 处理漂移配置
    if [ ${#drifted_configs[@]} -gt 0 ]; then
        print_warn "Found ${#drifted_configs[@]} modified configurations"

        echo "Options:"
        echo "  [b] Backup local changes and update"
        echo "  [k] Keep local changes (skip these files)"
        echo "  [o] Overwrite with remote version"
        read -p "Choose action [b/k/o]: " action

        case "$action" in
            b|B) backup_and_update "$drifted_configs" ;;
            k|K) skip_configs "$drifted_configs" ;;
            o|O) force_update "$drifted_configs" ;;
            *) print_err "Invalid option"; exit 1 ;;
        esac
    fi

    # 5. 重新链接所有配置
    print_info "Relinking configurations..."
    relink_all_configs

    print_success "Update completed!"
}

function backup_and_update() {
    local configs=("$@")
    mkdir -p "$UPDATE_BACKUP_DIR"

    for config in "${configs[@]}"; do
        if [ -f "$config" ]; then
            cp "$config" "$UPDATE_BACKUP_DIR/"
            print_info "Backed up $(basename $config)"
        fi
    done
}

function relink_all_configs() {
    # 重新建立所有已安装的模块链接
    # 读取安装记录（见功能五）
    if [ -f "$KS_PROJECT_DIR/.installed_modules" ]; then
        while IFS= read -r module; do
            print_info "Relinking $module..."
            source "$KS_PROJECT_DIR/lib/bin/modules/$module.sh" --relink
        done < "$KS_PROJECT_DIR/.installed_modules"
    fi
}
```

### 命令行接口

```bash
# 更新所有配置
$HOME/.ks-config/lib/bin/update.sh

# 更新特定模块
$HOME/.ks-config/lib/bin/update.sh vim

# 强制覆盖（不提示）
$HOME/.ks-config/lib/bin/update.sh --force
```

### 受影响文件

- **新增**: `lib/bin/update.sh`
- **修改**: `lib/bin/main.sh` - 添加 update 命令支持

## 功能三：健康检查 (Config Doctor)

### 需求场景

用户需要快速诊断配置环境的问题：软链接是否失效、依赖工具是否安装、Git 状态是否正常等。

### 技术方案

**检查项清单：**

| 检查项 | 说明 | 状态 |
|--------|------|------|
| 仓库完整性 | .git 目录是否存在 | Required |
| 软链接有效性 | 所有软链接是否指向有效文件 | Required |
| 工具可用性 | git, vim, tmux 等是否安装 | Warning |
| 权限检查 | 配置目录是否有写权限 | Required |
| Git 状态 | 是否有未提交的本地修改 | Info |
| 配置漂移 | 是否有本地修改 | Warning |

**实现细节：**

```bash
# lib/bin/doctor.sh

declare -i CHECKS_PASSED=0
declare -i CHECKS_FAILED=0
declare -i CHECKS_WARNING=0

function run_health_checks() {
    print_info "Running configuration health checks..."
    echo ""

    # 1. 检查仓库完整性
    check_repository_integrity

    # 2. 检查软链接
    check_symlink_health

    # 3. 检查工具依赖
    check_tool_dependencies

    # 4. 检查权限
    check_permissions

    # 5. 检查 Git 状态
    check_git_status

    # 6. 检查配置漂移
    check_drift_status

    # 输出总结
    echo ""
    print_info "Health Check Summary:"
    echo "  ✓ Passed: $CHECKS_PASSED"
    echo "  ⚠ Warning: $CHECKS_WARNING"
    echo "  ✗ Failed: $CHECKS_FAILED"

    return $CHECKS_FAILED
}

function check_repository_integrity() {
    echo -n "Checking repository integrity... "

    if [ -d "$KS_PROJECT_DIR/.git" ]; then
        echo "✓"
        ((CHECKS_PASSED++))
    else
        echo "✗"
        print_err "  Git repository not found"
        ((CHECKS_FAILED++))
    fi
}

function check_symlink_health() {
    echo -n "Checking symlink health... "

    local broken_links=0

    # 扫描家目录软链接
    while IFS= read -r link; do
        if [ -L "$link" ] && [ ! -e "$link" ]; then
            ((broken_links++))
            print_warn "  Broken link: $link"
        fi
    done < <(find ~ -maxdepth 1 -type l 2>/dev/null)

    if [ $broken_links -eq 0 ]; then
        echo "✓"
        ((CHECKS_PASSED++))
    else
        echo "⚠ ($broken_links broken)"
        ((CHECKS_WARNING++))
    fi
}

function check_tool_dependencies() {
    echo "Checking tool dependencies..."

    local tools=("git" "vim" "curl" "wget")

    for tool in "${tools[@]}"; do
        echo -n "  $tool... "
        if command -v "$tool" &> /dev/null; then
            local version=$($tool --version 2>/dev/null | head -n1 | awk '{print $NF}')
            echo "✓ ($version)"
            ((CHECKS_PASSED++))
        else
            echo "✗ (not installed)"
            ((CHECKS_WARNING++))
        fi
    done
}

function check_git_status() {
    echo -n "Checking git status... "

    cd "$KS_PROJECT_DIR"

    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
        echo "⚠ (uncommitted changes)"
        ((CHECKS_WARNING++))
    else
        echo "✓"
        ((CHECKS_PASSED++))
    fi
}

function check_drift_status() {
    echo -n "Checking configuration drift... "

    source "$KS_PROJECT_DIR/lib/bin/drift.sh"

    local drift_count=$(count_drift 2>/dev/null || echo 0)

    if [ "$drift_count" -eq 0 ]; then
        echo "✓"
        ((CHECKS_PASSED++))
    else
        echo "⚠ ($drift_count files modified)"
        ((CHECKS_WARNING++))
    fi
}
```

### 命令行接口

```bash
# 完整检查
$HOME/.ks-config/lib/bin/doctor.sh

# 仅检查特定项
$HOME/.ks-config/lib/bin/doctor.sh --check=symlinks
$HOME/.ks-config/lib/bin/doctor.sh --check=tools

# 自动修复可修复的问题
$HOME/.ks-config/lib/bin/doctor.sh --fix
```

### 受影响文件

- **新增**: `lib/bin/doctor.sh`
- **修改**: `lib/bin/main.sh` - 添加 doctor 命令

---

## 功能四：预览模式 (Dry Run Mode)

### 需求场景

用户希望在执行实际安装/更新前预览会执行哪些操作，避免误操作。

### 技术方案

**核心逻辑：**

添加全局变量 `DRY_RUN`，所有修改操作在执行前检查该变量。

**实现细节：**

```bash
# lib/bin/util.sh - 添加

# 全局预览模式标志
DRY_RUN=false

# 解析参数
function parse_args() {
    for arg in "$@"; do
        case "$arg" in
            --dry-run)
                DRY_RUN=true
                print_info "[DRY RUN MODE] No changes will be made"
                ;;
        esac
    done
}

# 安全的执行函数
function safe_exec() {
    local description="$1"
    shift

    if [ "$DRY_RUN" = true ]; then
        echo "  [WOULD EXECUTE] $description"
        echo "    Command: $*"
    else
        eval "$@"
    fi
}

# 安全的文件操作
function safe_ln() {
    local source="$1"
    local target="$2"

    if [ "$DRY_RUN" = true ]; then
        echo "  [WOULD LINK] $source -> $target"
    else
        ln -s "$source" "$target"
    fi
}

function safe_mv() {
    local source="$1"
    local target="$2"

    if [ "$DRY_RUN" = true ]; then
        echo "  [WOULD MOVE] $source -> $target"
    else
        mv "$source" "$target"
    fi
}

function safe_rm() {
    local target="$1"

    if [ "$DRY_RUN" = true ]; then
        echo "  [WOULD REMOVE] $target"
    else
        rm -rf "$target"
    fi
}
```

**修改模块脚本：**

```bash
# lib/bin/modules/vim.sh 示例修改

#!/bin/bash

# 解析参数
parse_args "$@"

vim_folder=~/.vim
vim_rc=~/.vimrc

print_info "Vim configuration plan:"
echo "  - Check: $vim_folder"
echo "  - Check: $vim_rc"
echo ""

# 使用 safe_ 前缀函数替代原始操作
ensure_no_folder "$vim_folder"
ensure_no_file "$vim_rc"

print_info "Linking Vim related files to $HOME"

if only_simple; then
    safe_ln "$KS_PROJECT_DIR/modules/vim/.simple.vimrc" "$vim_rc"
else
    safe_ln "$KS_PROJECT_DIR/modules/vim/.vim" "$vim_folder"
    safe_ln "$KS_PROJECT_DIR/modules/vim/.vimrc" "$vim_rc"

    if [ "$DRY_RUN" = false ]; then
        vim +'PlugInstall --sync' +qa
    else
        echo "  [WOULD EXECUTE] vim +'PlugInstall --sync' +qa"
    fi
fi
```

**修改 fs.sh：**

```bash
# lib/bin/fs.sh 修改

function ensure_no_folder() {
    local filename="$1"
    local name=${filename##*/}

    if [ -d "$filename" ]; then
        if [ "$DRY_RUN" = true ]; then
            echo "  [WOULD PROMPT] Handle existing folder: $filename"
            return 0
        fi

        # 原有逻辑...
    fi
}
```

### 命令行接口

```bash
# 预览安装
sh -c "$(curl ...)" -- --dry-run

# 预览特定模块
$HOME/.ks-config/lib/bin/main.sh vim --dry-run

# 预览更新
$HOME/.ks-config/lib/bin/update.sh --dry-run
```

### 受影响文件

- **修改**: `lib/bin/util.sh` - 添加 safe_* 函数和参数解析
- **修改**: `lib/bin/fs.sh` - 支持预览模式
- **修改**: `lib/bin/modules/vim.sh` - 使用 safe_* 函数
- **修改**: `lib/bin/modules/git.sh` - 使用 safe_* 函数
- **修改**: `lib/bin/modules/npm.sh` - 使用 safe_* 函数
- **修改**: `lib/bin/modules/eslint.sh` - 使用 safe_* 函数

## 功能五：卸载功能 (Config Uninstall)

### 需求场景

用户需要移除某个工具的配置，恢复原始状态或完全清理。

### 技术方案

**核心逻辑：**

1. 读取安装记录（记录之前安装了哪些模块）
2. 移除软链接
3. 可选择恢复备份
4. 更新安装记录

**实现细节：**

```bash
# lib/bin/uninstall.sh

readonly INSTALLED_MODULES_FILE="$KS_PROJECT_DIR/.installed_modules"
readonly UNINSTALL_BACKUP_DIR="$KS_PROJECT_DIR/.backup/uninstall-$(date +%Y%m%d-%H%M%S)"

function uninstall_module() {
    local module="$1"
    local restore_backup=false

    print_info "Uninstalling $module configuration..."

    # 检查模块是否已安装
    if ! is_module_installed "$module"; then
        print_warn "$module is not installed"
        return 1
    fi

    # 询问是否恢复备份
    read -p "Restore previous backup if exists? [y/n]: " ans
    if [ "$ans" = "y" ]; then
        restore_backup=true
    fi

    # 执行模块特定的卸载逻辑
    case "$module" in
        vim)    uninstall_vim "$restore_backup" ;;
        git)    uninstall_git "$restore_backup" ;;
        npm)    uninstall_npm "$restore_backup" ;;
        tmux)   uninstall_tmux "$restore_backup" ;;
        *)      print_err "Unknown module: $module"; return 1 ;;
    esac

    # 从安装记录中移除
    remove_from_installed "$module"

    print_success "$module configuration uninstalled"
}

function uninstall_vim() {
    local restore_backup="$1"

    local targets=("$HOME/.vim" "$HOME/.vimrc")

    for target in "${targets[@]}"; do
        if [ -L "$target" ]; then
            safe_rm "$target"
        fi

        # 恢复备份
        if [ "$restore_backup" = true ]; then
            restore_latest_backup "$target"
        fi
    done
}

function uninstall_git() {
    local restore_backup="$1"

    # 移除全局配置
    git config --global --unset commit.template 2>/dev/null

    if [ -L "$HOME/.gitmessage.txt" ]; then
        safe_rm "$HOME/.gitmessage.txt"
    fi

    if [ "$restore_backup" = true ]; then
        restore_latest_backup "$HOME/.gitmessage.txt"
    fi
}

function is_module_installed() {
    local module="$1"

    if [ ! -f "$INSTALLED_MODULES_FILE" ]; then
        return 1
    fi

    grep -q "^${module}$" "$INSTALLED_MODULES_FILE"
}

function remove_from_installed() {
    local module="$1"

    if [ -f "$INSTALLED_MODULES_FILE" ]; then
        sed -i.bak "/^${module}$/d" "$INSTALLED_MODULES_FILE"
        rm -f "$INSTALLED_MODULES_FILE.bak"
    fi
}

function restore_latest_backup() {
    local target="$1"
    local name=$(basename "$target")
    local backup_pattern="${target}-[0-9]*-[0-9]*"

    # 查找最新的备份
    local latest_backup=$(ls -td $backup_pattern 2>/dev/null | head -n1)

    if [ -n "$latest_backup" ]; then
        print_info "Restoring from backup: $latest_backup"
        safe_mv "$latest_backup" "$target"
    fi
}
```

**安装记录机制：**

```bash
# 在 install.sh 和模块脚本中添加安装记录

function record_installation() {
    local module="$1"
    local record_file="$KS_PROJECT_DIR/.installed_modules"

    # 避免重复记录
    if ! grep -q "^${module}$" "$record_file" 2>/dev/null; then
        echo "$module" >> "$record_file"
    fi
}

# 在 vim.sh 末尾添加
record_installation "vim"
```

### 命令行接口

```bash
# 卸载特定模块
$HOME/.ks-config/lib/bin/uninstall.sh vim

# 卸载并恢复备份
$HOME/.ks-config/lib/bin/uninstall.sh vim --restore

# 卸载所有模块
$HOME/.ks-config/lib/bin/uninstall.sh --all

# 预览卸载（dry-run）
$HOME/.ks-config/lib/bin/uninstall.sh vim --dry-run
```

### 受影响文件

- **新增**: `lib/bin/uninstall.sh`
- **修改**: `lib/bin/modules/vim.sh` - 添加 record_installation
- **修改**: `lib/bin/modules/git.sh` - 添加 record_installation
- **修改**: `lib/bin/modules/npm.sh` - 添加 record_installation
- **修改**: `lib/bin/modules/eslint.sh` - 添加 record_installation

## 边界条件和异常处理

### 1. 仓库不存在

- 所有脚本首先检查 `$KS_PROJECT_DIR` 是否存在
- 如不存在，提示用户先运行 install.sh

### 2. Git 操作失败

- pull 失败时保留本地修改，提示手动解决
- 网络超时重试 3 次

### 3. 软链接损坏

- doctor.sh 检测并报告损坏链接
- 提供一键修复选项

### 4. 权限不足

- 检查目录写权限
- 提示使用 sudo 或修改权限

### 5. 并发操作

- 使用锁文件防止同时运行多个操作
- 锁文件位置：`$KS_PROJECT_DIR/.lock`
