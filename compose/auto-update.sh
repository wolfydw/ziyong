#!/bin/bash

# 1. 设置Docker Compose更新脚本路径为当前目录
SCRIPT_PATH="./docker-compose-update.sh"

# 2. 创建docker-compose-update.sh脚本
echo "Creating docker-compose-update.sh script..."

cat > "$SCRIPT_PATH" <<EOL
#!/bin/bash
# docker compose一键更新脚本
# 通过输入docker compose update实现一键更新
# 执行docker compose down, pull 和 up
docker compose down && docker compose pull && docker compose up -d
EOL

# 3. 赋予脚本执行权限
chmod +x "$SCRIPT_PATH"
echo "docker-compose-update.sh script created and made executable."

# 4. 添加别名到~/.bashrc
echo "Setting up alias for docker-compose-update..."
echo "alias docker compose update=\"$(pwd)/docker-compose-update.sh\"" >> ~/.bashrc

# 5. 使更改生效
source ~/.bashrc
echo "Alias added to ~/.bashrc. "

echo "Setup complete! Now you can use the 'docker compose update' command to update your Docker Compose setup.."
