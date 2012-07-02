#!/bin/bash
#
function set_limits {

#  CPU and memory limits and defaults.
#  Reasonable maximum limits have to do with the destination queue.  I decided to collect these parameters
#  together because these have historically been the things that are different between the research1 and research2
#  clusters, and have been the things that I've had to maintain in qsas and qstata as memory limits have changed, etc.
#
#  I'm not sure how useful these are if people tend to submit to a variety of different queues
#  served by execution hosts with different capacities, etc.
#
cpumin=1
cpumax=24
memmin=2048
memmax=122880
cpudef=1
memdef=5120
}

args=$@
argcnt=$#
function print_help
{
    cat << EOF
Launch R (batch mode) under PBS-like systems.

Usage: qR FILE cpucount
       qR --program=FILE [OPTIONS] 

Options:
    --program=FILE        Run FILE using R in a PBS-like system.
    --logfile=FILE        Name of the log file. If not specified, it will be the default: FILE.Rout.
    --queue=QUEUE         Specifies which PBS queue to use.  When unspecified, the job will be sent to
                          the queue indicated by the environment variable DEFAULT_PBS_QUEUE (if set),
                          otherwise it will be sent to the default queue.
    --cpucount=NUM        Use NUM cpus to process the R program. Default is $cpudef.  NOTE: Generally,
                          R is single threaded, so unless you know what you are doing, this should be 1.
    --memsize=NUM         Use NUM memory (in MB) to process the R program. Limit is $memmax MB.  Default memory 
			  allocation is $memdef MB.
    --pbsname=LABEL       Set the name of the job in the PBS queue. The standard is to
                          use the first 15 digits of the program name.
    --mailops=OPS         Set the PBSPro events for which emails should be sent. The --mailto option must be set
                          properly for any email notifications to go out. The options are as follow:
                          n=No Emails (default); a=Send mail if job is aborted; b=Send mail when job executes; and
                          e=Send mail when job terminates. a, b, and e, can be used in combination.
    --mailto=ADDR         Send PBSPro event emails to ADDR, which should be in the form of USER@SERVER. Use
                          the --mailops option to set which event emails should be sent.
    --verbose             Turn on verbose mode. Prints all settings prior to running job.
    --debug               Turn on debug. All code will run except that the job will not be placed in the PBS
                          queue. Also, running in debug mode will set the verbose flag as well.

Version 0.01
qR is a hack by Chad Russell of the qstata program that was a hack by Graton Gathright of the qsas program by
Rob Creecy and modified by Matthew Graham.
Report bugs to <chad.eric.russell@census.gov>.
EOF

exit 0
}

function parse_args
{
	set -- $args
	[[ $# = 0 ]] && print_help
	case $1 in
		--help|-h)
			print_help
			;;
		-*)
			positional=no
			;;
		*)
			positional=yes
			[[ -z $1 ]] || program=$1
			[[ -z $2 ]] || cpucount=$2
			if [[ $# -gt 2 ]]
			then
			    echo "Warning: Too many positional parameters."
			    print_help
			fi
			quiet=no
			;;
	esac
	[[ $positional = yes ]] && return

	while [[ ! -z $1 ]]
	do
		case $1 in
			--program*)
				program=${1##*=}
				;;
			--memsize*)
				memsize=${1##*=}
				;;
                        --queue*)
                                queue=${1##*=}
                                ;;
			--pbsname*)
				pbsname=${1##*=}
				;;
			--cpucount*)
				cpucount=${1##*=}
				;;
                        --logfile*)
                                logfile=${1##*=}
                                ;;
			--mailops*)
				mailops=${1##*=}
				;;
			--mailto*)
				mailto=${1##*=}
				;;
		    --verbose*)
			    verbose=yes
				;;
		    --debug*)
		        echo "Debug Mode On: PBS Job will NOT be started."
		        debug=yes
 		        verbose=yes
				;;
			--quiet*)
				quiet=yes
				;;
			*)
				echo "Oops. Unknown parameter. Check your command line"
				echo "$*"
				exit 2
				;;
		esac
		shift
	done
#	[[ -z $program ]] && print_help

}

function calc_params
{
# Get a program name with a specified path
	baseprog=$(basename $program)
	program=$(dirname $program)/$baseprog
	
# If cpucount not specified, set to the default.
	[[ -z $cpucount ]] && cpucount=$cpudef
# If memsize not specified, set to the default.
	
	[[ -z $memsize ]] && memsize=$memdef

# Check memsize, and put it in range: memmin .le. memsize .le. memmax 
	
	if [[ $memsize -lt $memmin ]]
	then
	    echo "Warning: memsize not allowed to be less than $memmin (MB). Resetting to $memmin MB."
	    memsize=$memmin
	fi
	if [[ $memsize -gt $memmax ]]
	then
	    echo "Warning: memsize not allowed to be greater than $memmax GB. Resetting to $memmax  MB."
	    memsize=$memmax
	fi

# Check cpucount, and put it in range: cpumin .le. cpucount .le. cpumax

        if [[ $cpucount -lt $cpumin ]]
        then
            echo "Warning: cpucount not allowed to be less than $cpumin. Resetting to $cpumin."
            cpucount=$cpumin
        fi
        if [[ $cpucount -gt $cpumax ]]
        then
            echo "Warning: cpucount not allowed to be greater than $cpumax. Resetting to $cpumax."
            cpucount=$cpumax
        fi

	
        [[ -z $logfile ]] || extras=" ${logfile}"
	[[ -z $pbsname ]] && pbsname=${baseprog:0:15}
    	[[ -z $mailto ]] && mailto=$USER
    	[[ -z $mailops ]] && mailops=n
        [[ -z $queue ]] && queue=$DEFAULT_PBS_QUEUE
        [[ -z $queue ]] || destination=" -q ${queue}"
	resources="-l select=1:ncpus=$cpucount:mem=${memsize}mb"

}

function verbose_print
{
    cat <<EOF
Verbose Mode On

LIMITS AND DEFAULTS:

cpumin=${cpumin}
cpumax=${cpumax}
memmin=${memmin}
memmax=${memmax}
cpudef=$cpudef
memdef=$memdef


PARAMETERS:
program=$program 
logfile=$logfile
extras=$extras
cpus=$cpucount 
memsize=$memsize 
pbsname=$pbsname 
mailto=$mailto
mailops=$mailops
queue=$queue
destination=$destination
resources=$resources
R command=R CMD BATCH $program $extras

EOF
}

function run_program
{
    echo '#!/bin/bash' "
#PBS -N $pbsname
#PBS -M $mailto
#PBS -m $mailops
#PBS $resources
#PBS -j oe
cd $PWD
R CMD BATCH $program $extras" | qsub $destination
}


#------ Run Main Program ------
set_limits
parse_args
calc_params
[[ -z $verbose ]] || verbose_print
[[ -z $debug ]] && run_program

