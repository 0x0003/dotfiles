set -q GHCUP_INSTALL_BASE_PREFIX[1]; or set GHCUP_INSTALL_BASE_PREFIX $HOME ; set -gx PATH $HOME/.cabal/bin $HOME/.ghcup/bin $PATH # ghcup-env

# direnv setup
direnv hook fish | source

# zoxide setup
zoxide init fish | source

# fzf setup
fzfinit

# tmux autostart
#if status is-interactive
#and not set -q TMUX
#  tmux new-session -As 00
#end

