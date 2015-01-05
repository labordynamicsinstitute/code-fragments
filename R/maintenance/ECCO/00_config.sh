#lib=$HOME/build/R/library
lib=/scratch/lv39/MKL/MP/library
#version=3.0.2-ACML/MP
#lib=/home/admin/extras/R/R-2.14/R/library
#Rbin=/cac/contrib/R-${version}/bin/R
Rbin=$(which R)
CRANURL=http://lib.stat.cmu.edu/R/CRAN/src/contrib
BIOURL=http://www.bioconductor.org/biocLite.R
R_LIBS_SITE=$lib
export R_LIBS_SITE BIOURL CRANURL Rbin version lib

