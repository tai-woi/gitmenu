#!/bin/bash
# 定义常量
readonly pretty_format='%C(auto)%h %d %s%Creset %C(cyan)(%an %ad)%Creset'
readonly reflog_format='%C(auto)%h %d %gd %gs%Creset %C(cyan)(%ad)%Creset'
readonly log_n='-n 200'  # 便捷提示（自动显示）时生效，大型仓库保护

# 清屏并显示主菜单
main_menu() {
  while true; do
    clear
    echo '
==== Git 主菜单 ====
  c     基本设置  config
  ic    初始化    init & clone
  lr    日志      log & reflog
  sad   工作状态  status & add & diff
  cr    提交      commit & reset & revert
  s     暂存      stash
  t     打标签    tag
  bc    分支操作  branch & checkout
  mcr   合并      merge & cherry-pick & rebase
  gbl   搜索调试  grep & blame & bisect & ls-tree

  r     远程仓库  remote
  fp    远程操作  fetch & push
  q     退出
==== Git 主菜单 ====
'
    read -e -p '请选择功能：' main_choice
    case $main_choice in
      c)    submenu_config ;;
      ic)   submenu_init ;;
      lr)   submenu_log ;;
      sad)  submenu_status ;;
      cr)   submenu_commit ;;
      s)    submenu_stash ;;
      t)    submenu_tag ;;
      bc)   submenu_branch ;;
      mcr)  submenu_merge ;;
      gbl)  submenu_grep ;;
      r)    submenu_remote ;;
      fp)   submenu_fetch ;;
      q) echo '再见！'; exit 0 ;;
      *) echo "无效选项：$main_choice，请重试"; sleep 1 ;;
    esac
  done
}

# 子菜单：基本设置
submenu_config() {
  local level='global'

  while true; do
    clear
    echo "
---- 基本设置 ----
  c     设置级别（当前 $level）
  csg   执行 config 查找设置并显示来源

  cun   执行 config 设置用户名
  cue   执行 config 设置电子邮箱
  cce   执行 config 设置默认编辑器
  cld   执行 config 设置默认日期格式

  csd   执行 config 设置安全目录
  ccg   执行 config 设置自动签署提交
  cus   执行 config 设置签名密钥

  cd    执行 config 初始化默认设置
  ce    用编辑器修改 $level 配置文件
  q     返回主菜单
---- 基本设置 ----

注意：<必填>，[可填]，{ 选填1 | 选填2 }
"
    read -e -p '请选择操作，或 q 返回：' choice
    case $choice in
      c)
        read -e -p '可输入 { (l)ocal | (g)lobal | (s)ystem }，或留空 global：' c
        case $c in
          l|'local')
            level='local' ;;
          ''|g|'global')
            level='global' ;;
          s|'system')
            level='system' ;;
          *)
            echo "无效输入：$c"
            ;;
        esac
        ;;
      csg)
        read -e -p '可输入 [正则表达式]，或留空显示全部：' param
        echo ">>> git config --show-origin --get-regexp '${param:-.}'"
        git config --show-origin --get-regexp "${param:-.}"
        ;;
      cun)
        read -e -p '请输入 <用户名>：' param
        echo ">>> git config --$level user.name '${param}'"
        git config --$level user.name "${param}"
        ;;
      cue)
        read -e -p '请输入 <电子邮箱>：' param
        echo ">>> git config --$level user.email '${param}'"
        git config --$level user.email "${param}"
        ;;
      cce)
        read -e -p '可输入 [编辑器]，或留空使用 vi 编辑器：' param
        echo ">>> git config --$level core.editor '${param:-vi}'"
        git config --$level core.editor "${param:-vi}"
        ;;
      cld)
        read -e -p '请输入 { (d)efault | (h)uman | (i)so | (l)ocal | (r)elative | (s)hort }：' c
        case $c in
          d|'default')
            echo ">>> git config --$level log.date default"
            git config --$level log.date default
            ;;
          h|'human')
            echo ">>> git config --$level log.date human"
            git config --$level log.date human
            ;;
          i|'iso')
            echo ">>> git config --$level log.date iso"
            git config --$level log.date iso
            ;;
          l|'local')
            echo ">>> git config --$level log.date local"
            git config --$level log.date local
            ;;
          r|'relative')
            echo ">>> git config --$level log.date relative"
            git config --$level log.date relative
            ;;
          s|'short')
            echo ">>> git config --$level log.date short"
            git config --$level log.date short
            ;;
          *)
            echo "无效输入：$c"
            ;;
        esac
        ;;
      csd)
        read -e -p '可输入 [绝对路径]，或留空使用当前路径：' param
        echo ">>> git config --$level --add safe.directory ${param:-$(pwd)}"
        git config --$level --add safe.directory "${param:-$(pwd)}"
        ;;
      ccg)
        read -e -p '请输入 { (f)alse | (t)rue }：' c
        case $c in
          f|false)
            echo ">>> git config --$level commit.gpgsign false"
            git config --$level commit.gpgsign false
            ;;
          t|true)
            echo ">>> git config --$level commit.gpgsign true"
            git config --$level commit.gpgsign true
            ;;
          *)
            echo "无效输入：$c"
            ;;
        esac
        ;;
      cus)
        read -e -p '请输入 <签名密钥>：' param
        echo ">>> git config --$level user.signingkey 'param'"
        git config --$level user.signingkey "param"
        ;;
      cd)
        clear
        echo "
本选项会批量修改多个常用设置，包括：

  git config --$level core.autocrlf input
  git config --$level init.defaultBranch main

  git config --$level diff.algorithm histogram
  git config --$level diff.colorMoved default

  git config --$level core.quotepath false
  git config --$level i18n.commitEncoding utf-8
  git config --$level i18n.logOutputEncoding utf-8

如要新增或修改其它设置，可用编辑器直接修改配置文件。
"
        read -e -p '可输入 [do] 执行：' c
        if [[ "$c" == 'do' ]]; then
          git config --$level core.autocrlf input
          git config --$level init.defaultBranch main

          git config --$level diff.algorithm histogram  # 默认 myers
          git config --$level diff.colorMoved default

          git config --$level core.quotepath false
          git config --$level i18n.commitEncoding utf-8
          git config --$level i18n.logOutputEncoding utf-8

          echo "完成设置默认值。"
        else
          echo "取消设置默认值。"
        fi
        ;;
      ce)
        echo ">>> git config --$level -e"
        git config --$level -e
        ;;
      q)
        return ;;
      *)
        echo "无效选项：$choice" ;;
    esac

    echo '按 Enter 继续...'
    read
  done
}

# 子菜单：初始化
submenu_init() {
  while true; do
    clear
    echo '
---- 初始化 ----
  i     执行 init 初始化
  ib    执行 init 创建裸仓库

  c     执行 clone 克隆仓库
  cd    执行 clone 浅克隆仓库
  cr    执行 clone 克隆仓库和子模块
  crsd  执行 clone 浅克隆仓库和子模块
  q     返回主菜单
---- 初始化 ----

注意：<必填>，[可填]，{ 选填1 | 选填2 }
'
    read -e -p '请选择操作，或 q 返回：' choice
    case $choice in
      i)
        read -e -p '可输入 [仓库目录]，或留空使用当前目录：' param
        echo ">>> git init $param"
        git init $param
        ;;
      ib)
        read -e -p '请输入 <仓库名称>：' param
        echo ">>> git init --bare $param"
        git init --bare $param
        ;;
      c)
        read -e -p '请输入 <远程仓库地址> [仓库目录]：' param
        echo ">>> git clone $param"
        git clone $param
        ;;
      cd)
        read -e -p '请输入 <深度> <远程仓库地址> [仓库目录]：' param
        echo ">>> git clone --depth $param"
        git clone --depth $param
        ;;
      cr)
        read -e -p '请输入 <远程仓库地址> [仓库目录]：' param
        echo ">>> git clone --recursive $param"
        git clone --recursive $param
        ;;
      crsd)
        read -e -p '请输入 <深度> <远程仓库地址> [仓库目录]：' param
        echo ">>> git clone --recursive --shallow-submodules --depth $param"
        git clone --recursive --shallow-submodules --depth $param
        ;;
      q)
        return ;;
      *)
        echo "无效选项：$choice" ;;
    esac

    echo '按 Enter 继续...'
    read
  done
}

# 子菜单：查看日志
submenu_log() {
  # 本栏目 log 筛选时间范围
  local filter_since=''
  local filter_until=''
  local log_su=()

  # 筛选参数记录，避免微调时重复输入
  local filter_message=''
  local filter_diff=''
  local filter_author=''
  local filter_committer=''
  local log_params=()

  local range=''

  while true; do
    clear
    echo "
---- 查看日志 ----
  s     设置 log 默认起始日期（当前 ${filter_since:-不限}）
  u     设置 log 默认终止日期（当前 ${filter_until:-不限}）

  log   执行 log 图形化概览日志
  log2  执行 log 图形化查看指定分支日志
  l     执行 log 线性查看日志

  lg    执行 log 筛选日志记录
  ll    执行 log 查看代码块变更详情

  r     执行 reflog 查看分支操作历史
  rg    兼容 reflog 按操作描述中的关键词过滤操作历史
  q     返回主菜单
---- 查看日志 ----

注意：<必填>，[可填]，{ 选填1 | 选填2 }
"
    read -e -p "请选择操作，或 q 返回：" choice
    case $choice in
      s)
        read -e -p '可输入 [起始日期]，或留空不限：' -i "$filter_since" filter_since
        [[ -n "$filter_since" ]] && log_su[0]=--since="$filter_since" || unset 'log_su[0]'
        ;;
      u)
        read -e -p '可输入 [终止日期]，或留空不限：' -i "$filter_until" filter_until
        [[ -n "filter_until" ]] && log_su[1]=--until="$filter_until" || unset 'log_su[1]'
        ;;
      log)
        read -e -p '可输入 { (b)ranches | (r)emotes | (a)ll }，或留空查看本地分支：' c
        case $c in
          ''|b|'branches')
            echo ">>> git log --oneline --graph --branches ${log_su[@]}"
            git log --oneline --graph --branches "${log_su[@]}"
            ;;
          r|'remotes')
            echo ">>> git log --oneline --graph --remotes ${log_su[@]}"
            git log --oneline --graph --remotes "${log_su[@]}"
            ;;
          a|'all')
            echo ">>> git log --oneline --graph --all ${log_su[@]}"
            git log --oneline --graph --all "${log_su[@]}"
            ;;
          *)
            echo "无效输入：$c"
            ;;
        esac
        ;;
      log2)
        read -e -p '可输入 [分支A] [分支B] [^分支C] 等参数：' param
        git log --oneline --graph "${log_su[@]}" $param
        ;;
      l)
        git branch -vv -a
        read -e -p '可输入 [-8] [提交A..提交B] [-- 文件或目录]：' param
        show_log "$param" "${log_su[@]}"
        ;;
      lg)
        read -e -p '可输入 [提交说明] 筛选，支持正则表达式：' -i "$filter_message" filter_message
        read -e -p '可输入 [内容文字] 筛选，如果以 G: 开头则支持正则表达式：' -i "$filter_diff" filter_diff
        read -e -p '可输入 [作者] 筛选，支持正则表达式：' -i "$filter_author" filter_author
        read -e -p '可输入 [提交者] 筛选，支持正则表达式：' -i "$filter_committer" filter_committer
        read -e -p '可输入 [-8] [提交A..提交B] [-- 文件或目录] 查找：' -i "$range" range

        log_params=()
        [[ -n $filter_message ]] && log_params+=(--grep="$filter_message")

        if [[ "$filter_diff" == G:* ]]; then
          log_params+=(-G "${filter_diff#G:}")
        elif [[ -n $filter_diff ]]; then
          log_params+=(-S "$filter_diff")
        fi

        [[ -n $filter_author ]] && log_params+=(--author="$filter_author")
        [[ -n $filter_committer ]] && log_params+=(--committer="$filter_committer")

        show_log "$range" "${log_su[@]}" "${log_params[@]}"
        ;;
      ll)
        read -e -p '请输入 { <起始行>,<终止行>:<文件路径> | :<函数名>:<文件路径> }：' param
        echo ">>> git log -L $param"
        git log "${log_su[@]}" -L "$param"
        ;;
      r)
        read -e -p '可输入 [--stat] [分支名] 等参数，或留空默认：' param
        echo ">>> git reflog $param"
        git reflog --pretty=format:"$reflog_format" $param
        ;;
      rg)
        read -e -p '可输入 [查找文字]，支持正则表达式：' param
        read -e -p '可输入 [--stat] 等参数，或留空默认：' param2
        echo ">>> git log -g --grep-reflog='$param' $param2"
        git log --pretty=format:"$reflog_format" -g --grep-reflog="$param" $param2
        ;;
      q)
        return ;;
      *)
        echo "无效选项：$choice" ;;
    esac

    echo '按 Enter 继续...'
    read
  done
}

# 子菜单：工作状态
submenu_status() {
  while true; do
    clear
    echo '
---- 工作状态 ----
  ssb   执行 status 短格式查看状态和分支信息
  sis   执行 status 完整包含忽略和储藏的文件

  a     执行 add 添加未跟踪的文件或目录
  ai    执行 add 进入交互式暂存模式
  r     执行 restore 恢复文件状态

  d     执行 diff 比较，默认比较工作区与暂存区
  ds    执行 diff 比较暂存区与当前所在提交
  dh    执行 diff 比较工作区与当前所在提交
  q     返回主菜单
---- 工作状态 ----

注意：<必填>，[可填]，{ 选填1 | 选填2 }
'
    read -e -p '请选择操作，或 q 返回：' choice
    case $choice in
      ssb)
        read -e -p '可输入 [-- 文件或目录]，或留空显示全部：' param
        echo ">>> git status -sb $param"
        git status -sb $param
        ;;
      sis)
        read -e -p '可输入 [-- 文件或目录]，或留空显示全部：' param
        echo ">>> git status --ignored --show-stash $param"
        git status --ignored --show-stash $param
        ;;
      a)
        git status -sb
        read -e -p '可输入 [文件或目录]，或留空添加全部：' param
        echo ">>> git add ${param:--A}"
        git add ${param:--A}
        ;;
      ai)
        echo ">>> git add -i"
        git add -i
        ;;
      r)
        git status -sb
        read -e -p '可输入 { (w)orktree | (s)taged | (ws) }，或留空恢复工作区：' c
        case $c in
          ''|w|'worktree')
            read -e -p '可输入 [文件或目录]，或留空使用交互模式：' param
            echo ">>> git restore ${param:--p}"
            git restore ${param:--p}
            ;;
          s|'staged')
            read -e -p '可输入 [文件或目录]，或留空使用交互模式：' param
            echo ">>> git restore --staged ${param:--p}"
            git restore --staged ${param:--p}
            ;;
          'ws')
            read -e -p '可输入 [文件或目录]，或留空使用交互模式：' param
            echo ">>> git restore -WS ${param:--p}"
            git restore -WS ${param:--p}
            ;;
          *)
            echo "无效输入：$c"
            ;;
        esac
        ;;
      d)
        read -e -p '可输入 [--stat] [远程分支..本地分支] 等参数，或留空比较工作区与暂存区：' param
        echo ">>> git diff $param"
        git diff $param
        ;;
      ds)
        read -e -p '可输入 [--stat] [-- 文件或目录] 等参数，或留空显示全部：' param
        echo ">>> git diff --staged $param"
        git diff --staged $param
        ;;
      dh)
        read -e -p '可输入 [--stat] [-- 文件或目录] 等参数，或留空显示全部：' param
        echo ">>> git diff HEAD $param"
        git diff HEAD $param
        ;;
      q)
        return ;;
      *)
        echo "无效选项：$choice" ;;
    esac

    echo '按 Enter 继续...'
    read
  done
}

# 子菜单：提交
submenu_commit() {
  while true; do
    clear
    echo '
---- 提交 ----
  c     执行 commit 提交暂存的变更
  ca    执行 commit 修正当前所在提交
  cf    执行 commit 标记修复以前的提交
  cs    执行 commit 标记压缩以前的提交

  ria   执行 rebase 自动变基
  r     执行 reset 重置到指定提交

  rn    执行 revert 安全撤销之前的提交（暂存）
  rm    执行 revert 撤销合并提交
  rcas  执行 revert 处理撤销冲突
  q     返回主菜单
---- 提交 ----

注意：<必填>，[可填]，{ 选填1 | 选填2 }
'
    read -e -p '请选择操作，或 q 返回：' choice
    case $choice in
      c)
        git status -sb
        read -e -p '可输入 [提交说明]，或留空使用编辑器撰写：' param
        echo ">>> git commit ${param:+-m '$param'}"
        git commit ${param:+-m "$param"}
        ;;
      ca)
        git status -sb
        read -e -p '可输入 [提交说明]，或留空编辑原提交说明：' param
        echo ">>> git commit --amend ${param:+-m '$param'}"
        git commit --amend ${param:+-m "$param"}
        ;;
      cf)
        git log --oneline $log_n
        read -e -p '请输入 <提交哈希或引用>：' param
        echo ">>> git commit --fixup $param"
        git commit --fixup $param
        ;;
      cs)
        git log --oneline $log_n
        read -e -p '请输入 <提交哈希或引用>：' param
        echo ">>> git commit --squash $param"
        git commit --squash $param
        ;;
      ria)
        git log --oneline $log_n
        read -e -p '请输入 <提交哈希或引用>，需指定包含所有修复或压缩的前一个提交：' param
        echo ">>> git rebase -i --autosquash $param"
        git rebase -i --autosquash $param
        ;;
      r)
        git log --oneline $log_n
        read -e -p '可输入 [提交哈希或引用]，或留空对于当前所在提交：' param
        read -e -p '可输入 { (s)oft | (m)ixed | (h!)ard!! }，或留空 mixed：' c
        case $c in
          s|'soft')
            echo ">>> git reset --soft $param"
            git reset --soft $param
            ;;
          ''|m|'mixed')
            echo ">>> git reset --mixed $param"
            git reset --mixed $param
            ;;
          'h!'|'hard!!')
            echo ">>> git reset --hard $param"
            git reset --hard $param
            ;;
          *)
            echo "无效输入：$c"
            ;;
        esac
        ;;
      rn)
        git log --oneline $log_n
        read -e -p '请输入 <提交哈希或提交区间>：' param
        echo ">>> git revert -n $param"
        git revert -n $param
        ;;
      rm)
        git log --oneline --merges $log_n
        # 只保留父编号是 1 的情况，表示本分支，2 是合并进来的分支
        read -e -p '请输入 <合并提交的哈希>：' param
        echo ">>> git revert -m 1 $param"
        git revert -m 1 $param
        ;;
      rcas)
        git status --show-stash
        read -e -p '请输入 { (c)ontinue | (a)bort | (s)kip }：' c
        case $c in
          c|'continue')
            echo ">>> git revert --continue"
            git revert --continue
            ;;
          a|'abort')
            echo ">>> git revert --abort"
            git revert --abort
            ;;
          s|'skip')
            echo ">>> git revert --skip"
            git revert --skip
            ;;
          *)
            echo "无效输入：$c"
            ;;
        esac
        ;;
      q)
        return ;;
      *)
        echo "无效选项：$choice" ;;
    esac

    echo '按 Enter 继续...'
    read
  done
}

# 子菜单：暂存
submenu_stash() {
  while true; do
    clear
    echo '
---- 暂存 ----
  sl    执行 stash 查看暂存列表
  ss    执行 stash 查看暂存记录

  spm   执行 stash 暂存变更的文件
  sap   执行 stash 恢复暂存的文件
  sd    执行 stash 删除暂存记录

  sb    执行 stash 从暂存记录建立新分支
  q     返回主菜单
---- 暂存 ----

注意：<必填>，[可填]，{ 选填1 | 选填2 }
'
    read -e -p '请选择操作，或 q 返回：' choice
    case $choice in
      sl)
        echo ">>> git stash list"
        git stash list
        ;;
      ss)
        git stash list
        read -e -p '可输入 [暂存编号]，或留空查看最近一次暂存：' param
        read -e -p '可输入 [-p] 查看代码差异，或留空只查看变更摘要：' param2
        echo ">>> git stash show $param2 stash@{${param:-0}}"
        git stash show $param2 stash@{${param:-0}}
        ;;
      spm)
        git stash list
        read -e -p '可输入 { -u | -a | -p }，或留空只暂存已跟踪的文件：' param
        read -e -p '可输入 [注释文字]，或留空默认：' param2
        echo ">>> git stash push $param ${param2:+-m '$param2'}"
        git stash push $param ${param2:+-m "$param2"}
        ;;
      sap)
        git stash list
        read -e -p '可输入 [暂存编号]，或留空恢复最近一次暂存：' param
        read -e -p '可输入 [pop]，或留空应用 apply：' param2
        echo ">>> git stash ${param2:-apply} --index stash@{${param:-0}}"
        git stash ${param2:-apply} --index stash@{${param:-0}}
        ;;
      sd)
        git stash list
        read -e -p '请输入 <暂存编号>：' param
        echo ">>> git stash drop stash@{$param}"
        git stash drop stash@{$param}
        ;;
      sb)
        git stash list
        read -e -p '可输入 [暂存编号]，或留空使用最近一次暂存：' param
        read -e -p '请输入 <分支名>：' param2
        echo ">>> git stash branch $param2 stash@{${param:-0}}"
        git stash branch $param2 stash@{${param:-0}}
        ;;
      q)
        return ;;
      *)
        echo "无效选项：$choice" ;;
    esac

    echo '按 Enter 继续...'
    read
  done
}

# 子菜单：打标签
submenu_tag() {
  while true; do
    clear
    echo '
---- 打标签 ----
  tl    执行 tag 查看标签列表
  ss    执行 show 查看标签元数据

  tm    执行 tag 查看是否已合并的标签列表
  tc    执行 tag 查看是否包含指定提交的标签列表

  t     执行 tag 创建新标签
  te    执行 tag 使用编辑器撰写新标签
  td    执行 tag 删除标签
  q     返回主菜单
---- 打标签 ----

注意：<必填>，[可填]，{ 选填1 | 选填2 }
'
    read -e -p '请选择操作，或 q 返回：' choice
    case $choice in
      tl)
        read -e -p '可输入 [标签格式]，支持通配符，或留空显示全部：' param
        read -e -p '可输入 [行数] 显示几行注释信息，或留空以行格式显示：' param2
        if [[ -n "$param2" ]]; then
          echo ">>> git tag ${param:+-l '$param'} -n$param2"
          git tag ${param:+-l "$param"} "-n$param2"
        else
          echo ">>> git tag ${param:+-l '$param'} --column=row"
          git tag ${param:+-l "$param"} --column=row
        fi
        ;;
      ss)
        git tag --column=row
        read -e -p '请输入 <标签名>，否则显示当前所在提交：' param
        echo ">>> git show -s $param"
        git show -s $param
        ;;
      tm)
        git branch -vv -a
        echo "提示：如果需要指定某个特别的提交，可以自行查找，然后复制过来。"
        read -e -p '可输入 [提交哈希或引用]，或留空对于当前所在提交：' param
        read -e -p '请输入 { (m)erged | (n)o-merged }：' c
        case $c in
          m|'merged')
            echo ">>> git tag -n --merged ${param:-HEAD}"
            git tag -n --merged ${param:-HEAD}
            ;;
          n|'no-merged')
            echo ">>> git tag -n --no-merged ${param:-HEAD}"
            git tag -n --no-merged ${param:-HEAD}
            ;;
          *)
            echo "无效输入：$c"
            ;;
        esac
        ;;
      tc)
        git branch -vv -a
        echo "提示：如果需要指定某个特别的提交，可以自行查找，然后复制过来。"
        read -e -p '可输入 [提交哈希或引用]，或留空对于当前所在提交：' param
        read -e -p '请输入 { (c)ontains | (n)o-contains }：' c
        case $c in
          c|'contains')
            echo ">>> git tag -n --contains ${param:-HEAD}"
            git tag -n --contains ${param:-HEAD}
            ;;
          n|'no-contains')
            echo ">>> git tag -n --no-contains ${param:-HEAD}"
            git tag -n --no-contains ${param:-HEAD}
            ;;
          *)
            echo "无效输入：$c"
            ;;
        esac
        ;;
      t)
        read -e -p '请输入 <标签名> [提交哈希或引用]：' param
        read -e -p '可输入 [标签说明]，或留空创建轻量标签：' param2
        echo ">>> git tag $param ${param2:+-m '$param2'}"
        git tag $param ${param2:+-m "$param2"}
        ;;
      te)
        read -e -p '请输入 <标签名> [提交哈希或引用]：' param
        echo ">>> git tag -e $param"
        git tag -e $param
        ;;
      td)
        git tag --column=row
        read -e -p '请输入 <标签名>：' param
        echo ">>> git tag -d $param"
        git tag -d $param
        ;;
      q)
        return ;;
      *)
        echo "无效选项：$choice" ;;
    esac

    echo '按 Enter 继续...'
    read
  done
}

# 子菜单：分支操作
submenu_branch() {
  while true; do
    clear
    echo '
---- 分支操作 ----
  bv    执行 branch 查看分支列表
  bvl   执行 branch 查找类似名称的分支

  bvm   执行 branch 查看是否已合并的分支列表
  bvc   执行 branch 查看是否包含指定提交的分支列表

  b     执行 branch 创建新分支（不切换）
  bm    执行 branch 重命名分支
  bd    执行 branch 删除分支

  bsu   执行 branch 关联远程分支
  buu   执行 branch 取消关联远程分支

  c     执行 checkout 切换分支
  cb    执行 checkout 创建新分支并切换
  q     返回主菜单
---- 分支操作 ----

注意：<必填>，[可填]，{ 选填1 | 选填2 }
'
    read -e -p '请选择操作，或 q 返回：' choice
    case $choice in
      bv)
        read -e -p '可输入 { -r | -a }，或留空仅查看本地分支：' param
        echo ">>> git branch -vv $param"
        git branch -vv $param
        ;;
      bvl)
        read -e -p '请输入 <查找文字>，支持的 Glob 通配符：' param
        read -e -p '可输入 { -r | -a }，或留空仅查看本地分支：' param2
        echo ">>> git branch -vv $param2 --list '$param'"
        git branch -vv $param2 --list "$param"
        ;;
      bvm)
        git branch -vv -a
        echo "提示：如果需要指定某个特别的提交，可以自行查找，然后复制过来。"
        read -e -p '可输入 [提交哈希或引用]，或留空对于当前分支：' param
        read -e -p '可输入 { -r | -a }，或留空仅查看本地分支：' param2
        read -e -p '请输入 { (m)erged | (n)o-merged }：' c
        case $c in
          m|'merged')
            echo ">>> git branch -vv $param2 --merged $param"
            git branch -vv $param2 --merged $param
            ;;
          n|'no-merged')
            echo ">>> git branch -vv $param2 --no-merged $param"
            git branch -vv $param2 --no-merged $param
            ;;
          *)
            echo "无效输入：$c"
            ;;
        esac
        ;;
      bvc)
        git branch -vv -a
        echo "提示：如果需要指定某个特别的提交，可以自行查找，然后复制过来。"
        read -e -p '可输入 [提交哈希或引用]，或留空对于当前分支：' param
        read -e -p '可输入 { -r | -a }，或留空仅查看本地分支：' param2
        read -e -p '请输入 { (c)ontains | (n)o-contains }：' c
        case $c in
          c|'contains')
            echo ">>> git branch -vv $param2 --contains $param"
            git branch -vv $param2 --contains $param
            ;;
          n|'no-contains')
            echo ">>> git branch -vv $param2 --no-contains $param"
            git branch -vv $param2 --no-contains $param
            ;;
          *)
            echo "无效输入：$c"
            ;;
        esac
        ;;
      b)
        git branch -vv -a
        echo "提示：如果需要指定某个特别的提交，可以自行查找，然后复制过来。"
        read -e -p '请输入 <新分支名> [提交哈希或引用]，远程分支自动关联：' param
        echo ">>> git branch $param"
        git branch $param
        ;;
      bm)
        git branch -vv
        read -e -p '请输入 [旧分支名] <新分支名>：' param
        echo ">>> git branch -m $param"
        git branch -m $param
        ;;
      bd)
        git branch -vv
        read -e -p '请输入 [-f] <分支名>：' param
        echo ">>> git branch -d $param"
        git branch -d $param
        ;;
      bsu)
        git branch -vv -a
        read -e -p '请输入 <远程分支名> [本地分支名]：' param
        echo ">>> git branch --set-upstream-to $param"
        git branch --set-upstream-to $param
        ;;
      buu)
        git branch -vv
        read -e -p '可输入 [本地分支名]，或留空对于当前分支：' param
        echo ">>> git branch --unset-upstream $param"
        git branch --unset-upstream $param
        ;;
      c)
        git branch -vv
        read -e -p '请输入 <分支名>：' param
        echo ">>> git checkout $param"
        git checkout $param
        ;;
      cb)
        git branch -vv -a
        echo "提示：如果需要指定某个特别的提交，可以自行查找，然后复制过来。"
        read -e -p '请输入 <新分支名> [提交哈希或引用]，远程分支自动关联：' param
        echo ">>> git checkout -b $param"
        git checkout -b $param
        ;;
      q)
        return ;;
      *)
        echo "无效选项：$choice" ;;
    esac

    echo '按 Enter 继续...'
    read
  done
}

# 子菜单：合并
submenu_merge() {
  while true; do
    clear
    echo '
---- 合并 ----
  m     执行 merge 合并提交
  mnc   执行 merge 合并（暂存）
  ms    执行 merge 压缩合并（暂存）
  mca   执行 merge 处理合并冲突

  c     执行 cherry-pick 挑选提交
  ccas  执行 cherry-pick 处理挑选提交冲突

  r     执行 rebase 变基
  rcas  执行 rebase 处理变基冲突
  q     返回主菜单
---- 合并 ----

注意：<必填>，[可填]，{ 选填1 | 选填2 }
'
    read -e -p '请选择操作，或 q 返回：' choice
    case $choice in
      m)
        git branch -vv -a
        read -e -p '请输入 <分支名>：' param
        read -e -p '可输入 [提交说明]，或留空使用编辑器撰写：' param2
        read -e -p '可输入 { (f)f-only | (n)o-ff } 选择是否快进，或留空自动：' c
        case $c in
          '')
            echo ">>> git merge $param ${param2:+-m '$param2'}"
            git merge $param ${param2:+-m "$param2"}
            ;;
          f|'ff-only')
            echo ">>> git merge --ff-only $param ${param2:+-m '$param2'}"
            git merge --ff-only $param ${param2:+-m "$param2"}
            ;;
          n|'no-ff')
            echo ">>> git merge --no-ff $param ${param2:+-m '$param2'}"
            git merge --no-ff $param ${param2:+-m "$param2"}
            ;;
          *)
            echo "无效输入：$c"
            ;;
        esac
        ;;
      mnc)
        git branch -vv -a
        read -e -p '请输入 <分支名>：' param
        echo ">>> git merge --no-commit	$param"
        git merge --no-commit	$param
        ;;
      ms)
        git branch -vv -a
        read -e -p '请输入 <分支名>：' param
        echo ">>> git merge --squash $param"
        git merge --squash $param
        ;;
      mca)
        git status --show-stash
        read -e -p '请输入 { (c)ontinue | (a)bort }：' c
        case $c in
          c|'continue')
            echo ">>> git merge --continue"
            git merge --continue
            ;;
          a|'abort')
            echo ">>> git merge --abort"
            git merge --abort
            ;;
          *)
            echo "无效输入：$c"
            ;;
        esac
        ;;
      c)
        git branch -vv -a
        read -e -p '待提取提交所在的分支：' ref
        git log --oneline $log_n $ref
        read -e -p '请输入 <提交哈希或提交区间>：' param
        read -e -p '可输入 [-n] 只应用改动，或留空自动提交：' param2
        echo ">>> git cherry-pick ${param2:--x} $param"
        git cherry-pick ${param2:--x} $param
        ;;
      ccas)
        git status --show-stash
        read -e -p '请输入 { (c)ontinue | (a)bort | (s)kip }：' c
        case $c in
          c|'continue')
            echo ">>> git cherry-pick --continue"
            git cherry-pick --continue
            ;;
          a|'abort')
            echo ">>> git cherry-pick --abort"
            git cherry-pick --abort
            ;;
          s|'skip')
            echo ">>> git cherry-pick --skip"
            git cherry-pick --skip
            ;;
          *)
            echo "无效输入：$c"
            ;;
        esac
        ;;
      r)
        git branch -vv -a
        echo "提示：如果需要指定某个特别的提交，可以自行查找，然后复制过来。"
        read -e -p '请输入 [-i] <提交哈希或引用>：' param
        echo ">>> git rebase $param"
        git rebase $param
        ;;
      rcas)
        git status --show-stash
        read -e -p '请输入 { (c)ontinue | (a)bort | (s)kip }：' c
        case $c in
          c|'continue')
            echo ">>> git rebase --continue"
            git rebase --continue
            ;;
          a|'abort')
            echo ">>> git rebase --abort"
            git rebase --abort
            ;;
          s|'skip')
            echo ">>> git rebase --skip"
            git rebase --skip
            ;;
          *)
            echo "无效输入：$c"
            ;;
        esac
        ;;
      q)
        return ;;
      *)
        echo "无效选项：$choice" ;;
    esac

    echo '按 Enter 继续...'
    read
  done
}

# 子菜单：搜索调试
submenu_grep() {
  local lt_path=''

  while true; do
    clear
    echo '
---- 搜索调试 ----
  g     执行 grep 搜索指定文字
  b     执行 blame 查看代码责任

  bbg   执行 bisect 查找坏提交
  bsp   执行 bisect 复位或重放

  lt    执行 ls-tree 查看指定提交的树对象
  s     执行 show 查看指定对象（可导出）
  q     返回主菜单
---- 搜索调试 ----

注意：<必填>，[可填]，{ 选填1 | 选填2 }
'
    read -e -p '请选择操作，或 q 返回：' choice
    case $choice in
      g)
        read -e -p '请输入 [-i] [-w] [-F] [-v] -e <搜索文字>：' param
        read -e -p '可输入 [-n] [-p] 等显示参数，或留空默认：' param2
        read -e -p '可输入 [提交哈希或引用] [-- 文件或目录]，或留空搜索工作区：' param3
        echo ">>> git grep -I $param2 $param $param3"
        git grep -I $param2 $param $param3
        ;;
      b)
        read -e -p '请输入 [提交哈希或引用] <-- 文件路径>：' param
        read -e -p '可输入 { :<函数名> | -L <起始行>,<终止行> } 等参数，或留空显示全部：' param2
        read -e -p '可输入 [起始日期] 等参数，或留空不限：' param3
        echo ">>> git blame ${param3:+--since='$param3'} -w $param2 $param"
        git blame ${param3:+--since="$param3"} -w $param2 $param
        ;;
      bbg)
        read -e -p '请输入 { (s)tart | (b)ad | (g)ood | s(k)ip | (r)un | (l)og }：' c
        case $c in
          s|'start')
            read -e -p '可输入 [终点 起点]，或留空全查：' param
            echo ">>> git bisect start $param"
            git bisect start $param
            ;;
          b|'bad')
            read -e -p '可输入 [提交哈希]，或留空标记当前位置：' param
            echo ">>> git bisect bad $param"
            git bisect bad $param
            ;;
          g|'good')
            read -e -p '可输入 [提交哈希]，或留空标记当前位置：' param
            echo ">>> git bisect good $param"
            git bisect good $param
            ;;
          k|'skip')
            read -e -p '可输入 [提交哈希]，或留空标记当前位置：' param
            echo ">>> git bisect skip $param"
            git bisect skip $param
            ;;
          r|'run')
            read -e -p '请输入 <脚本>：' param
            echo ">>> git bisect run $param"
            git bisect run $param
            ;;
          l|'log')
            echo ">>> git bisect log"
            git bisect log

            read -e -p '可输入 [文件路径] 保存为文件，或留空不保存：' filename
            if [[ -n "$filename" ]]; then
              git bisect log > "$filename"
              echo "文件已保存： $filename"
            fi
            ;;
          *)
            echo "无效输入：$c"
            ;;
        esac
        ;;
      bsp)
        read -e -p '请输入 { re(s)et | re(p)lay }：' c
        case $c in
          s|'reset')
            echo ">>> git bisect reset"
            git bisect reset
            ;;
          p|'replay')
            read -e -p '请输入 <文件路径>：' param
            echo ">>> git bisect replay $param"
            git bisect replay $param
            ;;
          *)
            echo "无效输入：$c"
            ;;
        esac
        ;;
      lt)
        git branch -vv -a
        read -e -p '可输入 [树对象或引用]，或留空查看当前所在提交：' param
        while true; do
          read -e -p '可输入 [文件或目录]，或 q 退出：' -i "$lt_path" param2
          if [[ "$param2" = "q" ]]; then
            break
          fi
          clear
          echo ">>> git ls-tree --abbrev -l ${param:-HEAD} ${param2:+-- $param2}"
          git ls-tree --abbrev -l ${param:-HEAD}  ${param2:+-- $param2} | less -FRX
          lt_path=$param2
        done
        ;;
      s)
        git branch -vv -a
        echo "提示：如果需要指定某个特别的哈希，可以自行查找，然后复制过来。"
        while true; do
          read -e -p '可输入 [对象哈希或引用] 和相应的参数，或 q 退出：' param
          if [[ "$param" = "q" ]]; then
            break
          fi
          echo ">>> git show ${param:---raw}"
          git show ${param:---raw}
        done
        read -e -p '可输入 [文件路径] 保存为文件，留空或 q 不保存：' filename
        if [[ "$filename" != "q" && -n "$filename" ]]; then
          git show $param > "$filename"
          echo "文件已保存： $filename"
        fi
        ;;
      q)
        return ;;
      *)
        echo "无效选项：$choice" ;;
    esac

    echo '按 Enter 继续...'
    read
  done
}

# 子菜单：远程仓库
submenu_remote() {
  while true; do
    clear
    echo '
---- 远程仓库 ----
  rv    执行 remote 查看远程仓库列表
  rs    执行 remote 查看远程仓库信息

  ra    执行 remote 添加新的远程仓库
  rm    执行 remote 删除远程仓库
  rn    执行 remote 重命名远程仓库
  rsu   执行 remote 修改远程仓库地址

  rp    执行 remote 清理远程仓库中已删除的分支
  q     返回主菜单
---- 远程仓库 ----

注意：<必填>，[可填]，{ 选填1 | 选填2 }
'
    read -e -p '请选择操作，或 q 返回：' choice
    case $choice in
      rv)
        echo ">>> git remote -v"
        git remote -v
        ;;
      rs)
        git remote
        read -e -p '可输入 [仓库别名]，或留空显示 origin：' param
        echo ">>> git remote show ${param:-origin}"
        git remote show ${param:-origin}
        ;;
      ra)
        git remote
        read -e -p '请输入 <仓库别名> <远程仓库地址>：' param
        echo ">>> git remote add $param"
        git remote add $param
        ;;
      rm)
        git remote
        read -e -p '请输入 <仓库别名>：' param
        echo ">>> git remote remove $param"
        git remote remove $param
        ;;
      rn)
        git remote
        read -e -p '请输入 <旧仓库名> <新仓库名>：' param
        echo ">>> git remote rename $param"
        git remote rename $param
        ;;
      rsu)
        # 取消支持多推送地址，因为修改时不方便。需要时改用多个远程仓库。
        git remote
        read -e -p '请输入 <仓库别名> <新仓库地址>：' param
        echo ">>> git remote set-url $param"
        git remote set-url $param
        ;;
      rp)
        git remote
        read -e -p '可输入 [仓库别名]，或留空清理 origin：' param
        echo ">>> git remote prune ${param:-origin}"
        git remote prune ${param:-origin}
        ;;
      q)
        return ;;
      *)
        echo "无效选项：$choice" ;;
    esac

    echo '按 Enter 继续...'
    read
  done
}

# 子菜单：远程操作
submenu_fetch() {
  while true; do
    clear
    # TODO: fetch 暂未实现 --all, --depth, --recurse-submodules
    # TODO: push 暂未实现 --all, --tags
    echo '
---- 远程操作 ----
  ppr   执行 pull 拉取并自动变基
  fp    执行 fetch 获取远程仓库的分支和标签信息

  pu    执行 push 首次推送并关联远程分支
  p     执行 push 推送本地分支到远程
  pd    执行 push 删除远程分支

  pt    执行 push 推送本地标签到远程
  ptd   执行 push 删除远程标签
  q     返回主菜单
---- 远程操作 ----

注意：<必填>，[可填]，{ 选填1 | 选填2 }
'
    read -e -p '请选择操作，或 q 返回：' choice
    case $choice in
      ppr)
        git branch -vv -a
        read -e -p '可输入 [仓库别名 [分支名]]，或留空更新当前分支：' param
        echo ">>> git pull --prune --rebase $param"
        git pull --prune --rebase $param
        ;;
      fp)
        git branch -vv -a
        read -e -p '可输入 [仓库别名 [分支名]]，或留空获取上游或默认仓库的分支信息：' param
        read -e -p '可输入 [tags] 进一步获取相关标签信息：' c
        if [[ "$c" == 'tags' ]]; then
          echo ">>> git fetch -p --follow-tags $param"
          git fetch -p --follow-tags $param
        else
          echo ">>> git fetch -p $param"
          git fetch -p $param
        fi
        ;;
      pu)
        git branch -vv -a
        read -e -p '可输入 [仓库别名 [本地分支名[:远程分支名]]]，或留空推送当前分支到 origin：' param
        echo ">>> git push -u ${param:-origin HEAD}"
        git push -u ${param:-origin HEAD}
        ;;
      p)
        git branch -vv -a
        read -e -p '可输入 [仓库别名 [本地分支名[:远程分支名]]]，或留空推送当前分支到上游：' param
        read -e -p '可输入 { (f)orce | force-with-(l)ease }，或留空不覆盖：' c
        case $c in
          '')
            echo ">>> git push $param"
            git push $param
            ;;
          f|'force')
            echo ">>> git push --force $param"
            git push --force $param
            ;;
          l|'force-with-lease')
            echo ">>> git push --force-with-lease $param"
            git push --force-with-lease $param
            ;;
          *)
            echo "无效输入：$c"
            ;;
        esac
        ;;
      pd)
        git branch -r
        read -e -p '请输入 <仓库别名> <分支名>：' param
        echo ">>> git push --delete $param"
        git push --delete $param
        ;;
      pt)
        git remote
        read -e -p '可输入 [仓库别名]，或留空对于 origin：' param
        git tag --column=row
        read -e -p '请输入 <标签名> [-f]：' param2
        echo ">>> git push ${param:-origin} $param2"
        git push ${param:-origin} $param2
        ;;
      ptd)
        git remote
        read -e -p '可输入 [仓库别名]，或留空对于 origin：' param
        git tag --column=row
        read -e -p '请输入 <标签名>：' param2
        echo ">>> git push --delete ${param:-origin} $param2"
        git push --delete ${param:-origin} $param2
        ;;
      q)
        return ;;
      *)
        echo "无效选项：$choice" ;;
    esac

    echo '按 Enter 继续...'
    read
  done
}

# 显示线性 log 日志
# 注意：第一个参数是 $range，后面是 $log_params[]
show_log() {
  local range="$1"
  shift

  read -e -p '可输入 { (o)neline | (n)umstat | (r)aw | (p)atch }，或留空 oneline：' c
  # TODO: 运行正常，echo 不显示双引号，这是默认行为
  case $c in
    ''|o|'oneline')
      echo ">>> git log $@ $range"
      git log --pretty=format:"$pretty_format" "$@" $range
      ;;
    n|'numstat')
      echo ">>> git log --numstat --shortstat $@ $range"
      git log --numstat --shortstat --pretty=format:"$pretty_format" "$@" $range
      ;;
    r|'raw')
      echo ">>> git log --raw --pretty=fuller $@ $range"
      git log --raw --pretty=fuller "$@" $range
      ;;
    p|'patch')
      echo ">>> git log --patch --stat --pretty=fuller $@ $range"
      git log --patch --stat --pretty=fuller "$@" $range
      ;;
    *)
      echo "无效输入：$c"
      ;;
  esac
}

# -------- 脚本入口 --------
# 检查是否在 Git 仓库中（非强制，仅为提示）
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo '警告：当前目录不是 Git 仓库，部分命令可能失败。'
    sleep 1
fi

main_menu
