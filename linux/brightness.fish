function brightness --wraps='xrandr --output eDP-1 --brightness' --wraps='xrandr --output eDP1 --brightness' --wraps='xrandr --output DP-4 --brightness' --description 'alias dbd=xrandr --output DP-4 --brightness'
  xrandr --output DP-4 --brightness $argv
        
end
