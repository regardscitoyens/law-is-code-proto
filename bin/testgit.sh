mkdir -p /tmp/gitlaw
cd /tmp/gitlaw
git init
mkdir article_{1,2,3,4,5}
for a in article*; do mkdir $a/texte $a/amendments $a/interventions; done
for i in 1 2 3 4 5; do echo "Modifier le code blablabl" > article_$i/texte/article_$i.txt; done
for a in article*; do for i in 1 2 3 4 5; do echo "blabla" > $a/amendements/amendement_$i.txt; done; done
for a in article*; do for i in 1 2 3 4 5; do echo "blabla" > $a/amendments/amendement_$i.txt; done; done
for a in article*; do echo "blablabl" > $a/interventions/interventions.txt ; done
touch -t "1201010000" */texte/*.txt
export GIT_AUTHOR_NAME="Le gouvernement"
export GIT_COMMITER_NAME="Le gouvernement"
export GIT_AUTHOR_EMAIL="contact@gouv.fr"
export GIT_COMMITER_EMAIL="contact@gouv.fr"
export GIT_AUTHOR_DATE="Sun Jan 1 00:00:00 2012 +0200"
export GIT_COMMITER_DATE="Sun Jan 1 00:00:00 2012 +0200"
git add */texte/*.txt
git commit -m "Depot du texte" 
export GIT_AUTHOR_NAME="François Brottes"
export GIT_COMMITER_NAME="François Brottes"
export GIT_AUTHOR_EMAIL="fbrottes@assemblee-nationale.fr"
export GIT_COMMITER_EMAIL="fbrottes@assemblee-nationale.fr"
export GIT_COMMITER_DATE="Mon Jan 2 09:00:00 2012 +0200"
export GIT_AUTHOR_DATE="Mon Jan 2 09:00:00 2012 +0200"
touch -t "1201020900" article_1/amendments/amendement_1.txt
git add article_1/amendments/amendement_1.txt
git commit -m "Amendement 1 visant à blablabla" 
git branch brottes 
git branch bloche
git checkout  brottes
touch -t "1201020900" article_1/amendments/amendement_2.txt
git add article_1/amendments/amendement_2.txt
cp article_1/amendments/amendement_2.txt /tmp/
git commit -m "Amendement 2 visant à blablabla"
git branch 
git checkout bloche 
cp /tmp/amendement_2.txt article_1/amendments/amendement_2.txt
touch -t "1201020900" article_1/amendments/amendement_2.txt
export GIT_AUTHOR_EMAIL="pbloche@assemblee-nationale.fr"
export GIT_COMMITER_EMAIL="pbloche@assemblee-nationale.fr"
export GIT_COMMITER_NAME="Patrick Bloche"
export GIT_AUTHOR_NAME="Patrick Bloche"
git add article_1/amendments/amendement_2.txt
git commit -m "Amendement 2 visant à blablabla"
git checkout master 
git merge brottes 
git merge bloche 
git log --pretty=format:user:%aN%n%at --reverse --raw --encoding=UTF-8 --no-renames > git.log
unset GIT_AUTHOR_DATE     GIT_AUTHOR_EMAIL    GIT_AUTHOR_NAME     GIT_COMMITER_DATE   GIT_COMMITER_EMAIL  GIT_COMMITER_NAME
