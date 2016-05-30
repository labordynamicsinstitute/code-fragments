#!/bin/bash
if [[ -z $1 ]]
then
cat << EOF
  $0 start

  will launch the qsub jobs in this directory.

  $0 incoming (RELEASE)
 
  will only launch qsub jobs if the QWI download
  is for RELEASE

  (adding 'force'  will not check for existing output files)

EOF
exit 0
fi

method=$1
INRELEASE=$1
RELEASE=$2
[[ "$3"  = "force" ]] && force=1 || force=0

[[ -z $2 && "$method" = "incoming" ]] && method=start

eval $(grep -E "^INBASE"  create_qsub.bash )


for arg in $(ls -1 qsub.??)
do
  case $method in
	incoming)
	# check if the desired release is actually there
	state=$(echo $arg | awk -F. ' { print $2 } ')
	version=$(cat $INBASE/$state/wia/version.txt | dos2unix | sed 's/(//g; s/)//g; s/V3.4 /_/ ; s/\r//g' | awk -F_ '  { print $2 } ' )

	if [[ "$version"  = "$RELEASE" ]] 
	then
         eval $(grep -E "^PERMDATA" create_qsub.bash)
  	 # check if there is already a read-in version
	 test -d $PERMDATA/$state && READIN_DONE=1 || READIN_DONE=0
         [[ "$force" = "1" ]] && READIN_DONE=0 
	 case $READIN_DONE in
		1)
		echo "Output directory $PERMDATA/$state exists" 
	     	echo " Not launching job. To launch manually, do" 
		echo " cd logs; qsub ../$arg; cd -"
		;;
		0)
		echo "Launching qsub for state=$state"
  		cd logs
		qsub ../$arg
		cd ..
		;;
	 esac
        else
		echo "For state=$state, release $version != $RELEASE" 
		echo "Not launching"
	fi
	;;
	start)
	# unconditionally launching
	cd logs
	qsub -q premium ../$arg
	cd ..
	;;
  esac
done
