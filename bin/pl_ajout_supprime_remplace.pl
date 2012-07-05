#!/usr/bin/perl
#
# extrait chaque opération unitaire d'un wdiff et détecte si c'est au ajour un remplacement ou une suppression

use utf8;

while(<STDIN>) {
    chomp;
	$alinea = $1 if (/^(\d+)\t/);
	$action = '';
	while (/([^\]\}]*)(([\{\[])[\+\-]([^\}\]]+)[\+\-]([\}\]]))([^\[\{]*)/g) {
		$tout = $2;
		$contexte = "$1|$6";
		if ($3 eq '{') {
			$action = 'ajout';	
		}elsif ($5 eq '}') {
			$action = 'remplace';
		}else{
			$action = "supprime";
		}
		$mots = $4;
		$contexte =~ s/\d+\t//;
		$mots =~ s/\|/ /g;
		$mots =~ s/[,\.;!?']/ /g;
		print "$alinea\t$action\t$mots\t$tout\t$contexte\n";
	}
}
