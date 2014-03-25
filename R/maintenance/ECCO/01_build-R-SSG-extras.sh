#!/bin/bash
pkglist=pkglist.bioconductor.txt
outfile=build-R-SSG-extras.R
. config.sh
[[ -d $lib ]] || mkdir -p $lib

printf "%20s" "pkgs <- c(" > $outfile
cat $pkglist |\
  awk -v ORS=, ' { print "\""$1"\"" } ' >> $outfile
# work around the last part of the array: need one more element
head -1 $pkglist | awk -v ORS= ' { print "\""$1"\"" } ' >> $outfile
echo ")" >> $outfile

count=$(cat $pkglist| wc -l)

echo "source(\"$BIOURL\")" >> $outfile
echo "biocLite(pkgs, suppressUpdates = TRUE, lib='$lib')">> $outfile 
echo "warnings()" >> $outfile

# now we run it
echo "We will now run the progrom to create $count Bioconductor packages"
echo "   $Rbin CMD BATCH $outfile" 
echo " Press CTRL-C to interrupt within the next 5 seconds"
sleep 5
echo " Running "
export R_LIBS_SITE=$lib
$Rbin CMD BATCH $outfile
cat ${outfile}out


