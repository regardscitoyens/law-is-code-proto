$alinea = 0;
$nbspan = 1;
print '<script type="text/javascript" src="http://code.jquery.com/jquery.js"></script>';
print "<div id='controleur' style='position:fixed; top: 0px; width: 100px;'></div>";
print "<div id='diff' style='margin-left: 100px; float:left; width:45%; height: 80%; overflow:auto;'>";
while (<STDIN>) {
    $alinea++;
    print "<p><span id=\"alinea$alinea\" class=\"alinea\">$alinea ~ </span>";
    s/^<p>//;
    while (s/ <span style/ <span class="diff" id="diff$nbspan" data-alinea="$alinea" data-diffid="$nbspan" style/) {
	$nbspan++;
    }
    print;
}
print "
</div>
<script>
selectedalinea = 0;
selecteddiff = 0;
\$('.diff').click(function() {
selectedalinea = \$(this).data('alinea');
selecteddiff = \$(this).data('diffid'); 
\$('#controleur').html('Alinea :'+selectedalinea+' Diff: '+selecteddiff);
window.location = '#aalinea'+selectedalinea;
});
</script>";
