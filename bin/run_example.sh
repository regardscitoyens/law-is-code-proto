#!/bin/bash
#
#Tourne les script sur l'article 1 du PL Hopital
mkdir -p tmp
bash bin/compare_textes.sh example/article1_pl.txt example/article1_anfin1lecture.txt > tmp/article1.wdiff
cat example/article1_amendements_adoptés_avecsous.csv | perl bin/prepare_amendemnts.pl | sort -n > tmp/amendements_adoptés.comparables.csv
perl bin/htmlelize_amendements.pl <  tmp/amendements_adoptés.comparables.csv >> tmp/article1.wdiff.html
#perl bin/compare_diffs_amendements.pl bin/compare_diff_amendements.pl tmp/amendements_adoptés.comparables.csv < tmp/article1.wdiff | sh > tmp/compare_diffs_amendements.log
perl bin/compare_wdiffs_amendements.pl tmp/article1.wdiff tmp/amendements_adoptés.comparables.csv 76 example/correspondance_amendements_wdiff.csv example/coef.csv