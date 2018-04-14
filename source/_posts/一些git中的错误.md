---
title: 一些git中的错误
date: 2017-7-27 20:09:04
tags: [git]

---

#  git error


```
error: failed to push some refs to 'git@bitbucket.org:dft/ppgame.git'
hint: Updates were rejected because the tip of your current branch is behind
hint: its remote counterpart. Integrate the remote changes (e.g.
hint: 'git pull ...') before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.
```

```
Updates were rejected because the tip of your current branch is behind
```
提示是的很清楚了，你的远程仓库的分支比本地的代码要新所以有冲突，你要么把冲突解决掉再提交要么开新分支提交要么就直接git push --force（多人协作请慎重-。-）。git pull不行是因为你修改了本地，所以远程过来的时候又会有冲突。建议多人协作的时候还是开分支好点。

