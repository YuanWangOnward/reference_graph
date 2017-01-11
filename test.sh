#! /bin/bash
# test whether the backup works well

if [  -f ./finalDiagram.png ]; then
    rm ./finalDiagram.png
fi

rm ./finalDiagram.png

sh ./ris2diagram.sh  ./myCollection.ris  ./finalDiagram.png
