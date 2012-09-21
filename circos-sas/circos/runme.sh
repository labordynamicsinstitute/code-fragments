#!/bin/bash
# Adapted from an example created on Circos online http://mkweb.bcgsc.ca/tableviewer/
PERL=/usr/bin/perl
# your mileage will vary - point this to where you have Circos installed
# You will have to ensure yourself that Circos is installed and working.
BASE_DIR=/home/vilhuber/Desktop/circos/
# Directory where tableviewer can be found
# You need to download the circos-tools distribution 
TABLEVIEWER_DIR=$BASE_DIR/circos-tools-0.16-1/tools/tableviewer
# Directory where bin/circos can be found
CIRCOS_DIR=$BASE_DIR/circos-0.62-1
# Parse the tabular data
$PERL $TABLEVIEWER_DIR/bin/parse-table -conf etc/parse-table.conf -file ../sas/irs0809_names.txt  > data/parsed.txt
cat data/parsed.txt | $TABLEVIEWER_DIR/bin/make-conf -dir data
$PERL $CIRCOS_DIR/bin/circos -conf etc/circos.conf

