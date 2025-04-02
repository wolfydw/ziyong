#!/bin/bash

# 1. 设置Docker Compose更新脚本路径为当前目录
SCRIPT_PATH="./docker-auto-update.sh"

# 2. 创建docker-auto-update.sh脚本
echo "Creating docker-auto-update.sh script..."

cat > "$SCRIPT_PATH" <<EOL
#!/bin/bash
# docker compose一键更新脚本
# 通过输入docker-auto-update实现一键更新
# 执行docker compose down, pull 和 up
docker compose down && docker compose pull && docker compose up -d
EOL

# 3. 赋予脚本执行权限
chmod +x "$SCRIPT_PATH"
echo "docker-auto-update.sh script created and made executable."

# 4. 添加别名到~/.bashrc
echo "Setting up alias for docker-auto-update..."
echo "alias docker-auto-update='$(pwd)/docker-auto-update.sh'" >> ~/.bashrc

# 5. 使更改生效
source ~/.bashrc
echo "Alias added to ~/.bashrc."

echo "Setup complete! Now you can use the 'docker-auto-update' command to update your Docker Compose setup."
