#!/bin/bash

#
#   Diese Datei gibt eine Reihe von 24-Bit-Farbwerten
#   im Terminal aus, um dessen Funktionalität zu testen.
#   Die Escape-Sequenz für die Vordergrundfarbe ist ^[38;2;<r>;<g>;<b>m
#   Die Escape-Sequenz für die Hintergrundfarbe ist ^[48;2;<r>;<g>;<b>m
#   <r> <g> <b> liegen jeweils im Bereich von 0 bis einschließlich 255.
#   Die Escape-Sequenz ^[0m setzt die Ausgabe auf den Standard zurück.
setBackgroundColor()
{
    echo -en "\x1b[48;2;$1;$2;$3""m"
}

# 
# Setzt Ausgabe wieder zurück
resetOutput()
{
    echo -en "\x1b[0m\n"
}

# Gibt eine Farbe bei $1/255 % entlang des HSV-Farbraums aus  
# Gibt "$red $green $blue" aus, wobei  
# $red, $green und $blue Ganzzahlen sind  
# im Bereich von 0 bis einschließlich 255
rainbowColor()
{ 
    let h=$1/43
    let f=$1-43*$h
    let t=$f*255/43
    let q=255-t

    if [ $h -eq 0 ]
    then
        echo "255 $t 0"
    elif [ $h -eq 1 ]
    then
        echo "$q 255 0"
    elif [ $h -eq 2 ]
    then
        echo "0 255 $t"
    elif [ $h -eq 3 ]
    then
        echo "0 $q 255"
    elif [ $h -eq 4 ]
    then
        echo "$t 0 255"
    elif [ $h -eq 5 ]
    then
        echo "255 0 $q"
    else
        # execution should never reach here
        echo "0 0 0"
    fi
}

for i in `seq 0 127`; do
    setBackgroundColor $i 0 0
    echo -en " "
done
resetOutput

for i in `seq 255 128`; do
    setBackgroundColor $i 0 0
    echo -en " "
done
resetOutput

for i in `seq 0 127`; do
    setBackgroundColor 0 $i 0
    echo -n " "
done
resetOutput

for i in `seq 255 128`; do
    setBackgroundColor 0 $i 0
    echo -n " "
done
resetOutput

for i in `seq 0 127`; do
    setBackgroundColor 0 0 $i
    echo -n " "
done

resetOutput
for i in `seq 255 128`; do
    setBackgroundColor 0 0 $i
    echo -n " "
done
resetOutput

for i in `seq 0 127`; do
    setBackgroundColor `rainbowColor $i`
    echo -n " "
done
resetOutput

for i in `seq 255 128`; do
    setBackgroundColor `rainbowColor $i`
    echo -n " "
done
resetOutput
