# NOTE: git-related functions are slow in remote filesystems
function in_git_repo
  git rev-parse --is-inside-worktree > /dev/null 2>&1
end

function parse_git_branch
  set_color blue
  echo -n (git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ \1 /')
end

function parse_git_dirty
  set -l dirt (git status -s 2>&1)
  if not string length --quiet $dirt
    return
  else if test "x$dirt" = "xfatal: this operation must be run in a work tree"
    set_color brred
    echo -n "󱐚 "
  else
    set_color red
    echo -n "× "
  end
end

function in_direnv
  if test -z $DIRENV_DIR
    return
  else
    set_color green
    echo -n "."
  end
end

function in_nixshell
  if echo $PATH | grep -qc '/nix/store'
    set_color blue
    echo -n "󱄅."
  else
    return
  end
end

function fish_prompt
  set -l _last_status $status
  echo -n " "
  # BUG: returns false in bare repos as expected,
  #      but still executes
  if in_git_repo
    parse_git_dirty
    parse_git_branch
  end
  # pwd
  set_color white
  echo -n (prompt_pwd --dir-length=10)" "
  # exit status
  if test $_last_status -ne 0
    set_color red
    echo -n "[$_last_status] "
  end
  in_direnv
  in_nixshell
  set_color yellow
  echo -n "λ. "
  set_color $fish_color_command
end

function fish_right_prompt
  # tput sc; tput cuu1; tput cuf 2
  if test "$http_proxy" = "$PROXYADDRESS"
    set_color bryellow
    echo '`'
    set_color $fish_color_command
  end
  if test -e "/run/systemd/system/nix-daemon.service.d/override.conf"
    set_color brblue
    echo '`'
    set_color $fish_color_command
  end
  # tput rc
end

