#!/bin/bash

# 1. 设置Docker Compose更新脚本路径为当前目录
SCRIPT_PATH="./docker-auto-update.sh"

# 2. 创建docker-auto-update.sh脚本
echo "Creating docker-auto-update.sh script..."

cat > "$SCRIPT_PATH" <<'EOL'
#!/bin/bash
# docker compose一键更新脚本
# 通过输入 docker-auto-update 实现一键更新
# 执行 docker compose down, pull 和 up
docker compose down && docker compose pull && docker compose up -d
EOL

# 3. 赋予脚本执行权限
chmod +x "$SCRIPT_PATH"
echo "docker-auto-update.sh script created and made executable."

# 4. 确保脚本路径正确，并添加 alias 到 ~/.bashrc
ABSOLUTE_PATH="$(pwd)/docker-auto-update.sh"
echo "Setting up alias for docker-auto-update..."
echo "alias docker-auto-update='$ABSOLUTE_PATH'" >> ~/.bashrc

# 5. 使更改生效
source ~/.bashrc
echo "Alias added to ~/.bashrc."

echo "Setup complete! Now you can use the 'docker-auto-update' command to update your Docker Compose setup."
