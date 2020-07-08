# Git

Git 是一个开源的分布式版本控制系统，用于敏捷高效地处理任何或小或大的项目。

目前支持的配置是添加提交模版：

对于全局的配置将会软连项目的 `modules/git/.gitmessage.txt` 文件到用户家目录，同时使用 Git 命令进行配置。

对于局部配置则是直接拷贝 `modules/git/.gitmessage.txt` 文件到当前执行命令的位置，并使用 Git 提供的 `--local` 选项进行局部配置。
