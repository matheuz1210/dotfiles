zmodload zsh/zstat &>/dev/null && _HAS_ZSTAT=1

for stat format (
    mtime %Y
    size  %s
) {
    eval 'function '$stat' { for f ( $@ ) { if (( _HAS_ZSTAT )) { zstat +'$stat' $f } else { stat -c '$format' $f } } }'
}
