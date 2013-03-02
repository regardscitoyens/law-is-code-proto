#!/bin/bash
# List in order all versions of a text in a file named "NOM_DOSSIER.list"
# Then run "bash bin/parse_dossier_textes.sh DOSSIER_NAME"

source /usr/local/bin/virtualenvwrapper.sh
workon gitlaw
DOSSIER=$1

if [ -z $DOSSIER ]; then
  echo "please speify a project name matching a NAME.list file listing all text urls for the project"
  exit
fi

mkdir -p json
rm -rf data/$DOSSIER
ct=0
for url in `grep -v "^#" $DOSSIER.list`; do
  ct=$(($ct + 1))
  echo "$ct : $url"
  file=`perl bin/download_texte.pl $url`
  echo " --> $file"
  python bin/parse_texte.py "html/$file" $ct > json/$DOSSIER-$ct-$file.json
  python bin/json2arbo.py json/$DOSSIER-$ct-$file.json $DOSSIER
done

for i in `seq $ct`; do
  i=`printf "%02d\n" $i`
  for path in `ls data/$DOSSIER/*/$i*.json | sed 's/\.json$//'`; do
    cat $path.json >> data/$DOSSIER/$i.json
    echo >> data/$DOSSIER/$i.json
    cat $path.alineas >> data/$DOSSIER/$i.alineas
    echo >> data/$DOSSIER/$i.alineas
  done
done

tree data/$DOSSIER

deactivate
