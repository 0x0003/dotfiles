function ffo
  rg --column . | fzf  --delimiter : --preview="cat {1}"\
  --bind "enter:become(nvim -c \"call cursor ({2},0)\" {1})"
end

