#!/usr/bin/perl
#
# Extrait les informations utiles des amendements et devine quelle opération unitaire il réalise
#
use encoding "utf8";

while ($l = <STDIN>) {
	chomp($l);
	$l =~ s/,,/,"",/g;
	$org = $l;
	@champs = split(/","/, $l);
	$l = $champs[10];

	while($l =~ s/(«[^»]+)«/\1/){}
	$l =~ s/<\/p><p>//g;

	if ($l =~ /alinéa (\d+)/i) {
		$alinea = $1;
	}

	$mots_modifs = '';
	while ($l =~ /«+ *([^»]+) *»+/g) {
	    $mots_modifs .= "$1\t";
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
	print "$alinea\t$action\t$mots_modifs\t\t$org\n";
}
