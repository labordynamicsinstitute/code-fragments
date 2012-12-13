#!/bin/bash

####################################################################################
# Note to future generations/programmers:
#
# The qtility script was designed for use on a number of the Census Bureau's 
# research computers. It implements easy access points for users to run standard
# processing tools within the PBS Pro queueing system. Primarily this is meant
# for the majority of users who want to "just run my SAS program" or whatever.
# This is not going to be all that useful for a small set of expert PBS Pro users
# who need very specific tweaks for their programs to run. Some of the most basic
# and useful PBS options will be implemented here. And others can be added in the
# future as needed.
#
# A few requirements:
# - Calling qtility will be done with links. So, for example, we'll have:
#   qstata -> qtility, or
#   qR -> qtility, and the main qtility script will figure how it was called and how
#   it should work based on that.
# - For the most basic operations, the q script should be fully subtitutable for the
#   the original program call (i.e. "sas myprogram.sas" can be replace with
#   "qsas myprogram.sas"). Kind of a "simple mode".
# - Some PBS- and program-specific options can be accessed with double-dash command
#   line options in a sort of "advanced mode".
# - Changes to the core qtility script should not - in general - change the way 
#   currently implemented scripts work.
#
#
# The overall architecture of the script is as follows:
# 1. Parse the script name so we know how to handle program-specific stuff.
# 2. Parse the general arguments.
# 2a. Parse the program-specific arguments.
# 3. Check the general arguments for consistency and complete them if necessary.
# 3b. Check the program-specific arguments.
# 4. If requested, print all the checked/completed parameters.
# 5. If not in debug mode, submit the program-specific job.
#
# This fragment is a template for the program-specific implementations for qtility
# It is not designed to be run separately, but rather to be included in the general qtility
####################################################################################

SOFTWARE=SAS

####################################################################################
function qsas_help
{
	case $1 in
		head)
			cat << EOF
Currently sets memsize, sortsize, and sumsize automatically. When specifying the number
of chunks/cpucount, these variables will be set as follows unless overridden in the options:
    memsize = chunks * 5000MB
    sortsize = memsize - 10MB
    sumsize = memsize - 10MB
EOF
			;;	
		opts)
			cat << EOF
    --sasprog=FILE        Run FILE in a PBS-like system. '.sas' extension need not be specified.
    --sortsize=NUM        Set the SAS sortsize as NUM megabytes. sortsize may not be larger than memsize.
    --sumsize=NUM         Set the SAS sumzie as NUM megabytes. sumsize may not be larger than memsize.
    --altlog=FILE         Set the SAS altlog to be FILE. No error checking is done on the file or location.
EOF
			;;	
		tail)
			cat << EOF
SAS-specific handler written by Matthew Graham
Report bugs to <matthew.graham@census.gov>.
EOF
			;;	
	esac	
}
####################################################################################

####################################################################################
function qsas_parse_args
{
	case $1 in
		positional)
			set -- $args
			[[ -z $1 ]] || sasprog=$1
			[[ -z $2 ]] || cpucount=$2
			if [[ $# -gt 2 ]]
			then
			    echo "Warning: Too many positional parameters."
			    print_help
			fi
			quiet=no
			;;
		optional)
			shift
			while [[ ! -z $1 ]]
			do
				case $1 in
					#vvvvvvvvvvv MODIFY SAS OPTIONS BELOW HERE vvvvvvvvvvv
					--sasprog*)
						sasprog=${1##*=}
						;;
					--sortsize*)
						sortsize=${1##*=}
						if [[ $sortsize -ge $rawmemsize ]]
						then
							echo "Warning: sortsize (${sortsize}) must be less than memsize (${rawmemsize})."
							echo "Resetting sortsize to be 10MB less than memsize."
							sortsize=
						fi
						;;
					--sumsize*)
						sumsize=${1##*=}
						if [[ $sumsize -ge $rawmemsize ]]
						then
							echo "Warning: sumsize (${sumsize}) must be less than memsize (${rawmemsize})."
							echo "Resetting sumsize to be 10MB less than memsize."
							sumsize=
						fi
						;;
					--altlog*)
						altlog=${1##*=}
	    				# check for fullpath here
						if [[ "$(dirname $altlog)" = "." ]]
						then
							altlog=$(pwd)/$(basename $altlog)
						fi
						;;
					#^^^^^^^^^^ MODIFY SAS OPTIONS ABOVE HERE ^^^^^^^^^^
					*)
						echo "Oops. Your parameter was unknown by the general parser and by the SAS parser. Check your command line"
						echo "Your bad parameter was: $*"
						err=true
						;;
				esac
				shift
			done

			;;
	esac


}
####################################################################################

####################################################################################
function qsas_check_args
{
	# Reform the program name to make sure the ".sas" extension is there.
	[[ -z $sasprog && ! -z $program ]] && sasprog=$program
	baseprog=$(basename $sasprog .sas)
	sasprog=$(dirname $sasprog)/$baseprog.sas

	[[ -z $sumsize ]] && sumsize=$(( ${rawmemsize}-10 ))
	[[ -z $sortsize ]] && sortsize=$(( ${rawmemsize}-10 ))
	[[ -z $altlog ]] || extras="-altlog ${altlog}"

	# These variables need special formatting after getting their values.
	# These variables need special formatting after getting their values.
    memsize=$rawmemsize"m"
    sumsize=$sumsize"m"
    sortsize=$sortsize"m"
}
####################################################################################

####################################################################################
function qsas_verbose_print
{
    cat <<EOF
Verbose Mode On

PARAMETERS:
sasprog=$sasprog 
chunks/cpucount=$cpucount 
memsize=$memsize 
sumsize=$sumsize 
sortsize=$sortsize 
extras=$extras 
pbsname=$pbsname 
mailto=$mailto
mailops=$mailops
resources=$resources
sas command=sas -noterminal -cpucount $cpucount -memsize $memsize -sumsize $sumsize -sortsize $sortsize $extras $sasprog

EOF
}
####################################################################################

####################################################################################
function qsas_submit
{
    echo '#!/bin/bash' "
#PBS -N $pbsname
#PBS -M $mailto
#PBS -m $mailops
#PBS $resources
#PBS -j oe
cd $programdir
sas -noterminal -cpucount $cpucount -memsize $memsize -sumsize $sumsize -sortsize $sortsize $extras $sasprog" 
}
####################################################################################

