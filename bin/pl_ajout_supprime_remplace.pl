#!/usr/bin/perl
#
# extrait chaque opération unitaire d'un wdiff et détecte si c'est au ajour un remplacement ou une suppression

use utf8;

while(<STDIN>) {
	$alinea = $1 if (/^(\d+)\t/);
	$action = '';
	while (/(([\{\[])[\+\-]([^\}\]]+)[\+\-]([\}\]]))/g) {
		$tout = $1;
		if ($2 eq '{') {
			$action = 'ajout';	
		}elsif ($4 eq '}') {
			$action = 'remplace';
		}else{
			$action = 'supprime';
		}
		$mots = $3;
		$mots =~ s/\|/ /g;
		$mots =~ s/[,\.;!?']/ /g;
		print "$alinea\t$action\t$mots\t$tout\n";
	}
}
