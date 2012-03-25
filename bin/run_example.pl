#!/bin/bash
#
#Tourne les script sur l'article 1 du PL Hopital
mkdir -p tmp
bash bin/compare_textes.sh example/article1_pl.txt example/article1_anfin1lecture.txt > tmp/article1.wdiff
perl bin/prepare_amendemnts.pl < example/amendements_adoptés.csv > tmp/amendements_adoptés.comparables.csv
perl bin/compare_diffs_amendements.pl bin/compare_diff_amendements.pl tmp/amendements_adoptés.comparables.csv < tmp/article1.wdiff | sh > tmp/compare_diffs_amendements.log
