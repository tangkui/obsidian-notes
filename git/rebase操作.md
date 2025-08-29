
git 提交记录合并

#查看提交记录
git log --oneline 

# 例如：需要合并前面四个提交：2677ce26d~98260b0df
98260b0df (HEAD -> dev-FS-742, origin/dev-FS-742) t-[500]-[dev-FS-742]-[订单拆单-根据售卖模式对订单进行拆单]-[汤浩]
d8900b356 t-[500]-[dev-FS-742]-[订单拆单-根据售卖模式对订单进行拆单]-[汤浩]
7e42b96ab t-[500]-[dev-FS-742]-[订单拆单-单元测试]-[汤浩]
2677ce26d t-[500]-[dev-FS-742]-[订单拆单-根据售卖模式进行拆单]-[汤浩]
508611f1d (tag: 1.5.10.0-508611f1, origin/qa) Merge branch 'qa-zeebe022-off' into 'qa'

#从 2677ce26d 开始（从下往上）的所以提交记录：

#1、以 2677ce26d 开始变基
git rebase -i 2677ce26d


#2、以 2677ce26d的父提交开始变基
git rebase -i 2677ce26d^

#3、从最新一个提交开始变基并且指定前面3个提交记录
git rebase -i HEAD~3

#第一个命令为例：选择最早的提交（2677ce26d）作为 pick，其他标记为 squash。注意：全 squash 无效，需至少一个 pick。

pick 2677ce26d t-[500]-[dev-FS-742]-[订单拆单-根据售卖模式进行拆单]-[汤浩]
squash 7e42b96ab t-[500]-[dev-FS-742]-[订单拆单-单元测试]-[汤浩]
squash d8900b356 t-[500]-[dev-FS-742]-[订单拆单-根据售卖模式对订单进行拆单]-[汤浩]
squash 98260b0df t-[500]-[dev-FS-742]-[订单拆单-根据售卖模式对订单进行拆单]-[汤浩]

#编辑提交信息，保存后，Git 会合并四个提交，并打开编辑器让你编辑最终提交信息。默认情况下，Git 会显示所有四个提交的原始 message：

# This is a combination of 4 commits. 修改这个并且最为最终的提交说明
# The first commit's message is:
t-[500]-[dev-FS-742]-[订单拆单-根据售卖模式进行拆单]-[汤浩]

# The commit message #2 to be squashed:
t-[500]-[dev-FS-742]-[订单拆单-单元测试]-[汤浩]

# The commit message #3 to be squashed:
t-[500]-[dev-FS-742]-[订单拆单-根据售卖模式对订单进行拆单]-[汤浩]

# The commit message #4 to be squashed:
t-[500]-[dev-FS-742]-[订单拆单-根据售卖模式对订单进行拆单]-[汤浩]


#检查合并结果：
git log --oneline -1


#强制推送变更
git push --force




合并了包含其他合并的问题样例：





这是前面五个提交：
98260b0df (HEAD -> dev-FS-742, origin/dev-FS-742) t-[500]-[dev-FS-742]-[订单拆单-根据售卖模式对订单进行拆单]-[汤浩]
d8900b356 t-[500]-[dev-FS-742]-[订单拆单-根据售卖模式对订单进行拆单]-[汤浩]
7e42b96ab t-[500]-[dev-FS-742]-[订单拆单-单元测试]-[汤浩]
2677ce26d t-[500]-[dev-FS-742]-[订单拆单-根据售卖模式进行拆单]-[汤浩]
508611f1d (tag: 1.5.10.0-508611f1, origin/qa) Merge branch 'qa-zeebe022-off' into 'qa'


针对以下五个分支：
508611f1d4c33b661de9063962f65541cae55c17 
2677ce26d138ddd5ab87f4c98c0bd315f6301f90 
7e42b96abe24c24dec63aa38a83eb82729149538 
d8900b3562f67890c5f5efc266093e21e8368843 
98260b0df94ebb5c98c0ba5f603b7dbf937ed0d2


我执行了以下命令：

git rebase -i HEAD~5

pick 508611f1d4c33b661de9063962f65541cae55c17 
suqash 2677ce26d138ddd5ab87f4c98c0bd315f6301f90 
suqash 7e42b96abe24c24dec63aa38a83eb82729149538 
suqash d8900b3562f67890c5f5efc266093e21e8368843 
suqash 98260b0df94ebb5c98c0ba5f603b7dbf937ed0d2

保存操作
:wq


出现以下问题：
自动合并 pom.xml
自动合并 src/main/java/com/comall/ctf/order/application/OrderApplication.java
冲突（内容）：合并冲突于 src/main/java/com/comall/ctf/order/application/OrderApplication.java
错误：不能应用 d76086849... t-[CTF-16470]-[CTF-16471]-[Zeebe0.22下线-拆除旧版相关源码:dc-order]-[李嘉成]
提示： Resolve all conflicts manually, mark them as resolved with
提示： "git add/rm <conflicted_files>", then run "git rebase --continue".
提示： You can instead skip this commit: run "git rebase --skip".
提示： To abort and get back to the state before "git rebase", run "git rebase --abort".
提示： Disable this message with "git config set advice.mergeConflict false"
不能应用 d76086849... t-[CTF-16470]-[CTF-16471]-[Zeebe0.22下线-拆除旧版相关源码:dc-order]-[李嘉成]


#退出合并：git rebase --abort



 
基于远端qa创建并切换到一个新分支 'dev-FS-985'
git checkout -b dev-FS-985 origin/qa

推送分支dev-FS-985至远端
git push -u origin dev-FS-985





-----------------------------------------------------------------------------------------------------------
1、我在idea，本地项目，用git操作了代码hard，然后force push到远端了，
2、分支是dev-CTF-16283
3、现在想回到force push前的代码



查看 reflog，找到 force push 前的提交

git reflog

找到 reset 或 push 之前的提交（比如 def5678）。


恢复到指定提交

git checkout def5678


如果确认是需要的代码，创建一个新分支保存：

git checkout -b dev-CTF-16283-recovery



将恢复的分支推送到远端：

git push origin dev-CTF-16283-recovery


确保 dev-CTF-16283-recovery 包含正确代码。

重置 dev-CTF-16283 到恢复的提交：

git checkout dev-CTF-16283
git reset --hard dev-CTF-16283-recovery


推送回远端（可能需要再次强制推送）

git push origin dev-CTF-16283 --force


在执行危险操作前，备份分支：

git branch backup-dev-CTF-16283