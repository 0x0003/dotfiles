function ff
  set -l result (rg --column . | fzf --delimiter : --preview="cat {1}")
  echo $result
  cd (dirname (echo $result | cut -d ':' -f 1))
end

