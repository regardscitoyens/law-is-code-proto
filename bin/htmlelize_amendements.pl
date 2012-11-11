print "<div id='amendements' style='width: 45%;float: right; height: 80%; overflow:auto;'><h2>Amendements</h2>";
$lastalinea = 0;
while ($l = <STDIN>) {
    @diff = split /\t/, $l;
    $l =~ s/.*\t"//;
    @amd = split /","/, $l;
    $id = $diff[4];
    print "<div class='amendement' id='amendement$id'>";
    print "<a name='aalinea".$diff[0]."'></a>";
    for ($a = $lastalinea ; $a < $diff[0]; $a++) {
	print "<a name='aalinea$a'></a>";
    }
    print "<h3>Amendement $id</h3>";
    print "<p><a href='#alinea$diff[0]'>alinea $diff[0]</a>, $diff[1] :</p>";
    print "<p>«$diff[2]»</p>";
    print "<p>«$diff[3]»</p>" if ($diff[3]);
    print "<input class='associateit' type='submit' value='associate' data-amendementid='$id'/>";
    print "</div>";
    
}
print "</div>";
print "<script>\$('.associateit').click(function(){selectedamdmt = \$(this).data('amendementid'); \$('#associated').val(\$('#associated').val()+selecteddiff+';'+selectedamdmt+'\\n'); \$('#amendement'+selectedamdmt).css('color', 'orange'); \$('#diff'+selecteddiff).css('color', 'orange');\});</script>";
print "<div style='clear: both'><textarea id='associated'></textarea></div>";
