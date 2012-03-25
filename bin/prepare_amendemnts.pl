#!/usr/bin/perl
#
# Extrait les informations utiles des amendements et devine quelle opération unitaire il réalise
#

while ($l = <STDIN>) {
	chomp($l);
	$org = $l;

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
	}
	if ($l =~ /supprimer/i) {
		$action = 'supprime';
	}
	if ($l =~ /ajouter|compléter|insérer|rédiger/i) {
		$action = "ajout";
	}

	$mots_modifs =~ s/[,\.;:\?\!='-]/ /g;
	print "$alinea\t$action\t$mots_modifs\t$org\n";
}
