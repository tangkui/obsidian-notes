#!/bin/bash
echo "🚀 开始修复 GitHub SSH Host Key 问题..."

# 1. 删除旧的 github.com host key
ssh-keygen -R github.com 2>/dev/null

# 2. 拉取 GitHub 最新 host key
ssh-keyscan github.com >> ~/.ssh/known_hosts 2>/dev/null

# 3. 测试连接
echo "🔑 正在测试与 GitHub 的 SSH 连接..."
ssh -T git@github.com

echo "✅ 修复完成！如果上面提示 'successfully authenticated' 就代表成功。"
echo "现在可以再次执行: git push -u origin main"

