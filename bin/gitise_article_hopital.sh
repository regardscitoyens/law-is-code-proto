rm -rf gitlaw.example/hopital 2> /dev/null
mkdir -p gitlaw.example/hopital
cd gitlaw.example/hopital
ln -s ../../.cache .
git init
mkdir -p article_1/texte
cp ../../example/article1_pl.txt article_1/texte/article_1.txt
export GIT_AUTHOR_NAME="Le gouvernement"
export GIT_COMMITER_NAME="Le gouvernement"
export GIT_AUTHOR_EMAIL="contact@gouv.fr"
export GIT_COMMITER_EMAIL="contact@gouv.fr"
export GIT_AUTHOR_DATE="Tue Oct 28 00:00:00 2008 +0200"
export GIT_COMMITER_DATE="Tue Oct 28 00:00:00 2008 +0200"
git add */texte/*.txt
git commit -m "Depot du texte" 
grep '"Article PREMIER"' ../../example/amendements_adoptés_avecsous.csv | sed 's/,,/,"",/g' | sort -t, -k 11 > ../../tmp/amendements_adoptés.sorted.csv
mkdir -p article_1/amendements/deposes article_1/amendements/adoptes
mkdir -p .cache/photos .cache/csv

OLDDATE=1900-01-01
cat ../../tmp/amendements_adoptés.sorted.csv | while read line; do
	DEPUTES=$(echo $line | cut -d '"' -f 22)
	DATE=$(echo $line | cut -d '"' -f 20 )
	if test "$DATE" = "$OLDDATE" ; then
	    HEURE=$(printf "%02d" $(expr $HEURE + 1))
	else
	    HEURE=00
	fi
	if test $HEURE -gt 23; then
	    HEURE=24;
	fi
	OLDDATE=$DATE
	export GIT_AUTHOR_DATE=$(date --date="$DATE $HEURE:00:00 +0200" -R)
	echo $GIT_COMMITER_DATE;
	echo $DEPUTES | sed 's/,/\n/g' | sed 's/\.//g' | sed 's/ /%20/g' | while read depute; do
		git branch "$depute";
	done
	echo $DEPUTES | sed 's/,/\n/g' | sed 's/\.//g' | sed 's/ /%20/g' | while read depute; do
	        CSV=.cache/csv/$depute
		if ! test -e $CSV; then
		    curl -s -L http://2007-2012.nosdeputes.fr/$depute/csv > $CSV
		    if grep -i '<html' $CSV > /dev/null 2>&1; then
			echo -n > $CSV
		    fi
		fi
		export GIT_AUTHOR_NAME=$(echo $depute | sed 's/%20/ /g')
		export GIT_AUTHOR_EMAIL=$depute"@nosdeputes.fr"
		if test -s $CSV ; then 
		    export GIT_AUTHOR_NAME=$(cat $CSV | tail -n 1 | cut -d ';' -f 2)
		    if ! test -e ".cache/photos/$GIT_AUTHOR_NAME.png" ; then
			PHOTO=$(tail -n 1 $CSV | sed 's/.*;http/http/' | sed 's|/csv.*||' | sed 's|fr/|fr/depute/photo/|')/160
			curl -s $PHOTO > ".cache/photos/$GIT_AUTHOR_NAME.png"
		    fi
		    export GIT_AUTHOR_EMAIL=$(cat $CSV | tail -n 1 | cut -d ';' -f 20 | sed 's/assemblee-nationale.fr.*/assemblee-nationale.fr/' | sed 's/.*|//')
		fi
		export GIT_COMMITER_NAME=$GIT_AUTHOR_NAME
		export GIT_COMMITER_EMAIL=$GIT_AUTHOR_EMAIL
		export GIT_COMMITER_DATE=$GIT_AUTHOR_DATE
		git checkout "$depute"
		IDA=$(echo $line | cut -d '"' -f 10)
		IDSUR=$(echo $line | cut -d '"' -f 12)
		DIR=article_1/amendements/deposes/$IDSUR/$IDA
		mkdir -p $DIR
		echo $line | cut -d '"' -f 24 | sed 's/<p>//gi' | sed 's|</p>|\n|gi' > $DIR/$IDA.amendement
		git add $DIR/$IDA.amendement
		EXPLICATION=$(echo $line | cut -d '"' -f 26 | sed 's/<p>//gi' | sed 's|</p>| |gi')
		git commit -m "$EXPLICATION"
		git checkout master
	done
        echo $DEPUTES | sed 's/,/\n/g' | sed 's/\.//g' | sed 's/ /%20/g' | while read depute; do
                git merge "$depute";
		git branch -d "$depute";
        done

done

DATE=2009-02-12
HEURE=15:00
export GIT_AUTHOR_NAME="Jean-Marie Rolland"
export GIT_AUTHOR_EMAIL=jmrolland@assemblee-nationale.fr
export GIT_AUTHOR_DATE=$(date --date="$DATE $HEURE:00 +0200" -R)
export GIT_COMMITER_NAME=$GIT_AUTHOR_NAME
export GIT_COMMITER_EMAIL=$GIT_AUTHOR_EMAIL
export GIT_COMMITER_DATE=$GIT_AUTHOR_DATE
git mv article_1/amendements/deposes/263 article_1/amendements/adoptes
cat  article_1/texte/article_1.txt | sed "7,7s|L'article L. 6111-2 du même code est abrogé.||" > /tmp/article_1.txt
mv /tmp/article_1.txt article_1/texte/article_1.txt
git add article_1/texte/article_1.txt
git commit -m "Amendement 263 est adopté"

HEURE=15:15
export GIT_AUTHOR_NAM="Catherine Génisson"
export GIT_AUTHOR_EMAIL=
export GIT_AUTHOR_DATE=$(date --date="$DATE $HEURE:00 +0200" -R)
export GIT_COMMITER_NAME=$GIT_AUTHOR_NAME
export GIT_COMMITER_EMAIL=$GIT_AUTHOR_EMAIL
export GIT_COMMITER_DATE=$GIT_AUTHOR_DATE
git mv article_1/amendements/deposes/1093 article_1/amendements/adoptes
git mv article_1/amendements/deposes/264 article_1/amendements/adoptes
cat  article_1/texte/article_1.txt | sed "9,9s|Les articles L. 6112-1, L. 6112-2 et L. 6112-3 du même code sont *remplacés par les dispositions suivantes :|Les articles L. 6112-1, L. 6112-2 et L. 6112-3 du même code sont ainsi rédigés :|" > /tmp/article_1.txt
mv /tmp/article_1.txt article_1/texte/article_1.txt
git add article_1/texte/article_1.txt
git commit -m "Amendements 1093 et 264 sont adoptés"

HEURE=15:30
export GIT_AUTHOR_NAME="Jean-Marie Rolland"
export GIT_AUTHOR_EMAIL=jmrolland@assemblee-nationale.fr
export GIT_AUTHOR_DATE=$(date --date="$DATE $HEURE:00 +0200" -R)
export GIT_COMMITER_NAME=$GIT_AUTHOR_NAME
export GIT_COMMITER_EMAIL=$GIT_AUTHOR_EMAIL
export GIT_COMMITER_DATE=$GIT_AUTHOR_DATE
git mv article_1/amendements/deposes/1094 article_1/amendements/adoptes
git mv article_1/amendements/deposes/265 article_1/amendements/adoptes
git mv article_1/amendements/deposes/859 article_1/amendements/adoptes
cat  article_1/texte/article_1.txt | sed "24,24s|Art. L. 6112-2. – Les missions de service public définies à l'article L. 6112-1 peuvent être assurées, en tout ou *partie :|Art. L. 6112-2. – Les missions de service public définies à l'article L. 6112-1 peuvent être assurées, en tout ou partie, en fonction des besoins de la population appréciés dans le schéma régional d'organisation des soins :|" > /tmp/article_1.txt
mv /tmp/article_1.txt article_1/texte/article_1.txt
git add article_1/texte/article_1.txt
git commit -m "Amendements 1094, 265 et 859 sont adoptés"

HEURE=01
HEURE=15:45
export GIT_AUTHOR_NAME="Jean-Marie Rolland"
export GIT_AUTHOR_EMAIL=jmrolland@assemblee-nationale.fr
export GIT_AUTHOR_DATE=$(date --date="$DATE $HEURE:00 +0200" -R)
export GIT_COMMITER_NAME=$GIT_AUTHOR_NAME
export GIT_COMMITER_EMAIL=$GIT_AUTHOR_EMAIL
export GIT_COMMITER_DATE=$GIT_AUTHOR_DATE
git mv article_1/amendements/deposes/268 article_1/amendements/adoptes
cat  article_1/texte/article_1.txt | sed "44,44s|L'autorisation peut être suspendue ou retirée dans les conditions prévues *au I de l'article L. 6122-13 si|L'autorisation peut être suspendue ou retirée dans les conditions prévues à l'article L. 6122-13 si|" > /tmp/article_1.txt
mv /tmp/article_1.txt article_1/texte/article_1.txt
git add article_1/texte/article_1.txt
git commit -m "Amendement 268 est adopté"

HEURE=16:00
export GIT_AUTHOR_NAME="Jean-Marie Rolland"
export GIT_AUTHOR_EMAIL=jmrolland@assemblee-nationale.fr
export GIT_AUTHOR_DATE=$(date --date="$DATE $HEURE:00 +0200" -R)
export GIT_COMMITER_NAME=$GIT_AUTHOR_NAME
export GIT_COMMITER_EMAIL=$GIT_AUTHOR_EMAIL
export GIT_COMMITER_DATE=$GIT_AUTHOR_DATE
git mv article_1/amendements/deposes/269 article_1/amendements/adoptes
cat  article_1/texte/article_1.txt | sed "44,44s| *la condition ainsi| l'une des conditions ainsi|" | sed "44,44s| *mise à son octroi n'est pas réalisée.| mises à son octroi n'est pas réalisée.|" > /tmp/article_1.txt
mv /tmp/article_1.txt article_1/texte/article_1.txt
git add article_1/texte/article_1.txt
git commit -m "Amendement 269 est adopté"

HEURE=16:15
export GIT_AUTHOR_NAME="Yves Bur"
export GIT_AUTHOR_EMAIL=ybur@assemblee-nationale.fr
export GIT_AUTHOR_DATE=$(date --date="$DATE $HEURE:00 +0200" -R)
export GIT_COMMITER_NAME=$GIT_AUTHOR_NAME
export GIT_COMMITER_EMAIL=$GIT_AUTHOR_EMAIL
export GIT_COMMITER_DATE=$GIT_AUTHOR_DATE
git mv article_1/amendements/deposes/830 article_1/amendements/adoptes
cat  article_1/texte/article_1.txt | sed "47,47s| rupture. *| rupture qui ne peut être mise à la charge de l'établissement ou du praticien. |" > /tmp/article_1.txt
mv /tmp/article_1.txt article_1/texte/article_1.txt
git add article_1/texte/article_1.txt
git commit -m "Amendement 830 est adopté"

HEURE=16:30
export GIT_AUTHOR_NAME="Jean-Marie Rolland"
export GIT_AUTHOR_EMAIL=jmrolland@assemblee-nationale.fr
export GIT_AUTHOR_DATE=$(date --date="$DATE $HEURE:00 +0200" -R)
export GIT_COMMITER_NAME=$GIT_AUTHOR_NAME
export GIT_COMMITER_EMAIL=$GIT_AUTHOR_EMAIL
export GIT_COMMITER_DATE=$GIT_AUTHOR_DATE
git mv article_1/amendements/deposes/270 article_1/amendements/adoptes
cat  article_1/texte/article_1.txt | sed "47,47s|Le cas échéant, les contrats mentionnés à l'article L. 4113-9 sont révisés dans un délai de six mois à compter de la signature *du contrat mentionné *au dernier alinéa de l'article L. 6112-2 qui assujettit l'établissement de santé ou l'une des personnes mentionnées au même article à des obligations de service public. Le refus par le praticien de réviser son contrat en constitue un motif de|Le cas échéant, les contrats mentionnés à l'article L. 4113-9 sont révisés dans un délai de six mois à compter de la signature d'un des contrats mentionnés au dernier alinéa de l'article L. 6112-2 qui assujettit l'établissement de santé ou l'une des personnes mentionnées au même article à des obligations de service public. Le refus par le praticien de réviser son contrat en constitue un motif de|" > /tmp/article_1.txt
mv /tmp/article_1.txt article_1/texte/article_1.txt
git add article_1/texte/article_1.txt
git commit -m "Amendement 270 est adopté"

HEURE=16:45
export GIT_AUTHOR_NAME="Jean-Luc Préel"
export GIT_AUTHOR_EMAIL=jlpreel@assemblee-nationale.fr
export GIT_AUTHOR_DATE=$(date --date="$DATE $HEURE:00 +0200" -R)
export GIT_COMMITER_NAME=$GIT_AUTHOR_NAME
export GIT_COMMITER_EMAIL=$GIT_AUTHOR_EMAIL
export GIT_COMMITER_DATE=$GIT_AUTHOR_DATE
git mv article_1/amendements/deposes/865 article_1/amendements/adoptes
cat  article_1/texte/article_1.txt | sed "47,47s| *rupture. Le premier alinéa *| rupture qui ne peut être mise à la charge de l'établissement ou du praticien. |" | sed "48,48s| *6162-1 du même code est remplacé par| 6114-1, à garantir, pour certaines disciplines ou spécialités et dans une limite fixée par|" | sed "48,48s| *les dispositions suivantes : Les centres de| décret, une proportion minimale d'actes facturés sans dépassement d'honoraires, en dehors de|"| sed "48,48s| *lutte contre le cancer sont des| ceux délivrés aux bénéficiaires du droit à la protection complémentaire en matière de santé et des|" | sed "48,48s| *établissements de santé| situations d'urgence. L'établissement de santé|" | sed "48,48s| *qui exercent leurs missions dans le| ou le|" | sed "48,48s| *domaine de| titulaire de|" | sed "48,48s| *la cancérologie. *| l'autorisation modifie le cas échéant les contrats conclus pour l'exercice d'une profession médicale mentionnés aux premier et deuxième alinéas de l'article L. 4113-9. Le refus par le praticien de réviser son contrat en constitue un motif de rupture sans faute.|" > /tmp/article_1.txt
mv /tmp/article_1.txt article_1/texte/article_1.txt
git add article_1/texte/article_1.txt
git commit -m "Amendement 865 est adopté"

HEURE=17:00
export GIT_AUTHOR_NAME="Jean-Marie Rolland"
export GIT_AUTHOR_EMAIL=jmrolland@assemblee-nationale.fr
export GIT_AUTHOR_DATE=$(date --date="$DATE $HEURE:00 +0200" -R)
export GIT_COMMITER_NAME=$GIT_AUTHOR_NAME
export GIT_COMMITER_EMAIL=$GIT_AUTHOR_EMAIL
export GIT_COMMITER_DATE=$GIT_AUTHOR_DATE
git mv article_1/amendements/deposes/271 article_1/amendements/adoptes
git mv article_1/amendements/deposes/1099 article_1/amendements/adoptes
cat  article_1/texte/article_1.txt | sed "51,51s| *aux tarifs fixés par l'autorité administrative compétente.| privés d'intérêt collectif : 1° Les centres de lutte contre le cancer ; 2° Jusqu'à la signature de leur prochain contrat pluriannuel d'objectifs et de moyens, les établissements de santé privés gérés par des organismes sans but lucratif qui en font la déclaration à l'agence régionale de santé. Les obligations à l'égard des patients prévues aux 1° et 2° de l'article L. 6112-3 sont applicables aux établissements de santé privés d'intérêt collectif pour l'ensemble de leurs missions. Les établissements de santé privés d'intérêt collectif appliquent aux assurés sociaux les tarifs prévus aux articles L. 162-20 et L. 162-26 du code de la sécurité sociale, sans préjudice des articles L. 6146-2 et L. 6154-1 du présent code. Le premier alinéa de l'article L. 6162-1 du même code est ainsi rédigé : Les centres de lutte contre le cancer sont des établissements de santé qui exercent leurs missions dans le domaine de la cancérologie. L'article L. 162-20 du code de la sécurité sociale est ainsi rédigé : Art. L. 162-20. – Les assurés sociaux sont hospitalisés dans les établissements publics de santé aux tarifs fixés par l'autorité administrative compétente.|" > /tmp/article_1.txt
mv /tmp/article_1.txt article_1/texte/article_1.txt
git add article_1/texte/article_1.txt
git commit -m "Amendements 271 et 1099 sont adoptés"

HEURE=17:15
export GIT_AUTHOR_NAME="Marc Le Fur"
export GIT_AUTHOR_EMAIL=mlefur@assemblee-nationale.fr
export GIT_AUTHOR_DATE=$(date --date="$DATE $HEURE:00 +0200" -R)
export GIT_COMMITER_NAME=$GIT_AUTHOR_NAME
export GIT_COMMITER_EMAIL=$GIT_AUTHOR_EMAIL
export GIT_COMMITER_DATE=$GIT_AUTHOR_DATE
git mv article_1/amendements/deposes/272 article_1/amendements/adoptes
git mv article_1/amendements/deposes/201 article_1/amendements/adoptes
cat  article_1/texte/article_1.txt | sed "67,67s|Les articles L. 6161-3-1, L. *6161-5, L. * 6161-6, L. 6161-7, L. 6161-8, L. 6161-9 et L. 6161-10 du même code sont abrogés.|Les articles L. 6161-3-1, L. 6161-6, L. 6161-7, L. 6161-8, L. 6161-9 et L. 6161-10 du même code sont abrogés.|" > /tmp/article_1.txt
mv /tmp/article_1.txt article_1/texte/article_1.txt
git add article_1/texte/article_1.txt
git commit -m "Amendements 272 et 201 sont adoptés"

HEURE=17:30
export GIT_AUTHOR_NAME="Catherine Génisson"
export GIT_AUTHOR_EMAIL=cgenisson@assemblee-nationale.fr
export GIT_AUTHOR_DATE=$(date --date="$DATE $HEURE:00 +0200" -R)
export GIT_COMMITER_NAME=$GIT_AUTHOR_NAME
export GIT_COMMITER_EMAIL=$GIT_AUTHOR_EMAIL
export GIT_COMMITER_DATE=$GIT_AUTHOR_DATE
git mv article_1/amendements/deposes/1102 article_1/amendements/adoptes
git mv article_1/amendements/deposes/274 article_1/amendements/adoptes
cat  article_1/texte/article_1.txt | sed "68,68s| *d'objectif * et de moyens jusqu'au terme de ce contrat| d'objectifs et de moyens jusqu'au terme de ce contrat|" > /tmp/article_1.txt
mv /tmp/article_1.txt article_1/texte/article_1.txt
git add article_1/texte/article_1.txt
git commit -m "Amendements 1002 et 274 sont adoptés"

HEURE=17:45
export GIT_AUTHOR_NAME="Jean-Marie Rolland"
export GIT_AUTHOR_EMAIL=jmrolland@assemblee-nationale.fr
export GIT_AUTHOR_DATE=$(date --date="$DATE $HEURE:00 +0200" -R)
export GIT_COMMITER_NAME=$GIT_AUTHOR_NAME
export GIT_COMMITER_EMAIL=$GIT_AUTHOR_EMAIL
export GIT_COMMITER_DATE=$GIT_AUTHOR_DATE
git mv article_1/amendements/deposes/1103 article_1/amendements/adoptes
git mv article_1/amendements/deposes/275 article_1/amendements/adoptes
cat  article_1/texte/article_1.txt | sed "68,68s| *2004. *| 2004 (n° 2003-1199 du 18 décembre 2003). Ils deviennent des établissements de santé privés d'intérêt collectif sauf opposition expresse de leur part notifiée par leur représentant légal au directeur général de l'agence régionale de santé, par lettre recommandée avec demande d'accusé de réception. |" > /tmp/article_1.txt
mv /tmp/article_1.txt article_1/texte/article_1.txt
git add article_1/texte/article_1.txt
git commit -m "Amendements 275 et 1103 sont adoptés"

HEURE=18:00
export GIT_AUTHOR_NAME="Jean-Marie Rolland"
export GIT_AUTHOR_EMAIL=jmrolland@assemblee-nationale.fr
export GIT_AUTHOR_DATE=$(date --date="$DATE $HEURE:00 +0200" -R)
export GIT_COMMITER_NAME=$GIT_AUTHOR_NAME
export GIT_COMMITER_EMAIL=$GIT_AUTHOR_EMAIL
export GIT_COMMITER_DATE=$GIT_AUTHOR_DATE
git mv article_1/amendements/deposes/273 article_1/amendements/adoptes
cat  article_1/texte/article_1.txt | sed "68,68s|Les établissements de santé privés qui ont été admis à participer à l'exécution du service public hospitalier à la date de publication de la présente loi continuent d'exercer, dans les mêmes conditions, les missions pour lesquelles ils y ont été admis ou celles prévues *à * leur contrat pluriannuel|Les établissements de santé privés qui ont été admis à participer à l'exécution du service public hospitalier à la date de publication de la présente loi continuent d'exercer, dans les mêmes conditions, les missions pour lesquelles ils y ont été admis ou celles prévues par leur contrat pluriannuel|" > /tmp/article_1.txt
mv /tmp/article_1.txt article_1/texte/article_1.txt
git add article_1/texte/article_1.txt
git commit -m "Amendement 273 est adopté"

HEURE=18:15
export GIT_AUTHOR_NAME="Jean-Marie Rolland"
export GIT_AUTHOR_EMAIL=jmrolland@assemblee-nationale.fr
export GIT_AUTHOR_DATE=$(date --date="$DATE $HEURE:00 +0200" -R)
export GIT_COMMITER_NAME=$GIT_AUTHOR_NAME
export GIT_COMMITER_EMAIL=$GIT_AUTHOR_EMAIL
export GIT_COMMITER_DATE=$GIT_AUTHOR_DATE
git mv article_1/amendements/deposes/276 article_1/amendements/adoptes
cat  article_1/texte/article_1.txt | sed "69,69s|Jusqu'à la date *choisie * en application|Jusqu'à la date retenue en application|" > /tmp/article_1.txt
mv /tmp/article_1.txt article_1/texte/article_1.txt
git add article_1/texte/article_1.txt
git commit -m "Amendement 276 est adopté"

HEURE=18:30
export GIT_AUTHOR_NAME="Jean-Marie Rolland"
export GIT_AUTHOR_EMAIL=jmrolland@assemblee-nationale.fr
export GIT_AUTHOR_DATE=$(date --date="$DATE $HEURE:00 +0200" -R)
export GIT_COMMITER_NAME=$GIT_AUTHOR_NAME
export GIT_COMMITER_EMAIL=$GIT_AUTHOR_EMAIL
export GIT_COMMITER_DATE=$GIT_AUTHOR_DATE
git mv article_1/amendements/deposes/1176 article_1/amendements/adoptes
cat  article_1/texte/article_1.txt | sed "70,70s| *de l'article L. 6161-3-1 * et du dernier alinéa de l'article L. 6161-7 du code de la santé publique, dans| du XVIII bis du présent article et du dernier alinéa de l'article L. 6161-7 du code de la santé publique, dans|" | sed "70,70s| *leur * rédaction antérieure à la présente loi, leur| sa rédaction antérieure à la présente loi, leur|" | sed "70,70s| *restent * applicables.| sont applicables.|" > /tmp/article_1.txt
mv /tmp/article_1.txt article_1/texte/article_1.txt
git add article_1/texte/article_1.txt
git commit -m "Amendement 1176 est adopté"

HEURE=18:45
export GIT_AUTHOR_NAME="Jean-Marie Rolland"
export GIT_AUTHOR_EMAIL=jmrolland@assemblee-nationale.fr
export GIT_AUTHOR_DATE=$(date --date="$DATE $HEURE:00 +0200" -R)
export GIT_COMMITER_NAME=$GIT_AUTHOR_NAME
export GIT_COMMITER_EMAIL=$GIT_AUTHOR_EMAIL
export GIT_COMMITER_DATE=$GIT_AUTHOR_DATE
git mv article_1/amendements/deposes/277 article_1/amendements/adoptes
cat  article_1/texte/article_1.txt | sed "70,70s|Jusqu'à la date *choisie * en application du premier alinéa du|Jusqu'à la date retenue en application du premier alinéa du|" > /tmp/article_1.txt
mv /tmp/article_1.txt article_1/texte/article_1.txt
git add article_1/texte/article_1.txt
git commit -m "Amendement 277 est adopté"

HEURE=19:00
export GIT_AUTHOR_NAME="Jean-Marie Rolland"
export GIT_AUTHOR_EMAIL=jmrolland@assemblee-nationale.fr
export GIT_AUTHOR_DATE=$(date --date="$DATE $HEURE:00 +0200" -R)
export GIT_COMMITER_NAME=$GIT_AUTHOR_NAME
export GIT_COMMITER_EMAIL=$GIT_AUTHOR_EMAIL
export GIT_COMMITER_DATE=$GIT_AUTHOR_DATE
git mv article_1/amendements/deposes/278 article_1/amendements/adoptes
cat  article_1/texte/article_1.txt | sed "71,71s| *d'objectif * et de moyens jusqu'au terme de ce contrat ou, au plus tard, jusqu'à la date mentionnée au VII de l'article 33 de la loi| d'objectifs et de moyens jusqu'au terme de ce contrat ou, au plus tard, jusqu'à la date mentionnée au VII de l'article 33 de la loi|" > /tmp/article_1.txt
mv /tmp/article_1.txt article_1/texte/article_1.txt
git add article_1/texte/article_1.txt
git commit -m "Amendement 278 est adopté"

HEURE=19:15
export GIT_AUTHOR_NAME="Jean-Marie Rolland"
export GIT_AUTHOR_EMAIL=jmrolland@assemblee-nationale.fr
export GIT_AUTHOR_DATE=$(date --date="$DATE $HEURE:00 +0200" -R)
export GIT_COMMITER_NAME=$GIT_AUTHOR_NAME
export GIT_COMMITER_EMAIL=$GIT_AUTHOR_EMAIL
export GIT_COMMITER_DATE=$GIT_AUTHOR_DATE
git mv article_1/amendements/deposes/279 article_1/amendements/adoptes
cat  article_1/texte/article_1.txt | sed "72,72s|Jusqu'à la date *choisie * en application|Jusqu'à la date retenue en application|" > /tmp/article_1.txt
mv /tmp/article_1.txt article_1/texte/article_1.txt
git add article_1/texte/article_1.txt
git commit -m "Amendement 279 est adopté"

HEURE=19:30
export GIT_AUTHOR_NAME="Jean-Marie Rolland"
export GIT_AUTHOR_EMAIL=jmrolland@assemblee-nationale.fr
export GIT_AUTHOR_DATE=$(date --date="$DATE $HEURE:00 +0200" -R)
export GIT_COMMITER_NAME=$GIT_AUTHOR_NAME
export GIT_COMMITER_EMAIL=$GIT_AUTHOR_EMAIL
export GIT_COMMITER_DATE=$GIT_AUTHOR_DATE
git mv article_1/amendements/deposes/280 article_1/amendements/adoptes
cat  article_1/texte/article_1.txt | sed "73,73s|Jusqu'à la date *choisie * en application du premier alinéa du|Jusqu'à la date retenue en application du premier alinéa du|" > /tmp/article_1.txt
mv /tmp/article_1.txt article_1/texte/article_1.txt
git add article_1/texte/article_1.txt
git commit -m "Amendement 280 est adopté"

HEURE=19:45
export GIT_AUTHOR_NAME="Yves Bur"
export GIT_AUTHOR_EMAIL=ybur@assemblee-nationale.fr
export GIT_AUTHOR_DATE=$(date --date="$DATE $HEURE:00 +0200" -R)
export GIT_COMMITER_NAME=$GIT_AUTHOR_NAME
export GIT_COMMITER_EMAIL=$GIT_AUTHOR_EMAIL
export GIT_COMMITER_DATE=$GIT_AUTHOR_DATE
git mv article_1/amendements/deposes/1177 article_1/amendements/adoptes
git mv article_1/amendements/deposes/1085 article_1/amendements/adoptes
cat  article_1/texte/article_1.txt | sed "73,73s| * XVII, les| présent XVII, les|" | sed "73,73s| *dispositions de l'article L. 6161-3-1 du code de la santé publique, dans sa rédaction antérieure * à| deuxième à|" | sed "73,73s| *la présente loi, * leur| sixième alinéas du XVIII bis leur|" | sed "73,73s| *restent * applicables.| sont applicables.|" > /tmp/article_1.txt
mv /tmp/article_1.txt article_1/texte/article_1.txt
git add article_1/texte/article_1.txt
git commit -m "Amendements 1177 et 1085 sont adoptés"

HEURE=20:00
export GIT_AUTHOR_NAME="Jean-Marie Rolland"
export GIT_AUTHOR_EMAIL=jmrolland@assemblee-nationale.fr
export GIT_AUTHOR_DATE=$(date --date="$DATE $HEURE:00 +0200" -R)
export GIT_COMMITER_NAME=$GIT_AUTHOR_NAME
export GIT_COMMITER_EMAIL=$GIT_AUTHOR_EMAIL
export GIT_COMMITER_DATE=$GIT_AUTHOR_DATE
git mv article_1/amendements/deposes/281 article_1/amendements/adoptes
cat  article_1/texte/article_1.txt | sed "74,74s|Les centres de lutte contre le cancer mentionnés à l'article L. 6162-1 du code de la santé publique continuent d'exercer, dans les mêmes conditions, outre les missions qui leur sont assignées par la loi, les missions prévues à leur contrat pluriannuel *d'objectif * et de moyens jusqu'au terme de ce contrat ou, au plus tard, jusqu'à la date mentionnée au VII de l'article 33 de la loi|Les centres de lutte contre le cancer mentionnés à l'article L. 6162-1 du code de la santé publique continuent d'exercer, dans les mêmes conditions, outre les missions qui leur sont assignées par la loi, les missions prévues à leur contrat pluriannuel d'objectifs et de moyens jusqu'au terme de ce contrat ou, au plus tard, jusqu'à la date mentionnée au VII de l'article 33 de la loi|" > /tmp/article_1.txt
mv /tmp/article_1.txt article_1/texte/article_1.txt
git add article_1/texte/article_1.txt
git commit -m "Amendement 281 est adopté"

HEURE=20:15
export GIT_AUTHOR_NAME="Jean-Marie Rolland"
export GIT_AUTHOR_EMAIL=jmrolland@assemblee-nationale.fr
export GIT_AUTHOR_DATE=$(date --date="$DATE $HEURE:00 +0200" -R)
export GIT_COMMITER_NAME=$GIT_AUTHOR_NAME
export GIT_COMMITER_EMAIL=$GIT_AUTHOR_EMAIL
export GIT_COMMITER_DATE=$GIT_AUTHOR_DATE
git mv article_1/amendements/deposes/282 article_1/amendements/adoptes
cat  article_1/texte/article_1.txt | sed "75,75s|Jusqu'à la date *choisie * en application|Jusqu'à la date retenue en application|" > /tmp/article_1.txt
mv /tmp/article_1.txt article_1/texte/article_1.txt
git add article_1/texte/article_1.txt
git commit -m "Amendement 282 est adopté"

HEURE=20:30
export GIT_AUTHOR_NAME="Yves Bur"
export GIT_AUTHOR_EMAIL=ybur@assemblee-nationale.fr
export GIT_AUTHOR_DATE=$(date --date="$DATE $HEURE:00 +0200" -R)
export GIT_COMMITER_NAME=$GIT_AUTHOR_NAME
export GIT_COMMITER_EMAIL=$GIT_AUTHOR_EMAIL
export GIT_COMMITER_DATE=$GIT_AUTHOR_DATE
git mv article_1/amendements/deposes/1180 article_1/amendements/adoptes
git mv article_1/amendements/deposes/1088 article_1/amendements/adoptes
cat  article_1/texte/article_1.txt | sed "77,77s| *restent * applicables.| reste applicable. Les deuxième à sixième alinéas du XVIII bis du présent article leur sont applicables.|" > /tmp/article_1.txt
mv /tmp/article_1.txt article_1/texte/article_1.txt
git add article_1/texte/article_1.txt
git commit -m "Amendements 1088 et 1180 sont adoptés"

HEURE=20:45
export GIT_AUTHOR_NAME="Jean-Marie Rolland"
export GIT_AUTHOR_EMAIL=jmrolland@assemblee-nationale.fr
export GIT_AUTHOR_DATE=$(date --date="$DATE $HEURE:00 +0200" -R)
export GIT_COMMITER_NAME=$GIT_AUTHOR_NAME
export GIT_COMMITER_EMAIL=$GIT_AUTHOR_EMAIL
export GIT_COMMITER_DATE=$GIT_AUTHOR_DATE
git mv article_1/amendements/deposes/1175 article_1/amendements/adoptes
git mv article_1/amendements/deposes/1084 article_1/amendements/adoptes
cat  article_1/texte/article_1.txt | sed "77,79s| *Les contrats de concession pour l'exécution du service public hospitalier conclus en application de l'article L. 6161-9 du code de la santé publique, dans sa rédaction antérieure à la présente loi, ne sont pas renouvelés. Ils prennent fin au plus tard à la date mentionnée au VII de l'article 33 de la loi| Jusqu'à la date retenue en application du premier alinéa du XVI, les dispositions suivantes sont applicables aux établissements de santé privés qui ont été admis à participer à l'exécution du service public hospitalier à la date de publication de la présente loi : Lorsque le directeur général de l'agence régionale de santé estime que la situation financière de l'établissement l'exige et, à tout le moins, lorsque le suivi et l'analyse de l'exécution de l'état des prévisions de recettes et de dépenses prévus à l'article L. 6145-1 du code de la santé publique ou le compte financier font apparaître un déséquilibre financier répondant à des critères définis par décret, ou lorsque sont constatés des dys-fonctionnements dans la gestion de l'établissement, le directeur général de l'agence régionale de santé adresse à la personne morale gestionnaire une injonction de remédier au déséquilibre financier ou aux dys-fonctionnements constatés et de produire un plan de redressement adapté, dans un délai qu'il fixe. Ce délai doit être raisonnable et adapté à l'objectif recherché. Les modalités de retour à l'équilibre financier donnent lieu à la signature d'un avenant au contrat pluriannuel d'objectifs et de moyens prévu à l'article L. 6114-1 du même code. S'il n'est pas satisfait à l'injonction, ou en cas de refus de l'établissement de signer l'avenant susmentionné, le directeur général de l'agence régionale de santé peut désigner un administrateur provisoire de l'établissement pour une durée qui ne peut être supérieure à six mois renouvelable une fois. Si l'organisme gestionnaire gère également des établissements ou services qui relèvent de la compétence tarifaire du représentant de l'État ou du président du conseil général, l'administrateur provisoire est désigné conjointement par le représentant de l'État dans le département et le directeur général de l'agence régionale de santé. L'administrateur doit satisfaire aux conditions définies aux deuxième à quatrième alinéas de l'article L. 811-2 du code de commerce. L'administrateur provisoire accomplit, pour le compte de l'établissement, les actes d'administration urgents ou nécessaires pour mettre fin aux dysfonctionnements ou irrégularités constatés et préparer et mettre en oeuvre un plan de redressement. La rémunération de l'administrateur est assurée par les établissements gérés par l'organisme et répartie entre les établissements ou services au prorata des charges d'exploitation de chacun d'eux. L'administrateur justifie, pour ses missions, d'une assurance couvrant les conséquences financières de la responsabilité conformément aux dispositions de l'article L. 814-5 du code de commerce, prise en charge dans les mêmes conditions que la rémunération. En cas d'échec de l'administration provisoire, le directeur général de l'agence régionale de santé peut saisir le commissaire aux comptes pour la mise en oeuvre de l'article L. 612-3 du même code. Les contrats de concession pour l'exécution du service public hospitalier conclus en application de l'article L. 6161-9 du code de la santé publique, dans sa rédaction antérieure à la présente loi, ne sont pas renouvelés. Ils prennent fin au plus tard à la date mentionnée au VII de l'article 33 de la loi|" > /tmp/article_1.txt
mv /tmp/article_1.txt article_1/texte/article_1.txt
git add article_1/texte/article_1.txt
git commit -m "Amendements 1175 et 1084 sont adoptés"

HEURE=21:00
export GIT_AUTHOR_NAME="Yves Bur"
export GIT_AUTHOR_EMAIL=ybur@assemblee-nationale.fr
export GIT_AUTHOR_DATE=$(date --date="$DATE $HEURE:00 +0200" -R)
export GIT_COMMITER_NAME=$GIT_AUTHOR_NAME
export GIT_COMMITER_EMAIL=$GIT_AUTHOR_EMAIL
export GIT_COMMITER_DATE=$GIT_AUTHOR_DATE
git mv article_1/amendements/deposes/1087 article_1/amendements/adoptes
git mv article_1/amendements/deposes/1179 article_1/amendements/adoptes
cat  article_1/texte/article_1.txt | sed "77,77s| *leur * rédaction antérieure à la présente loi, leur| sa rédaction antérieure à la présente loi, leur|" > /tmp/article_1.txt
mv /tmp/article_1.txt article_1/texte/article_1.txt
git add article_1/texte/article_1.txt
git commit -m "Amendements 1179 et 1087 sont adoptés"

HEURE=21:15
export GIT_AUTHOR_NAME="Jean-Marie Rolland"
export GIT_AUTHOR_EMAIL=jmrolland@assemblee-nationale.fr
export GIT_AUTHOR_DATE=$(date --date="$DATE $HEURE:00 +0200" -R)
export GIT_COMMITER_NAME=$GIT_AUTHOR_NAME
export GIT_COMMITER_EMAIL=$GIT_AUTHOR_EMAIL
export GIT_COMMITER_DATE=$GIT_AUTHOR_DATE
git mv article_1/amendements/deposes/1086 article_1/amendements/adoptes
git mv article_1/amendements/deposes/1178 article_1/amendements/adoptes
cat  article_1/texte/article_1.txt | sed "77,77s| *les dispositions des articles L. 6161-3-1 et du * dernier alinéa de l'article L. 6161-7 du code de la santé publique, dans| le dernier alinéa de l'article L. 6161-7 du code de la santé publique, dans|" > /tmp/article_1.txt
mv /tmp/article_1.txt article_1/texte/article_1.txt
git add article_1/texte/article_1.txt
git commit -m "Amendement 1086 et 1178 sont adoptés"

export GIT_AUTHOR_NAME="La séance"
export GIT_AUTHOR_EMAIL=laseance@assemblee-nationale.fr
export GIT_AUTHOR_DATE=$(date --date="2009-03-18 15:00:00 +0200" -R)
export GIT_COMMITER_NAME=$GIT_AUTHOR_NAME
export GIT_COMMITER_EMAIL=$GIT_AUTHOR_EMAIL
export GIT_COMMITER_DATE=$GIT_AUTHOR_DATE
cp ../../example/article1_anfin1lecture.txt article_1/texte/article_1.txt
git add article_1/texte/article_1.txt
git commit -m "Mise en forme"