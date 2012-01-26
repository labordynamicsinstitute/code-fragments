#!/bin/bash
pkglist=pkglist.SSG.txt
outfile=build-R-SSG.R
CRANURL=http://www.vrdc.cornell.edu/CRAN/src/contrib
lib=/scratch/lv39
Rbin=/cac/contrib/R-2.14.0/bin/R

printf "%20s" "pkgs <- c(" > $outfile
cat $pkglist |\
  awk -v ORS=, ' { print "\""$1"\"" } ' >> $outfile
# work around the last part of the array: need one more element
head -1 $pkglist | awk -v ORS= ' { print "\""$1"\"" } ' >> $outfile
echo ")" >> $outfile

count=$(cat $pkglist| wc -l)

echo "install.packages(pkgs, contriburl='$CRANURL', lib='$lib')">> $outfile 
echo "warnings()" >> $outfile

# now we run it
echo "We will now run the progrom to create $count CRAN packages"
echo "   $Rbin CMD BATCH $outfile" 
echo " Press CTRL-C to interrupt within the next 5 seconds"
sleep 5
echo " Running "
$Rbin CMD BATCH $outfile
cat ${outfile}out


