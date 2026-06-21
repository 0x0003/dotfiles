set -x PATH ~/scripts ~/scripts/wsl $PATH

export EDITOR='nvim'

# bc - math lib, quiet, bcrc file
export BC_ENV_ARGS="-lq $HOME/.config/bc/calc"

# IME
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export DefaultIMModule=fcitx
export SDL_IM_MODULE=fcitx

# explicitly indicate truecolor support
export COLORTERM='truecolor'

# rg config
export RIPGREP_CONFIG_PATH="$HOME/.config/rg/rg.conf"

# ncurses programs by default have 100ms delay when pressing escape
export ESCDELAY=0

# proxy (see `ip route | grep default` for WSL host IP)
export PROXYADDRESS=http://(ip route | awk '/default/ {print $3}'):2080
# export PROXYADDRESS=socks5://192.168.x.x:2080
# export PROXYADDRESS=http://192.168.x.x:2080
# export PROXYADDRESS=http://127.0.0.1:2080

if test -f $HOME/.cache/fish/prx_state
  set -x http_proxy $PROXYADDRESS
  set -x https_proxy $PROXYADDRESS
  set -x HTTP_PROXY $PROXYADDRESS
  set -x HTTPS_PROXY $PROXYADDRESS
  set -x all_proxy $PROXYADDRESS
end

