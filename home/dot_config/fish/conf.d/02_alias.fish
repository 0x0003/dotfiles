alias cl="clear"
alias vi="nvim"
alias egrep="egrep --color"
alias we="wego | tail -n +2 && echo"
alias wef="wego -days 3 | tail -n +2"
alias weff="wego -days 5 | tail -n +2"
alias ql=qalc

# sesh
alias s="tmux-sesh.sh"
alias t="sesh connect . && tmux kill-pane"

# pass fzf
# the scripts are located in $HOME/.password-store/.extensions
alias pw="PASSWORD_STORE_ENABLE_EXTENSIONS=true pass fzf"
alias pwo="PASSWORD_STORE_ENABLE_EXTENSIONS=true pass fzf-otp"

# abbreviations
# NOTE: use C-Space to prevent expansion
# NOTE: if an abbreviation persist after being removed from
# this file, use `abbr --erase <name>`

# git
abbr -a -- gin  "git init"
abbr -a -- ginb "git init --bare"
abbr -a -- gcl  "git clone"
abbr -a -- gclb "git clone --bare"
abbr -a -- gcld "git clone --depth 1"
abbr -a -- gr   "git remote"
abbr -a -- grl  "git remote -v show"
abbr -a -- ga   "git add"
abbr -a -- gaa  "git add --all"
abbr -a -- gs   "git stash"
abbr -a -- gst  "git status"
abbr -a -- gd   "git diff"
abbr -a -- gcf  "git config --list"
abbr -a -- gb   "git branch"
abbr -a -- gbl  "git branch -a"
abbr -a -- gco  "git checkout"
abbr -a -- gcom "git checkout master"
abbr -a -- gc   "git commit"
abbr -a -- gca  "git commit --amend"
abbr -a -- gce  "git commit --allow-empty-message -m \"\""
abbr -a -- grs  "git reset"
abbr -a -- gm   "git merge"
abbr -a -- gl   "git pull"
abbr -a -- gp   "git push"
abbr -a -- gpf  "git push --force-with-lease"
abbr -a -- gw   "git worktree"
abbr -a -- gwl  "git worktree list"
abbr -a -- gwa  "git worktree add"
abbr -a -- gwr  "git worktree remove"

# nix
abbr -a -- nb   "nix build"
abbr -a -- nd   "nix develop"
abbr -a -- nr   "nix run"
abbr -a -- ns   "nix shell"
abbr -a -- nf   "nix flake"
abbr -a -- nfu  "nix flake update"
abbr -a -- nfi  "nix flake init --template"
abbr -a -- nfit "nix flake show templates"
abbr -a -- np   "nix profile"
abbr -a -- npl  "nix profile list"
abbr -a -- npi  "nix profile add"
abbr -a -- npr  "nix profile remove"
abbr -a -- nph  "nix profile history"
abbr -a -- nphr "nix profile wipe-history"
abbr -a -- npu  "nix profile upgrade"
abbr -a -- npua "nix profile upgrade --all"
abbr -a -- nre  "nix repl"
abbr -a -- nrg  "nix registry"
abbr -a -- nrgp "nix registry pin"
abbr -a -- nrgr "nix registry remove"
abbr -a -- nrgl "nix registry list"
abbr -a -- nrgs "nix registry list | grep '^user '"
abbr -a -- nse  "nix search"
abbr -a -- nst  "nix store"
abbr -a -- nsto "nix store optimise --debug"
abbr -a -- ngc  "nix store gc --debug"
abbr -a -- ndr  "nix-direnv-reload"
abbr -a -- hm   "home-manager"

# chezmoi
abbr -a -- cmin "chezmoi init"
abbr -a -- cmad "chezmoi add"
abbr -a -- cmed "chezmoi edit --watch"
abbr -a -- cmre "chezmoi re-add"
abbr -a -- cmdr "chezmoi apply --dry-run -v"
abbr -a -- cmst "chezmoi diff"
abbr -a -- cmap "chezmoi apply -v"
abbr -a -- cmfo "chezmoi forget"
abbr -a -- cmrm "chezmoi remove"

# tmux
abbr -a -- tn  "tmux new-session"
abbr -a -- tna "tmux new-session -s"
abbr -a -- ta  "tmux attach"
abbr -a -- tat "tmux attach -t"
abbr -a -- tl  "tmux list-sessions"

# zoxide
abbr -a -- zad  "ls -d */ | xargs -I {} zoxide add {}"
abbr -a -- zre  "zoxide remove"
abbr -a -- zrea "ls -d */ | xargs -I {} zoxide remove {} & zoxide remove (pwd)"

# todo
abbr -a -- tad "todo add"
abbr -a -- tli "todo list"
abbr -a -- tse "todo search"
abbr -a -- tde "todo delete"
abbr -a -- ted "todo edit"

# proxychains
abbr -a -- pch "proxychains4 -q"

# dnscrypt-proxy
abbr -a -- dnsr "dnscrypt-proxy.exe -resolve"

