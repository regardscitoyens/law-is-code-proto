#!/bin/bash

if ! test "$1"; then 
	echo "USAGE: $0 DOSSIER_DESC.CSV"
	echo "\t DOSSIER_DESC.CSV: CSV décrivant un ou plusieurs dossiers parlementaires générés via parse_dosser.pl (de NosSénateurs.pl)"
fi

cat $1 | while read line ; do 
dossier=$(echo $line | awk -F ';' '{print $1"_"$2}')
etape=$(echo $line | sed 's/ //g' | awk -F ';' '{print $3*1"_"$5"_"$4"_"$6}' | sed 's/^\([0-9]\)_/0\1_/' | sed 's/_$/_depot/')
projectdir=$dossier"/"$etape
url=$(echo $line | awk -F ';' '{print $7}')
escape=$(perl -e 'use URI::Escape; print uri_escape shift();print"\n"' $url)
curl -s $url | sed 's/iso-?8859-?1/UTF-8/i' > html/$escape;
if file -i html/$escape | grep -i iso > /dev/null; then recode ISO88591..UTF8 html/$escape; fi
python bin/parse_texte.py html/$escape > json/$escape
python bin/json2arbo.py json/$escape $projectdir
echo "INFO: data exported in data/$projectdir"
done 
