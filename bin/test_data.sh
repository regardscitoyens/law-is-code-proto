#!/bin/bash

perl bin/download_texte.pl http://www.assemblee-nationale.fr/13/projets/pl1210.asp
perl bin/download_texte.pl http://www.assemblee-nationale.fr/13/ta/ta0245.asp

mkdir -p json
python bin/parse_texte.py html/http%3A%2F%2Fwww.assemblee-nationale.fr%2F13%2Fprojets%2Fpl1210.asp > json/http%3A%2F%2Fwww.assemblee-nationale.fr%2F13%2Fprojets%2Fpl1210.asp
python bin/parse_texte.py html/http%3A%2F%2Fwww.assemblee-nationale.fr%2F13%2Fta%2Fta0245.asp  > json/http%3A%2F%2Fwww.assemblee-nationale.fr%2F13%2Fta%2Fta0245.asp
python bin/json2arbo.py json/http%3A%2F%2Fwww.assemblee-nationale.fr%2F13%2Fprojets%2Fpl1210.asp hopital
python bin/json2arbo.py json/http%3A%2F%2Fwww.assemblee-nationale.fr%2F13%2Fta%2Fta0245.asp hopital
tree data

