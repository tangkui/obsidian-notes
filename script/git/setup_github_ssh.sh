#!/bin/bash
# GitHub SSH 自动配置脚本（智能处理 passphrase）

LOG_FILE="$HOME/setup_github_ssh_auto.log"
KEY_PATH="$HOME/.ssh/id_ed25519"

echo "====================================================" | tee -a "$LOG_FILE"
echo "🚀 GitHub SSH 自动配置脚本启动: $(date)" | tee -a "$LOG_FILE"
echo "日志文件: $LOG_FILE"
echo "===================================================="

mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Step 1: 检查 SSH Key 是否存在
if [ -f "$KEY_PATH" ]; then
    echo "✅ 检测到已有 SSH Key: $KEY_PATH" | tee -a "$LOG_FILE"
else
    echo "🔑 未检测到 SSH Key，需要生成新的。" | tee -a "$LOG_FILE"
    read -p "请输入你的 GitHub 邮箱 (用于标记 key): " GITHUB_EMAIL
    if [ -z "$GITHUB_EMAIL" ]; then
        echo "❌ 错误：邮箱不能为空。" | tee -a "$LOG_FILE"
        exit 1
    fi
    ssh-keygen -t ed25519 -C "$GITHUB_EMAIL" -f "$KEY_PATH" -N "" >>"$LOG_FILE" 2>&1
    if [ $? -ne 0 ]; then
        echo "❌ SSH Key 生成失败，请检查 ssh-keygen。" | tee -a "$LOG_FILE"
        exit 1
    fi
    echo "✅ SSH Key 已生成: $KEY_PATH" | tee -a "$LOG_FILE"
fi

# Step 2: 启动 ssh-agent
eval "$(ssh-agent -s)" >>"$LOG_FILE" 2>&1

# Step 3: 检查是否加密了 passphrase
SSH_PASSPHRASE=""
ssh-keygen -y -f "$KEY_PATH" >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "⚠️  你的私钥设置了 passphrase，需要输入解锁。" | tee -a "$LOG_FILE"
    read -s -p "请输入 SSH Key 的 passphrase: " SSH_PASSPHRASE
    echo ""
    echo "$SSH_PASSPHRASE" | ssh-add "$KEY_PATH" >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "❌ passphrase 错误，加载失败。" | tee -a "$LOG_FILE"
        exit 1
    fi
else
    ssh-add "$KEY_PATH" >>"$LOG_FILE" 2>&1
fi
echo "✅ SSH Key 已加载到 ssh-agent" | tee -a "$LOG_FILE"

# Step 4: 输出公钥
echo "📋 请复制以下公钥到 GitHub → Settings → SSH and GPG keys → New SSH Key" | tee -a "$LOG_FILE"
echo "----------------------------------------------------"
cat "$KEY_PATH.pub"
echo "----------------------------------------------------"

# Step 5: 测试 GitHub 连接
echo "🔍 测试 SSH 连接..."
ssh -T git@github.com 2>&1 | tee -a "$LOG_FILE"

echo "====================================================" | tee -a "$LOG_FILE"
echo "✅ 脚本执行完毕！复制上方公钥到 GitHub 后，即可 git push。" | tee -a "$LOG_FILE"
echo "===================================================="
