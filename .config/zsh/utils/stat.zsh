zmodload zsh/zstat &>/dev/null && _HAS_ZSTAT=1

for stat format (
    mtime %Y
    size  %s
) {
    eval 'function '$stat' { if (( _HAS_ZSTAT )) { zstat +'$stat' $1 } else { stat -c '$format' $1 } }'
}
