#!/bin/bash

if ! test "$1"; then 
	echo "USAGE: $0 DOSSIER_DESC.CSV"
	echo "\t DOSSIER_DESC.CSV: CSV décrivant un ou plusieurs dossiers parlementaires générés via parse_dosser.pl (de NosSénateurs.pl)"
fi

cat $1 | while read line ; do 
  #Variables
  dossier=$(echo $line | awk -F ';' '{print $1"_"$2"_"$3}' | sed 's/-\([0-9]*\)-/\1/')
  etape=$(echo $line | sed 's/ //g' | awk -F ';' '{print $4"_"$6"_"$7"_"$8}')
  projectdir=$dossier"/"$etape
  url=$(echo $line | awk -F ';' '{print $9}')
  escape=$(perl -e 'use URI::Escape; print uri_escape shift();print"\n"' $url)

  mkdir  "data/$dossier" 2> /dev/null
  if test "$dossier" = "$olddossier"; then
      echo $line >>  "data/$dossier/procedure.csv"
  else
      echo $line >  "data/$dossier/procedure.csv"
  fi
  python bin/procedure2json.py "data/$dossier/procedure.csv" > "data/$dossier/procedure.json"
  olddossier=$dossier
  if echo $line | grep ';EXTRA;' > /dev/null ; then
	continue;
  fi
 
  #Text export
  curl -s $url | sed 's/iso-?8859-?1/UTF-8/i' > html/$escape;
  if file -i html/$escape | grep -i iso > /dev/null; then recode ISO88591..UTF8 html/$escape; fi
  python bin/parse_texte.py html/$escape $(echo $line | sed 's/ //g' | awk -F ';' '{print $4}') > json/$escape
  python bin/json2arbo.py json/$escape "$projectdir/texte"
  
  #Amendement export
  if test "$amdidtext"; then
  mkdir "data/$projectdir/amendements" 2> /dev/null
  cd "data/$projectdir/amendements"
  chambre=$(echo $line | awk -F ';' '{print $7}')
  urlchambre="http://www.nosdeputes.fr/14/amendements/"
  if test "$chambre" = "senat"; then
  	urlchambre="http://www.nossenateurs.fr/amendements/"
  fi
  curl -s $urlchambre"/"$amdidtext"/csv" > amendements.csv
  if grep [a-z] amendements.csv > /dev/null; then 
  	curl -s $urlchambre"/"$amdidtext"/json" > amendements.json
  	curl -s $urlchambre"/"$amdidtext"/xml" > amendements.xml
  	cd - > /dev/null
  else
  	rm amendements.csv
  	cd - > /dev/null
  	rmdir data/$projectdir/amendements
  fi
  fi
  
  #Intervention export
  
  #End
  amdidtext=$(echo $line | awk -F ';' '{print $10}')
  echo "INFO: data exported in data/$projectdir"
done 
