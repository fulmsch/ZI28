#!/usr/bin/env bash

ROOTDIR=../..
UTILDIR=$ROOTDIR/utils

SRCFILES=$(find src/ -type f)

for infile in $SRCFILES
do
	outfile=doc/${infile##*/}.yaml
	$UTILDIR/zi28doc/z80asmdoc.py -i $infile -o $outfile -x doc/index.yaml
	if [ -f $outfile ]
	then
		pandoc --template $UTILDIR/zi28doc/template_file.html $outfile -o ${outfile/yaml/html}
	fi
done

pandoc --template $UTILDIR/zi28doc/template_index.html doc/index.yaml -o doc/index.html
rm doc/*.yaml
cp $UTILDIR/zi28doc/styles.css doc/
