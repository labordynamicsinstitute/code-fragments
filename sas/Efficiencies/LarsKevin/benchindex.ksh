#! /usr/bin/ksh
programname=$1
repetitions=$2

if [[ -z ${programname} ]]
then
    echo "$0 programname repetitions"
    exit 1
fi
# intialize this log file
logfile=${programname}.${repetitions}
date > ${logfile}

# get at statistics
function statistics 
{
tmp="$(grep -E "user cpu|system cpu" ${programname}.log | tail -2 | awk ' { print $3 } ')"
user_cpu="$(echo "$tmp" | head -1 )"
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
	    echo "This is new to me.. don't understand"
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
	    echo "This is new to me.. don't understand"
	    exit 2
	fi
   fi
fi
IFS=" "

# now the I/O counts
tmp="$(grep -E "input|output" ${programname}.log | tail -2 | awk ' { print $2 } ')"
input="$(echo "$tmp" | head -1 )"
output="$(echo "$tmp" | tail -1 )"

# compute into metrics
let user_cpu=${user_cpu_m}+(${user_cpu_s}/60)
let system_cpu=${system_cpu_m}+(${system_cpu_s}/60)
let io=${input}+${output}

echo "Statistics for Run ${this_run}: ">> ${logfile}
echo "USER_CPU: ${user_cpu}" 	       >> ${logfile}
echo "SYSTEM_CPU: ${system_cpu}"       >> ${logfile}
echo "IO: ${io}"                       >> ${logfile}  

} # end function statistics

# start iterations
this_run=1
while [[ $this_run -le $repetitions ]]
do
    # run sas prog
    ( time sas ${programname}.sas ) 2>> ${logfile}
    statistics
    let this_run=${this_run}+1
done

total_user="$(grep USER_CPU ${logfile} | \
    awk '{print $2}' | awk '{ sum += $1 } { print sum }' | tail -1 )"
total_system="$(grep SYSTEM_CPU ${logfile} | \
    awk '{print $2}' | awk '{ sum += $1 } { print sum }' | tail -1 )"
total_io="$(grep IO ${logfile} | \
    awk '{print $2}' | awk '{ sum += $1 } { print sum }' | tail -1 )"
let avg_user=${total_user}/${repetitions}
let avg_system=${total_system}/${repetitions}
let avg_io=${total_io}/${repetitions}

print "Avg USER_CPU   for ${repetitions} runs: $avg_user" >> ${logfile}
print "Avg SYSTEM_CPU for ${repetitions} runs: $avg_system" >> ${logfile}
print "Avg IO         for ${repetitions} runs: $avg_io" >> ${logfile}
tail -3 ${logfile}