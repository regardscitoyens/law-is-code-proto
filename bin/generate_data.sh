#!/bin/bash

if ! test "$1"; then 
	echo "USAGE: $0 DOSSIER_DESC.CSV"
	echo "\t DOSSIER_DESC.CSV: CSV décrivant un ou plusieurs dossiers parlementaires générés via parse_dosser.pl (de NosSénateurs.pl)"
fi
oldchambre=""
cat $1 | while read line ; do 
  #Variables
  dossier=$(echo $line | awk -F ';' '{print $1"_"$2"_"$3}' | sed 's/-\([0-9]*\)-/\1/')
  dossier_instit=$(echo $line | awk -F ';' '{print $2}')
  etape=$(echo $line | sed 's/ //g' | awk -F ';' '{print $4"_"$6"_"$7"_"$8}')
  projectdir=$dossier"/"$etape
  order=$(echo $line | awk -F ';' '{print $4}')
  url=$(echo $line | awk -F ';' '{print $9}')
  escape=$(perl -e 'use URI::Escape; print uri_escape shift();print"\n"' $url)
  chambre=$(echo $line | awk -F ';' '{print $7}')
  
  mkdir -p "data/$dossier"
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
  python bin/parse_texte.py html/$escape $order > json/$escape
  python bin/json2arbo.py json/$escape "$projectdir/texte"
  
  if test "$amdidtext" && test "$oldchambre" = "$chambre"; then
    urlchambre="http://www.nosdeputes.fr/14"
    if test "$chambre" = "senat"; then
    	urlchambre="http://www.nossenateurs.fr"
    fi
    is_commission=''
    if echo $etape | grep commission > /dev/null; then
      is_commission='?commission=1'
    fi

    #Amendements export
    mkdir -p "data/$projectdir/amendements"
    cd "data/$projectdir/amendements"
    curl -s "$urlchambre/amendements/$amdidtext/csv" > amendements.csv
    if grep [a-z] amendements.csv > /dev/null; then 
    	curl -s "$urlchambre/amendements/$amdidtext/json" > amendements.json
    	curl -s "$urlchambre/amendements/$amdidtext/xml" > amendements.xml
    	cd - > /dev/null
    else
    	rm amendements.csv
    	cd - > /dev/null
    	rmdir data/$projectdir/amendements
    fi

    #Interventions export
    inter_dir="data/$projectdir/interventions"
    curl -s "$urlchambre/seances/$amdidtext/csv$is_commission" | grep "[0-9]" | sed 's/;//g' | while read id_seance; do
      if curl -sI "$urlchambre/seance/$id_seance/$dossier_instit/csv" | head -n 1 | grep -v 404 > /dev/null; then
        mkdir -p $inter_dir
        curl -s "$urlchambre/seance/$id_seance/$dossier_instit/csv" > $inter_dir/$id_seance.csv
        curl -s "$urlchambre/seance/$id_seance/json" > $inter_dir/$id_seance.json
        curl -s "$urlchambre/seance/$id_seance/xml" > $inter_dir/$id_seance.xml
      fi
    done

  fi

  #End
  amdidtext=$(echo $line | awk -F ';' '{print $10}')
  oldchambre=$chambre
  echo "INFO: data exported in data/$projectdir"
done 
