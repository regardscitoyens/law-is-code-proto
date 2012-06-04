#!/usr/bin/perl
#
# Extrait les informations utiles des amendements et devine quelle opération unitaire il réalise
#

while ($l = <STDIN>) {
	chomp($l);
	$org = $l;
	$l =~ s/,,/,"",/g;
	@champs = split(/","/, $l);
	$l = $champs[10];

	if ($l =~ /alinéa (\d+)/i) {
		$alinea = $1;
	}

	$mots_modifs = '';
	while ($l =~ /«([^»<]+)[»<]/) {
		if ($l =~ s/«([^»<]+)[»<]//) {
			$mots_modifs .= " $1 ";
		}
	}
	
	$action = '';
	if ($l =~ /substituer|remplacer/i) {
		$action = 'remplace';
	}elsif ($l =~ /supprimer/i) {
		$action = 'supprime';
	}elsif ($l =~ /ajout[eé]|complét[eé]|insér[eé]|rédig[eé]/i) {
		$action = "ajout";
	}

	$mots_modifs =~ s/[,\.;:\?\!='-]/ /g;
	print "$alinea\t$action\t$mots_modifs\t$org\n";
}
