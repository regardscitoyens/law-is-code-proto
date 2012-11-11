#!/usr/bin/perl
#
# extrait chaque opération unitaire d'un wdiff et détecte si c'est au ajour un remplacement ou une suppression

use utf8;
$id = 1;
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
		$mots0 = $mots; $mots1 = '';
		if ($mots =~ s/(.*)\|(.*)/\t/g) {
		    $mots0 = $1;
		    $mots1 = $2;
		}
		$mots0 =~ s/[,\.;!?']/ /g;
		$mots1 =~ s/[,\.;!?']/ /g;
		print "$alinea\t$action\t$mots0\t$mots1\t$id\t$tout\t$contexte\n";
		$id++;
	}
}
