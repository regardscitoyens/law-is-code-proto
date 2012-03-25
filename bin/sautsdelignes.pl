#!/usr/bin/perl
# 
# Réorganise un wdiff pour conserver les numéros de ligne du premier document

$ol = '';
$suppr = 0;
$ajout = 0;
$cn = '';
while($l = <STDIN>) {
	chomp ($l);
	$cn .= "\n";
	if ($ol && $l =~ /^[^\{\[]+$/) {
                $ol .= " $l";
		$cn = '' unless ($suppr);
        }elsif ($l =~ /([\{\[])[\+\-][^\}\]]+$/) {
		$ol .= " $l ";
		if ($1 eq '[') {
			$suppr = 1;
			$ajout = 0;
		}elsif ($suppr) {
			chop($cn);
			print $ol.'+}'.$cn.'{+';
			$cn = $ol = '';
			$suppr = 0;
			$ajout = 1;
		}else{
			$suppr = 0 ;
			$ajout = 1 ;
			$cn = '';
		}
	}else{
		print $ol;
		print "\n" if ($ajout && $ol !~ /^[\d\s]*\{[^\}]+\}\s*$/);
		print " $l $cn";
		$ol = $cn = '';
		$ajout = $suppr = 0;
	}

}
print "$ol";
