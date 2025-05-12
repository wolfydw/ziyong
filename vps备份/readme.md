## 简介
这是一个自动化服务器备份工具，可以将指定目录的数据备份到远程服务器，并通过Telegram发送备份状态通知。

## 功能特点
- 支持多目录备份
- 安全的远程传输
- 备份完成后通过Telegram通知
- 简单易用的配置方式

# 说明
- backup.sh # 主脚本
- env.conf #

## 贡献
欢迎提交Issue和Pull Request来改进这个工具。

## 许可证
MIT


# 自动备份工具

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

一个简易的备份工具，可以自动打包指定目录并上传至远程服务器，支持多目录备份、排除文件、Telegram通知等功能。

## 功能特点

- 支持备份多个文件/目录
- 自动上传备份到远程服务器
- 排除不需要备份的文件
- 详细的日志记录
- 简单直观的配置方式
- （可选）支持Telegram通知

## 文件结构

```
.
├── backup.sh        # 主备份脚本
├── env.conf         # 配置文件
├── exclude.list     # 排除文件列表
└── README.md        # 说明文档
```

## 安装和使用

### 安装步骤

1. 克隆仓库到本地：

```bash
git clone https://github.com/wolfydw/ziyong.git
```

2. 编辑配置文件：

```bash
nano env.conf
```

3. 设置排除文件列表：

```bash
nano exclude.list
```

4. 添加执行权限：

```bash
chmod +x backup.sh
```

5. 设置定时任务（每天凌晨3点执行）：

```bash

```

### 手动执行备份

```bash
./backup.sh
```

## 配置文件说明

### env.conf

```
# 服务器A的配置
SERVER_IP=192.168.1.100
SERVER_PORT=22
SERVER_PASSWORD=your_password_here

# 备份配置 - 用空格分隔多个路径
BACKUP_DIR="/path/to/dir1 /path/to/dir2 /path/to/file1.txt"
REMOTE_BACKUP_DIR=/home/backup

# Telegram通知配置（可选）
TG_BOT_TOKEN=your_telegram_bot_token
TG_USER_ID=your_telegram_user_id
```

### exclude.list

```
# 以下文件和目录将被排除在备份之外
*.log
*.tmp
.git
node_modules
cache
tmp
```

## Telegram通知

脚本支持通过Telegram发送备份状态通知，可以提供以下信息：

- 备份成功/失败状态
- 备份时间
- 备份文件大小
- 备份存储位置
- 备份耗时
- 错误原因（如失败）

要启用此功能，请在`env.conf`中配置有效的Telegram Bot Token和User ID。

## 故障排除

### 备份失败：文件变化

如果备份过程中遇到"file change as we read it"错误，脚本已包含处理这种情况的参数。如果仍有问题，请考虑在`exclude.list`中添加频繁变化的文件。

### SSH连接问题

确保远程服务器允许SSH密码认证，并且可以从执行脚本的服务器访问。或者考虑使用SSH密钥认证替代密码。

### Telegram通知失败

检查Bot Token和User ID是否正确，确认Bot是否有权限发送消息。如果通知仍然失败，脚本会继续执行并记录错误到日志文件。

## 注意事项

- 请将服务器密码保存在安全的位置，避免泄露
- 定期检查备份文件完整性
- 考虑实施备份轮换策略，避免占用过多存储空间
- 在生产环境使用前充分测试

## 贡献

欢迎通过Pull Request或Issue贡献代码和提出改进建议。

## 许可证

此项目采用MIT许可证 - 详情请参阅LICENSE文件。
