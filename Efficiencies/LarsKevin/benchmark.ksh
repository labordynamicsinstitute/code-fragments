#! /usr/bin/ksh
version=0.2
programname=$1
repetitions=$2

if [[ -z ${programname} ]]
then
    echo "$0 programname [repetitions]"
    echo "                default=5"
    exit 1
fi

programname=${programname%*.sas}
if [[ ! -e ${programname}.sas ]]
then
    echo "${programname}.sas not exist"
    exit 2
fi
[[ -z ${repetitions} ]] && repetitions=5
echo "Running $repetitions repetitions"
# intialize this log file
logfile=${programname}.${repetitions}
date > ${logfile}

# get at statistics
function statistics 
{
# for SAS 6.12:
# tmp="$(grep -E "user cpu|system cpu" ${programname}.log | tail -2 | awk ' { print $3 } ')"
# For SAS 8
tmp="$(grep -E "real time" ${programname}.log | tail -1 | awk ' { print $3 } ')"
IFS=".:"
real_time="$(echo "$tmp" | head -1)"
set -- ${real_time}
# echo "1=$1 2=$2 3=$3"
if [[ $# -eq 2 ]]
then
    real_time_m=0
    real_time_s=${1}.${2}
else if [[ $# -eq 3 ]]
	then
	    real_time_m=${1}
	    real_time_s=${2}.${3}
   else if [[ $# -eq 4 ]]
	then
	    let real_time_m=${1}*60+${2}
	    real_time_s=${3}.${4}
	else
	    echo "This is new to me.. don't understand (real time)"
	    exit 2
	fi
   fi
fi
#echo "real_time_m=$real_time_m"
#echo "real_time_s=$real_time_s"
IFS=" "

#
# user and system time
tmp="$(grep -E "user cpu|system cpu" ${programname}.log | tail -2 | awk ' { print $4 } ')"
#echo "Tmp=$tmp"
user_cpu="$(echo "$tmp" | head -1)"
#echo "user_cpu=$user_cpu"
IFS=".:"
set -- ${user_cpu}
if [[ $# -eq 2 ]]
then
    user_cpu_m=0
    user_cpu_s=${1}.${2}
else if [[ $# -eq 3 ]]
	then
	    user_cpu_m=${1}
	    user_cpu_s=${2}.${3}
   else if [[ $# -eq 4 ]]
	then
	    let user_cpu_m=${1}*60+${2}
	    user_cpu_s=${3}.${4}
	else
	    echo "This is new to me.. don't understand (user_cpu)"
	    exit 2
	fi
   fi
fi
system_cpu="$(echo "$tmp" | tail -1 )"
set -- ${system_cpu}
if [[ $# -eq 2 ]]
then
    system_cpu_m=0
    system_cpu_s=${1}.${2}
else if [[ $# -eq 3 ]]
	then
	    system_cpu_m=${1}
	    system_cpu_s=${2}.${3}
   else if [[ $# -eq 4 ]]
	then
	    let system_cpu_m=${1}*60+${2}
	    system_cpu_s=${3}.${4}
	else
	    echo "This is new to me.. don't understand (system_cpu)"
	    exit 2
	fi
   fi
fi
IFS=" "

# now the I/O counts
#tmp="$(grep -E "nput|utput" ${programname}.log | tail -2 | awk ' { print $2 } ')"
tmp="$(grep -E "nput|utput" ${programname}.log | tail -2 | awk ' { print $4 } ')"
input="$(echo "$tmp" | head -1 )"
output="$(echo "$tmp" | tail -1 )"

# compute into metrics
let real_time=${real_time_m}+(${real_time_s}/60)
let user_cpu=${user_cpu_m}+(${user_cpu_s}/60)
let system_cpu=${system_cpu_m}+(${system_cpu_s}/60)
let io=${input}+${output}

echo "Statistics for Run ${this_run}: ">> ${logfile}
echo "REAL_TIME: ${real_time}"         >> ${logfile}
echo "USER_CPU: ${user_cpu}" 	       >> ${logfile}
echo "SYSTEM_CPU: ${system_cpu}"       >> ${logfile}
echo "IO: ${io}"                       >> ${logfile}  

} # end function statistics

# start iterations
echo "Starting iterations...\c"
this_run=1
while [[ $this_run -le $repetitions ]]
do
    # run sas prog
    echo "${this_run}...\c"
    ( time sas ${programname}.sas ) 2>> ${logfile}
    statistics
    let this_run=${this_run}+1
done
echo "Done."
total_time="$(grep REAL_TIME ${logfile} | \
    awk '{print $2}' | awk '{ sum += $1 } END { print sum }' )"
total_user="$(grep USER_CPU ${logfile} | \
    awk '{print $2}' | awk '{ sum += $1 } END { print sum }'  )"
total_system="$(grep SYSTEM_CPU ${logfile} | \
    awk '{print $2}' | awk '{ sum += $1 } END { print sum }'  )"
total_io="$(grep IO ${logfile} | \
    awk '{print $2}' | awk '{ sum += $1 } END { print sum }'  )"
let avg_time=${total_time}/${repetitions}
let avg_user=${total_user}/${repetitions}
let avg_system=${total_system}/${repetitions}
let avg_io=${total_io}/${repetitions}

print "Avg REAL_TIME  for ${repetitions} runs: $avg_time" >> ${logfile}
print "Avg USER_CPU   for ${repetitions} runs: $avg_user" >> ${logfile}
print "Avg SYSTEM_CPU for ${repetitions} runs: $avg_system" >> ${logfile}
print "Avg IO         for ${repetitions} runs: $avg_io" >> ${logfile}
print "(IO is sum of INPUT and OUTPUT operations)" >> ${logfile}
echo ""
tail -5 ${logfile}
