function rate
  function sticker -S
    if test "$argv[1]" = set
      set RATING_NEW $argv[2]
      mpc sticker $FILE set rating $RATING_NEW
    else
      set RATING_NEW 0
      mpc sticker $FILE delete rating
    end
  end

  set -l FILE (mpc current --format '%file%')
  set -l RATING_OLD (mpc sticker $FILE get rating 2>/dev/null | string match -r '\d+$')
  set -l STATE (test -n "$RATING_OLD" && echo (math "$RATING_OLD / 2") || echo 0)

  if test "$argv" = s -o "$argv" = l -o "$argv" = ls -o "$argv" = show -o "$argv" = list
    set_color magenta && echo -n (mpc current)
    echo
    set_color green && echo -n $STATE
    set_color normal && echo " stars"
    functions -e sticker
    return
  end

  if not string length --quiet $argv
    if test -n "$RATING_OLD" -a "$RATING_OLD" -gt 0
      sticker delete
    else
      sticker set 10
    end
  else if test "$argv" -eq 0
    sticker delete
  else if test "$argv" -gt 5
    sticker set 10
  else
    sticker set (math "$argv * 2")
  end

  functions -e sticker

  set_color magenta && echo -n (mpc current)
  echo
  set_color red && echo -n $STATE
  set_color normal && echo -n " -> "
  set_color green && echo -n (math "$RATING_NEW / 2")
  set_color normal && echo " stars"
end

