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

printcolor() {
  echo -n "$FX[reset]$FG[$1]$2$FX[reset]"
}
