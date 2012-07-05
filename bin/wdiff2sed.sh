while read line; do
#    echo "DEBUG $line"
    LINE=$(echo $line | sed "s/^\([0-9]*\) [^0-9].*$/\1/");
    ACTION=$(echo $line | sed 's/^[0-9]* //' | sed 's/ .*//');
    CHANGEMENT=""
    CHANGEMENT=$(echo $line | sed 's/.*[\[\{][-+]//' | sed 's/+}.*//' | sed 's/-\].*//');
    CONTEXTE=""
    CONTEXTE=$(echo $line | sed 's/.*}\s*//' | sed 's/.*\]\s*//')
    PRECONTEXTE=""
    PRECONTEXTE=$(echo $CONTEXTE | sed 's/|.*//');
    POSTCONTEXTE=""
    POSTCONTEXTE=$(echo $CONTEXTE | sed 's/.*|//');
    SEDEXP=""
    if test $ACTION = "supprime" ; then
	SEDEXP="$LINE,"$LINE"s|$PRECONTEXTE \*$CHANGEMENT \*$POSTCONTEXTE|$PRECONTEXTE $POSTCONTEXTE|"; 
    else if test $ACTION = "remplace" ; then
	PRECHANGEMENT=$(echo $CHANGEMENT | sed 's/|.*//');
	POSTCHANGEMENT=$(echo $CHANGEMENT | sed 's/.*|//');
	SEDEXP="$LINE,"$LINE"s|$PRECONTEXTE \*$PRECHANGEMENT \*$POSTCONTEXTE|$PRECONTEXTE $POSTCHANGEMENT $POSTCONTEXTE|";
    else if test $ACTION = "ajout"; then
	SEDEXP="$LINE,"$LINE"s|$PRECONTEXTE \*$POSTCONTEXTE|$PRECONTEXTE $CHANGEMENT $POSTCONTEXTE|";
    fi; fi; fi
    echo $SEDEXP;
#    cat $1 | sed "$SEDEXP" > /tmp/diff.res
#    if diff $1 /tmp/diff.res > /dev/null; then
#	echo "ERROR sur $line ($SEDEXP)"
#    fi
done
