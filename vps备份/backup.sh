#!/bin/bash

# 将工作目录设置为脚本所在目录
cd "$(dirname "$0")"

# 设置日志文件
LOG_FILE="./backup.log"

# 记录日志的函数
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# 发送Telegram通知
send_telegram() {
    local status=$1     # success 或 error
    local reason=$2     # 错误原因（可选）
    local error_log=$3  # 详细错误日志（可选）
    
    # 检查是否配置了Telegram
    if [ -z "$TG_BOT_TOKEN" ] || [ -z "$TG_USER_ID" ]; then
        log "未配置Telegram通知"
        return 0
    fi
    
    # 构建消息
    local current_date=$(date +'%Y-%m-%d %H:%M:%S')
    local message=""
    
    if [ "$status" = "success" ]; then
        message=" *备份成功通知* %0A%0A备份主机：${LABLE}%0A备份时间：$current_date%0A备份内容：$BACKUP_DIR%0A文件大小：$BACKUP_SIZE%0A储存位置：$SERVER_IP:$REMOTE_BACKUP_DIR/"
    else
        message=" *备份失败通知* %0A%0A${LABLE}备份失败！"
        if [ -n "$reason" ]; then
            message+="%0A原因：$reason"
        fi
        if [ -n "$error_log" ]; then
            message+="%0A错误日志:%0A\`\`\`$error_log\`\`\`"
        fi
    fi
    
    # 发送消息
    local response=$(curl -s "https://api.telegram.org/bot${TG_BOT_TOKEN}/sendMessage" \
        -d "chat_id=${TG_USER_ID}" \
        -d "text=${message}" \
        -d "parse_mode=Markdown")

    if ! echo "$response" | grep -q '"ok":true'; then
        log "Telegram通知发送失败: $response"
        return 1
    fi
    
    log "Telegram通知发送成功"
    return 0
}

# 函数：处理错误退出
handle_error() {
    local reason=$1
    local error_log=$2
    local cleanup_file=$3
    
    log "错误：$reason"
    
    # 清理临时文件（如果提供了）
    if [ -n "$cleanup_file" ] && [ -f "$cleanup_file" ]; then
        rm "$cleanup_file"
    fi
    
    # 发送失败通知
    send_telegram "error" "$reason" "$error_log"
    
    exit 1
}

log "开始备份程序"

# 检查配置文件是否存在
if [ ! -f "./env.conf" ]; then
    handle_error "env.conf文件不存在"
fi

if [ ! -f "./exclude.list" ]; then
    handle_error "exclude.list文件不存在"
fi

# 读取配置信息
source ./env.conf

# 检查关键变量是否已设置
if [ -z "$SERVER_IP" ] || [ -z "$SERVER_PORT" ] || [ -z "$SERVER_PASSWORD" ]; then
    handle_error "配置文件缺少必要的参数"
fi

# 如果BACKUP_DIR未设置或为空，提示错误
if [ -z "$BACKUP_DIR" ]; then
    handle_error "未指定备份目录 (BACKUP_DIR)"
fi

# 如果REMOTE_BACKUP_DIR未设置，使用默认值
REMOTE_BACKUP_DIR=${REMOTE_BACKUP_DIR:-"/root/backup"}

# 创建备份文件名和临时目录
current_date=$(date +'%Y%m%d_%H%M%S')
BACKUP_FILENAME="backup_${current_date}.tar.gz"
BACKUP_PATH="./$BACKUP_FILENAME"

log "正在创建备份文件: $BACKUP_FILENAME"

# 构建tar命令
tar_cmd="tar --create --gzip --file=\"$BACKUP_PATH\" --warning=no-file-changed --exclude-from=\"./exclude.list\""

# 添加每个源目录到tar命令
for dir in $BACKUP_DIR; do
    # 检查目录是否存在
    if [ ! -d "$dir" ] && [ ! -f "$dir" ]; then
        log "警告：源路径不存在 $dir"
        continue
    fi
    
    # 为每个目录添加正确的tar参数
    base_dir=$(dirname "$dir")
    target_name=$(basename "$dir")
    tar_cmd+=" -C \"$base_dir\" \"$target_name\""
done

# 执行打包命令
log "执行命令: $tar_cmd"
if ! eval $tar_cmd 2>/tmp/backup_error.log; then
    error_log=$(cat /tmp/backup_error.log)
    handle_error "打包文件失败" "$error_log" "$BACKUP_PATH"
fi

# 获取并存储备份文件大小到变量中
BACKUP_SIZE=$(du -h "$BACKUP_PATH" | cut -f1)
log "备份文件创建成功，大小: $BACKUP_SIZE"

# 使用sshpass和scp上传文件到服务器A
log "正在上传备份文件到服务器 $SERVER_IP"

# 检查是否安装了sshpass
if ! command -v sshpass &> /dev/null; then
    log "正在安装sshpass..."
    sudo apt-get update && sudo apt-get install -y sshpass
    if [ $? -ne 0 ]; then
        handle_error "安装sshpass失败" "" "$BACKUP_PATH"
    fi
fi

# 确保远程目录存在
sshpass -p "$SERVER_PASSWORD" ssh -p "$SERVER_PORT" -o StrictHostKeyChecking=no "root@$SERVER_IP" "mkdir -p $REMOTE_BACKUP_DIR"

# 上传文件
sshpass -p "$SERVER_PASSWORD" scp -P "$SERVER_PORT" -o StrictHostKeyChecking=no "$BACKUP_PATH" "root@$SERVER_IP:$REMOTE_BACKUP_DIR/"

if [ $? -ne 0 ]; then
    handle_error "上传备份文件失败" "" "$BACKUP_PATH"
fi

log "备份文件上传成功"

# 清理临时文件
rm "$BACKUP_PATH"

log "备份完成"

# 发送成功通知
send_telegram "success"
