# toggle proxy in current and consecutive shell sessions
function prx
  set -l prx_state $HOME/.cache/fish/prx_state
  if set -q http_proxy
    rm -f $prx_state
    set -e -g http_proxy
    set -e -g https_proxy
    set -e -g HTTP_PROXY
    set -e -g HTTPS_PROXY
    set -e -g all_proxy
    set -e -g SSH_PROXY
    echo "OFF"
  else
    mkdir -p (dirname $prx_state)
    touch $prx_state
    set -gx http_proxy $PROXYADDRESS
    set -gx https_proxy $PROXYADDRESS
    set -gx HTTP_PROXY $PROXYADDRESS
    set -gx HTTPS_PROXY $PROXYADDRESS
    set -gx all_proxy $PROXYADDRESS
    set -l prx_uri (string replace 'http://' '' -- $PROXYADDRESS)
    set -gx SSH_PROXY $prx_uri
    echo "ON @ $PROXYADDRESS"
  end
end

