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
	$id = $champs[3];

	while($l =~ s/(«[^»]+)«/\1/){}
	$l =~ s/<\/p><p>//g;

	if ($l =~ /alinéa (\d+)/i) {
		$alinea = $1;
	}

	@mots_modifs = (' <empty> ', ' <empty> ');$cpt = 0;
	while ($l =~ /«+ *([^»]+) *»+/g) {
	    $mots_modifs[$cpt++] = "$1";
	}
	
	$action = '';
	if ($l =~ /substituer|remplacer/i) {
		$action = 'remplace';
	}elsif ($l =~ /supprimer/i) {
		$action = 'supprime';
	}elsif ($l =~ /ajout[eé]|complét[eé]|insér[eé]|rédig[eé]/i) {
		$action = "ajout";
	}

	$mots_modifs[0] =~ s/\. ([A-Z][^\.])/\. ; $1/g;
	$m0 = $mots_modifs[0];
	$mots_modifs[1] =~ s/\. ([A-Z][^\.])/\. ; $1/g;
	$m1 = $mots_modifs[1];
	$idsuffix = 1000;
	foreach $m0 (split(';', $mots_modifs[0])) {
	    $m0 =~ s/[,\.;:\?\!='-]/ /g;
	    foreach $m1 (split(';', $mots_modifs[1])) {
		$m0 = '' if ($m0 eq ' <empty> ');
		$m1 = '' if ($m1 eq ' <empty> ');
		$m1 =~ s/[,\.;:\?\!='-]/ /g;
		print "$alinea\t$action\t$m0\t$m1\t$id$idsuffix\t$org\n";
		$idsuffix++;
	    }
	}
}
