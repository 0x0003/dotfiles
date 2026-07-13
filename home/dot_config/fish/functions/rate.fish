function rate
  if not string length --quiet $argv
    echo "Usage: `rate <number>`"
    return 1
  end
  if test $argv -gt 5
    set RATING 10
  else
    set RATING (math "$argv * 2")
  end
  mpc sticker (mpc current --format '%file%') set rating $RATING
end

