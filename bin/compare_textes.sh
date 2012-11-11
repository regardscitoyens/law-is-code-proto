#!/bin/bash

wdiff $1 $2   | 
	perl bin/sautsdelignes.pl | 
	sed 's/\-\] {+/\|/g' > tmp/article1.wdiff.orig
cat tmp/article1.wdiff.orig | sed 's/\[-/<span style="color:red">/g' | sed 's/|/<\/span><span style="color:green">/g' | sed 's/{+/<span style="color:green">/g' | sed 's/-\]/<\/span>/g' | sed 's/+\}/<\/span>/g' | sed 's/^/<p>/' | sed 's/$/<\/p>/' | perl bin/htmlelize_wdiff.pl > tmp/article1.wdiff.html
cat tmp/article1.wdiff.orig |
        awk '{print FNR "\t" $0}' |
	perl bin/pl_ajout_supprime_remplace.pl |
	cat
