# config

快速安装和配置常用开发工具。

## 快速开始

```bash
sh -c "$(wget -O- https://raw.githubusercontent.com/kisstar/config/master/lib/bin/install.sh)"

# 或者

sh <(curl -L https://raw.githubusercontent.com/kisstar/config/master/lib/bin/install.sh)
```

## 支持的工具

| 工具 | 描述 |
|------|-------------|
| `vim` | 高度可配置的文本编辑器 |
| `npm` | JavaScript 包管理器 |
| `git` | 分布式版本控制系统 |
| `eslint` | JavaScript 代码检查工具 |
| `tmux` | 终端复用器 |

## 命令说明

安装完成后，可以使用以下命令：

### 安装配置
```bash
# 交互模式（选择要安装的工具）
~/.ks-config/lib/bin/main.sh

# 安装指定工具
~/.ks-config/lib/bin/main.sh vim
~/.ks-config/lib/bin/main.sh git

# 预览安装（不实际执行，查看将要进行的操作）
~/.ks-config/lib/bin/main.sh vim --dry-run
```

### 更新配置
```bash
# 从远程仓库更新所有配置并重新链接
~/.ks-config/lib/bin/update.sh

# 更新指定模块
~/.ks-config/lib/bin/update.sh vim

# 强制更新（覆盖本地修改）
~/.ks-config/lib/bin/update.sh --force

# 预览更新
~/.ks-config/lib/bin/update.sh --dry-run
```

### 健康检查
```bash
# 运行完整的健康检查
~/.ks-config/lib/bin/doctor.sh

# 自动修复损坏的软链接
~/.ks-config/lib/bin/doctor.sh --fix
```

### 配置漂移检测
```bash
# 检查配置是否有本地修改（与仓库版本对比）
~/.ks-config/lib/bin/drift.sh

# 详细报告（显示差异内容）
~/.ks-config/lib/bin/drift.sh --verbose

# 自动修复漂移（恢复为仓库版本）
~/.ks-config/lib/bin/drift.sh --fix
```

### 卸载配置
```bash
# 移除指定配置
~/.ks-config/lib/bin/uninstall.sh vim

# 移除并恢复之前的备份
~/.ks-config/lib/bin/uninstall.sh vim --restore

# 移除所有配置
~/.ks-config/lib/bin/uninstall.sh --all

# 预览卸载操作
~/.ks-config/lib/bin/uninstall.sh vim --dry-run
```

## 功能特性

### 配置漂移检测
当本地配置文件被手动修改后与仓库版本不一致时，能够检测出来。帮助你在多台机器上保持配置同步。

### 预览模式（`--dry-run`）
在实际执行前查看将要进行的修改，避免误操作。适用于安装、更新、卸载等所有命令。

### 健康检查
验证你的配置环境是否完整：
- 仓库完整性
- 软链接状态
- 工具依赖
- 配置漂移
- Git 状态

### 自动备份
在替换原始配置前自动备份：
- 备份位置：`~/.ks-config/.backup/`
- 命名格式：`文件名-YYYYMMDD-随机数`
- 卸载时可使用 `--restore` 恢复备份

### 安装记录
在 `~/.ks-config/.installed_modules` 中记录已安装的模块，确保更新和卸载操作可靠。

## 目录结构

```
~/.ks-config/
├── lib/
│   └── bin/
│       ├── install.sh       # 入口脚本
│       ├── main.sh          # 命令路由
│       ├── drift.sh         # 漂移检测
│       ├── doctor.sh        # 健康检查
│       ├── update.sh        # 更新命令
│       ├── uninstall.sh     # 卸载命令
│       ├── log.sh           # 日志工具
│       ├── util.sh          # 共享工具函数
│       ├── fs.sh            # 文件操作
│       └── modules/         # 各工具安装脚本
│           ├── vim.sh
│           ├── git.sh
│           ├── npm.sh
│           ├── eslint.sh
│           └── tmux.sh
├── modules/                 # 配置文件目录
│   ├── vim/
│   ├── git/
│   ├── npm/
│   ├── eslint/
│   └── tmux/
├── .installed_modules       # 安装记录（不纳入 Git）
└── .backup/                 # 备份目录（不纳入 Git）
```

## 使用建议

### 日常维护工作流

```bash
# 1. 定期检查健康状态
~/.ks-config/lib/bin/doctor.sh

# 2. 检查是否有本地修改
~/.ks-config/lib/bin/drift.sh

# 3. 获取最新配置
~/.ks-config/lib/bin/update.sh

# 4. 如需清理，安全卸载
~/.ks-config/lib/bin/uninstall.sh vim --restore
```

### 在多台机器间同步配置

```bash
# 机器 A：修改并提交到仓库
cd ~/.ks-config
git add .
git commit -m "update vim config"
git push

# 机器 B：拉取更新
~/.ks-config/lib/bin/update.sh
```

## Git Hooks

本项目使用 Git hooks 保证代码质量：

```bash
# 安装 hooks
npm install
```

## 许可证

[MIT](./LICENSE)
