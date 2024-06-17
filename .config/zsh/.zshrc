# some parts of this file are adapted from https://github.com/ohmyzsh/ohmyzsh
setopt noclobber appendcreate interactivecomments globstarshort extendedglob

# directory settings
setopt autocd autopushd pushdignoredups pushdminus
eval "$(zoxide init zsh)"

# history
setopt extendedhistory appendhistory histignore{dups,space} sharehistory histverify
HISTFILE=$XDG_CACHE_HOME/zsh_history
HISTSIZE=500000
SAVEHIST=100000

nohist() {
	HISTFILE=/dev/null
}

## Aliases
alias \
	dotfiles="git --git-dir ~/.config/dotfiles --work-tree ~" \
	snp=snapper \
	cls=clear \
	_="doas " \
	fmp="ffmpeg -hide_banner" fpl="ffplay -hide_banner" fpr="ffprobe -hide_banner" \
	d="dirs -v" -="cd -" history="builtin fc -l 1"

alias \
	rm="rm -Iv" \
	md="mkdir -p" rd=rmdir \
	cp="cp -av" mv="mv -v" ln="ln -v" \
	chmod="chmod -c" chown="chown -c" \
	miniserve="miniserve -v" \
	rsync="rsync -hhhHXPAa" \
	zst="zstdmt --rm --ultra -22 --long -v"

alias \
	grep="grep --color=auto --exclude-dir=.git" \
	diff="diff --color" \
	ip="ip --color=auto"

alias \
	ls="eza -G" \
	l="eza -balG" \
	ll="eza -bal"

function tar {
  local TAR
  if (( $+commands[bsdtar] ))
    then TAR==bsdtar
    else TAR==tar
  fi

  if [[ $1 == -* ]] {
    $TAR -p $@
  } else {
    $TAR p$@
  }
}
functions -c tar bsdtar

function pac {
	case $1 in
		-Q*|-S[si]*|-F^(y)) pacman $@;;
		*) doas pacman $@;;
	esac
}

pat(){ bat -p $@ }
READNULLCMD=pat

for util ( stat math color ) {
	source $ZDOTDIR/utils/$util.zsh
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

# set tmux pane title to last command
if (( $+TMUX )) {
	typeset -ga preexec_functions precmd_functions
	_tmux_clear_pane() { printf '\033]2;zsh\007' }
	_tmux_rename_pane() { printf '\033]2;%s\007' $2 }
	preexec_functions+=_tmux_rename_pane
	precmd_functions+=_tmux_clear_pane
}

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
source ${PREFIX:-/usr}/share/fzf/key-bindings.zsh

# you need this for $terminfo to work for some reason
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )) {
  function zle-line-init { echoti smkx }
  function zle-line-finish { echoti rmkx }
  zle -N zle-line-init
  zle -N zle-line-finish
}

WORDCHARS=${WORDCHARS/\/}
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
