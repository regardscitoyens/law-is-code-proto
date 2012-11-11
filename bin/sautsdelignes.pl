#!/usr/bin/perl
# 
# Réorganise un wdiff pour conserver les numéros de ligne du premier document

sub cutSentence {
    $str = shift;
    $ret = "";
    while ($str =~ s/([^\[\{]*)([\[\{][\+\-])([^\]\}]+)([\+\-][\]\}])//) {
	$sepin = $2;
	$ret .= $1.$sepin;
	$sepout = $4;
	$milieu = $3;
	$milieu =~ s/\. +([A-Z][^\.])/; $1/g;
	$milieu =~ s/; /;$sepout $sepin$2/g;
	$ret .= $milieu.$sepout;
    }
    return $ret.$str;
}

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
#			print cutSentence($ol).'+}'.$cn.'{+';
#			$cn = $ol = '';
			$suppr = 0;
			$ajout = 1;
		}else{
			$suppr = 0 ;
			$ajout = 1 ;
			$cn = '';
		}
	}else{
		print cutSentence($ol);
		print "\n" if ($ajout && $ol !~ /^[\d\s]*\{[^\}]+\}\s*$/);
		print " ";
		print cutSentence($l);
		print " $cn";
		$ol = $cn = '';
		$ajout = $suppr = 0;
	}
}
print cutSentence($ol);
