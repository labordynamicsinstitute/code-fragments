#!/bin/bash
pkglist=pkglist.CAC.txt
outfile=build-R-CAC.R
CRANURL=http://www.vrdc.cornell.edu/CRAN/src/contrib
lib=$HOME/build/R
. config.sh


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

# we need to clean out some packages that were re-compiled
for arg in $(cat core-packages.txt)
do
[[ -d $lib/$arg ]] && echo \rm -rf $lib/$arg >> remove-core.sh
done

echo " Verify remove-core.sh, then"
echo " do" 
echo " (cd $base; tar czvf ${wd}/R-packages-SSG-$version.tgz $libbase)"


