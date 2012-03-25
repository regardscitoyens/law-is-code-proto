#!/bin/bash

wdiff $1 $2   | 
	perl bin/sautsdelignes.pl | 
	sed 's/\-\] {+/\|/g' | 
        awk '{print FNR "\t" $0}' |
	perl bin/pl_ajout_supprime_remplace.pl |
	cat
