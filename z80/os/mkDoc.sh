#!/usr/bin/env bash

ROOTDIR=../..
UTILDIR=$ROOTDIR/utils

SRCFILES=$(find src/ -maxdepth 1 -type f)

for infile in $SRCFILES
do
	outfile=${infile/src/doc}.yaml
	$UTILDIR/zi28doc/z80asmdoc.py -i $infile -o $outfile -x doc/index.yaml
	pandoc --template $UTILDIR/zi28doc/template_file.html $outfile -o ${outfile/yaml/html}
done

pandoc --template $UTILDIR/zi28doc/template_index.html doc/index.yaml -o doc/index.html
rm doc/*.yaml
cp $UTILDIR/zi28doc/styles.css doc/
