if (( ! $+TMUX )) {
	(( $+SSH_TTY )) && exec tmux -u new -A
	(( ! $+DISPLAY && ! $+WAYLAND_DISPLAY && $XDG_VTNR == 1 )) && XDG_SESSION_TYPE=wayland exec startplasma-wayland
}
