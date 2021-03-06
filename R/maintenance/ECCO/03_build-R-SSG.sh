#!/bin/bash
pkglist=pkglist.SSG.txt
outfile=build-R-SSG.R
wd=$(pwd)
#. config.sh

[[ -d $lib ]] || mkdir -p $lib

count=$(cat $pkglist| wc -l)
echo "# $(date) " > $outfile
if [[ ! $count = 0 ]]
then
   printf "%20s" "pkgs <- c(" >> $outfile
   cat $pkglist |\
    awk -v ORS=, ' { print "\""$1"\"" } ' >> $outfile
   # work around the last part of the array: need one more element
   head -1 $pkglist | awk -v ORS= ' { print "\""$1"\"" } ' >> $outfile
   echo ")" >> $outfile
fi

echo "install.packages(pkgs, contriburl='$CRANURL', lib='$lib')">> $outfile 
echo "warnings()" >> $outfile

# adding lines for rstan
#echo "library(inline)" >> $outfile
#echo "library(Rcpp)" >> $outfile
#echo "library(RcppEigen)" >> $outfile
echo "options(repos = c(getOption('repos'), rstan = 'http://wiki.stan.googlecode.com/git/R'))
install.packages('rstan', type = 'source') " >> $outfile

# now we run it
echo "We will now run the progrom to create $count CRAN packages"
echo "   $Rbin CMD BATCH $outfile" 
echo " Press CTRL-C to interrupt within the next 5 seconds"
sleep 5
echo " Running "
$Rbin CMD BATCH $outfile
#echo " Installing Umacs"
#R CMD INSTALL Umacs_0.924.tar.gz >>${outfile}out
echo "Installing ASREML-R [enter]"
read
R CMD INSTALL /home/admin/extras/ASREML/asreml_3.0.1_R_gl-centos5.5-intel64.tar.gz -l $lib >>${outfile}out

cat ${outfile}out

# we need to clean out some packages that were re-compiled
for arg in $(cat core-packages.txt)
do
[[ -d $lib/$arg ]] && echo \rm -rf $lib/$arg >> remove-core.sh
done

echo " Verify remove-core.sh, then"
echo " do" 
echo " (cd $lib/..; tar cjvf ${wd}/R-${version}-mkl-ssg.tar.bz2 library/)"




