# toggle proxy in current and consecutive shell sessions
function prx
  set -l prx_state $HOME/.cache/fish/prx_state
  if test -f $prx_state
    rm $prx_state
    set -e -g http_proxy
    set -e -g https_proxy
    set -e -g HTTP_PROXY
    set -e -g HTTPS_PROXY
    set -e -g all_proxy
    echo "OFF"
  else
    mkdir -p (dirname $prx_state)
    touch $prx_state
    set -gx http_proxy $PROXYADDRESS
    set -gx https_proxy $PROXYADDRESS
    set -gx HTTP_PROXY $PROXYADDRESS
    set -gx HTTPS_PROXY $PROXYADDRESS
    set -gx all_proxy $PROXYADDRESS
    echo "ON @ $PROXYADDRESS"
  end
end

