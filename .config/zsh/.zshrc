# some parts of this file are adapted from https://github.com/ohmyzsh/ohmyzsh
setopt noclobber appendcreate interactivecomments globstarshort

# directory settings
setopt autocd autopushd pushdignoredups pushdminus
eval "$(zoxide init zsh)"

# history
setopt extendedhistory appendhistory histignore{dups,space} sharehistory histverify
HISTFILE=$XDG_CACHE_HOME/zsh_history
HISTSIZE=50000
SAVEHIST=10000

## Aliases
alias \
	dotfiles="git --git-dir ~/.config/dotfiles" \
	snp=snapper \
	cls=clear \
	_="doas " \
	fmp="ffmpeg -hide_banner" fpl="ffplay -hide_banner" fpr="ffprobe -hide_banner" \
	d="dirs -v" -="cd -" history="builtin fc -l 1"

alias \
	rm="rm -Iv" \
	md="mkdir -p" rd=rmdir \
	cp="cp -av" mv="mv -v" ln="ln -v" \
	chmod="chmod -v" chown="chown -v" \
	miniserve="miniserve -v" \
	rsync="rsync -hhhaP" \
	zst="zstdmt --rm --ultra -22 --long -v"

alias \
	grep="grep --color=auto --exclude-dir=.git" \
	diff="diff --color" \
	ip="ip --color=auto"

alias \
	ls="eza -G" \
	l="eza -balG" \
	ll="eza -bal"

function pac {
	case $1 in
		-Q*|-S[si]*|-F^(y)) pacman $@;;
		*) doas pacman $@;;
	esac
}

pat(){ bat -p $@ }
READNULLCMD=pat

## Colors
typeset -AHg FX FG BG
FX=(
  reset     "[00m"
  bold      "[01m" no-bold      "[22m"
  italic    "[03m" no-italic    "[23m"
  underline "[04m" no-underline "[24m"
  blink     "[05m" no-blink     "[25m"
  reverse   "[07m" no-reverse   "[27m"
)
for color ( {000..255} ) {
  FG[$color]="[38;5;${color}m"
  BG[$color]="[48;5;${color}m"
}
for n color (
    0 black   8 gray
    1 red     9 brightred
    2 green   10 brightgreen
    3 yellow  11 brightyellow
    4 blue    12 brightblue
    5 magenta 13 brightmagenta
    6 cyan    14 brightcyan
    7 white   15 brightwhite
) {
    FG[$color]="[38;5;${n}m"
    BG[$color]="[48;5;${n}m"
}

## Prompts
REPORTTIME=5
TIMEFMT="$BG[black]$FG[blue] ⌚$FX[reset] %*Es"

setopt promptsubst
prompt() {
  exit=$?
  if [[ $exit != 0 ]] { color=red } else { color=yellow }

  # color vars encased in %{...%} to prevent the cursor position being wrong
  echo -n "%{$FX[reset]%}"
  [[ $exit != 0 ]] && { echo "%{$BG[black]$FG[red]%} ⚠️%{$FX[reset]%} command exited with error code %?!" }
  echo "%{$FG[$color]%}╭───── %{$FX[reset]$FX[bold]$FG[brightblue]%}%n%{$FX[reset]%} at %{$FX[bold]$FG[brightyellow]%}%~%{$FX[reset]%}"
  echo "%{$FG[$color]%}╰─ %#%{$FX[reset]%} "
}
PS1='$(prompt)'


## Completion
setopt globdots
autoload -Uz compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' # case-insensitive
compinit -d $XDG_CACHE_HOME/zcompdump
compdef _pacman pac=pacman

## Key Bindings
bindkey $terminfo[khome] beginning-of-line     # Home
bindkey $terminfo[kend]  end-of-line           # End
bindkey $terminfo[kLFT5] backward-word         # Ctrl-Left
bindkey $terminfo[kRIT5] forward-word          # Ctrl-Right
bindkey $terminfo[kdch1] delete-char           # Delete
bindkey $terminfo[kcbt]  reverse-menu-complete # Shift-Tab
bindkey '^H'             backward-delete-word  # Ctrl-Backspace
bindkey '^[z'            undo                  # Alt-z

autoload -U edit-command-line
zle -N edit-command-line
bindkey '^[e'  edit-command-line              # Alt-e

# you need this for $terminfo to work for some reason
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )) {
  function zle-line-init { echoti smkx }
  function zle-line-finish { echoti rmkx }
  zle -N zle-line-init
  zle -N zle-line-finish
}

## Syntax Highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main cursor)

typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=red,bold'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=blue'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=blue'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument-unclosed]='fg=red'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument-unclosed]='fg=red'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=magenta,bold'


ZSH_HIGHLIGHT_STYLES[cursor]='standout'

. $ZDOTDIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
