[[ $SSH_TTY && ! $TMUX ]] && exec tmux -u new -A
[[ -z $DISPLAY && $XDG_VTNR = 1 ]] && XDG_SESSION_TYPE=wayland exec startplasma-wayland
