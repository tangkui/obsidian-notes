``` bash
#!/bin/bash

echo "🚀 开始清理旧的 Docker 安装..."

# Step 1: 卸载 docker-desktop Cask
brew uninstall --cask docker-desktop || true

# Step 2: 清理 Homebrew 缓存和旧文件
brew cleanup

# Step 3: 删除所有可能的补全文件冲突
echo "🧹 删除 Bash/Fish/Zsh 自动补全冲突文件..."
rm -f /usr/local/etc/bash_completion.d/docker*
rm -f /usr/local/share/fish/vendor_completions.d/docker*
rm -f /usr/local/share/zsh/site-functions/_docker*

# Step 4: 删除旧的 Caskroom 缓存
rm -rf /usr/local/Caskroom/docker-desktop

# Step 5: 删除旧的软链接（确保干净）
rm -f /usr/local/bin/docker*
rm -f /usr/local/cli-plugins/docker-compose
rm -f /usr/local/bin/kubectl.docker
rm -f /usr/local/bin/hub-tool

# Step 6: 重新安装 docker-desktop
echo "📦 正在重新安装 Docker Desktop..."
brew install --cask --force docker-desktop

# Step 7: 启动 Docker GUI 应用提示
echo "✅ 安装完成，请手动启动 Docker Desktop 应用以激活服务（首次必须）"
echo "🧭 可以通过以下命令启动 GUI："
echo "open -a Docker"

# 验证 docker 命令是否可用
echo "🔍 检查 docker 版本："
docker --version 2>/dev/null || echo "❌ docker 命令尚不可用，请先启动 Docker Desktop 应用。"

``` 
