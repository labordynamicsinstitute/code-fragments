#!/bin/bash
# $Id: benchmark-lehd.bash 17 2009-11-27 17:55:13Z vilhu001 $
# $HeadURL: http://repository.vrdc.cornell.edu/public/benchmarks/trunk/sas/lehd/benchmark-lehd.bash $
#
INRELEASE=$1
INBASE=/data/raw/qwipu/qwi.$INRELEASE

if [[ "$INRELEASE"  = "incoming" ]]
then
   RELEASE=$(cat $INBASE/??/sa/f/version_sa_f.txt | dos2unix | sed 's/(//g; s/)//g; s/V3.4 /_/' | awk -F_ '  { print $2 } ' | sort | uniq | tail -1)
else
   RELEASE=$INRELEASE
fi

PROGBASE=$(pwd)/..
TEMPBASE=/temporary/lv39/qwipu/data
PERMSERVER=archive.vrdc.cornell.edu
# this is the path on PERMSERVER!
SASDATA=/data/archive/clean/qwipu/state/data.$RELEASE
 
echo " $0 (INRELEASE)"
echo " Processing INRELEASE=$INRELEASE" 
echo "  Latest is RELEASE=$RELEASE" 
echo "  Inputs read from $INBASE"
echo "  Outputs will be stored under $PERMSERVER:$SASDATA"
echo " Press enter to continue"
read

BASE=$(pwd)
# create log directory
[[ -d ${BASE}/logs ]] || mkdir ${BASE}/logs
# update config location
svn up $PROGBASE
case $? in
   1)
	echo "Is $PROGBASE not a svn checkout?"
	exit 2
	;;
   0)
	echo "$PROGBASE is up-to-date"
	;;
   *)
	echo " Unknown exit code" 
	exit 1
	;;
esac
# modify config
if [[ -f $PROGBASE/sasprogs/config.sas ]] 
then
	echo "$PROGBASE/sasprogs/config.sas exists - not modifying"
else
	cp -i $PROGBASE/sasprogs/config.template $PROGBASE/sasprogs/config.sas
	echo "%let release=${RELEASE};
%let importbase=${INBASE};
%let progbase=${PROGBASE}/sasprogs;
%let outbase=${TEMPBASE};
%put ============= Running on %sysget(HOSTNAME)=============;
" >> $PROGBASE/sasprogs/config.sas
fi


for state in $(cd $INBASE; ls -1d ?? )
do 
echo "
#PBS -l ncpus=1,mem=8192mb
#PBS -l walltime=12:00:00
#PBS -N $state
#PBS -j oe
#PBS -m abe
#PBS -M virtualrdc@cornell.edu
PROGBASE=$PROGBASE
[[ -d $TEMPBASE/\$PBS_JOBNAME ]] && \rm -rf $TEMPBASE/\$PBS_JOBNAME
mkdir -p $TEMPBASE/\$PBS_JOBNAME
cd $BASE/logs
/usr/local/bin/sas  -work /dev/shm -memsize 7500m       \
-print $BASE/logs/qwi-readin-\${PBS_JOBNAME}.lst     \
-log $BASE/logs/qwi-readin-\${PBS_JOBNAME}.log     \
-sysparm \$PBS_JOBNAME     \
-initstmt '%let release=${RELEASE};%let importbase=${INBASE};%let progbase=${PROGBASE}/sasprogs;%let outbase=${TEMPBASE};' \
-cpucount 1      \
\$PROGBASE/sasprogs/read_in_state_v2.sas \
-autoexec \$PROGBASE/sasprogs/config.sas 
exitcode=\$?
echo \"SAS exitcode was \$exitcode\"
# clean up after ourselves
if [[ \$exitcode = 0 ]]
then
#\rm -rf $TEMPBASE/\$PBS_JOBNAME 
#chmod -R a+rX $$PERMSERVER:$SASDATA/\$PBS_JOBNAME/
exitcode=\$?
fi
exit \$exitcode 

" > qsub.${state} 
 echo Processed state $state
done

if [[ "$2" = "launch" ]]
then
  launch_qsub.bash $RELEASE 
else
echo "Not launching - to launch, specify 'launch' as argument to this script"
echo "  or run    launch_qsub.bash incoming $RELEASE " 
fi


