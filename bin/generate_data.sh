#!/bin/bash

if ! test "$1"; then 
	echo "USAGE: $0 DOSSIER_DESC.CSV"
	echo "\t DOSSIER_DESC.CSV: CSV décrivant un ou plusieurs dossiers parlementaires générés via parse_dosser.pl (de NosSénateurs.pl)"
fi

cat $1 | while read line ; do 
  dossier=$(echo $line | awk -F ';' '{print $1"_"$2"_"$3}')
  etape=$(echo $line | sed 's/ //g' | awk -F ';' '{print $4"_"$7"_"$6"_"$8}' | sed 's/_$/_depot/')
  projectdir=$dossier"/"$etape
  url=$(echo $line | awk -F ';' '{print $9}')
  escape=$(perl -e 'use URI::Escape; print uri_escape shift();print"\n"' $url)
  curl -s $url | sed 's/iso-?8859-?1/UTF-8/i' > html/$escape;
  if file -i html/$escape | grep -i iso > /dev/null; then recode ISO88591..UTF8 html/$escape; fi
  python bin/parse_texte.py html/$escape $(echo $line | sed 's/ //g' | awk -F ';' '{print $4}') > json/$escape
  python bin/json2arbo.py json/$escape "$projectdir/texte"
  echo "INFO: data exported in data/$projectdir"
done 
