zmodload zsh/mathfunc

for func ( log{,2,10} sqrt ) {
	eval 'function '$func' { if (( $+1 )) { n=$1 } else { read n }; echo $(( '$func'($n) )) }'
}
