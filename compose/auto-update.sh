# 使用以下命令运行代码
# bash <(curl -s https://raw.githubusercontent.com/wolfydw/ziyong/refs/heads/main/compose/auto-update.sh)
# 作者：wolfydw
# 最后更新时间：2025-04-02

#!/bin/bash

# 1. 设置Docker Compose更新脚本路径为当前目录
SCRIPT_PATH="./docker-auto-update.sh"

# 2. 创建docker-auto-update.sh脚本
echo "Creating docker-auto-update.sh script..."

cat > "$SCRIPT_PATH" <<'EOL'
#!/bin/bash
# docker compose一键更新脚本
# 通过输入docker-auto-update实现一键更新
# 执行docker compose down, pull 和 up
docker compose down && docker compose pull && docker compose up -d
EOL

# 3. 赋予脚本执行权限
chmod +x "$SCRIPT_PATH"
echo "docker-auto-update.sh script created and made executable."

# 4. 添加别名到~/.bashrc (检查是否已存在)
echo "Setting up alias for docker-auto-update..."
FULL_PATH="$(pwd)/docker-auto-update.sh"
ALIAS_LINE="alias docker-auto-update='$FULL_PATH'"

# 检查别名是否已存在
if grep -q "alias docker-auto-update=" ~/.bashrc; then
    echo "Alias already exists in ~/.bashrc. Skipping."
else
    echo "$ALIAS_LINE" >> ~/.bashrc
    echo "Alias added to ~/.bashrc."
fi

# 5. 提示用户手动使更改生效
echo "Setup complete! To activate the alias, please run: source ~/.bashrc"
echo "After that, you can use the 'docker-auto-update' command to update your Docker Compose setup."
