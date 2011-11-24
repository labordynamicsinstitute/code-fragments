#!/bin/bash
# $Id$
# $URL$
#
# Script to launch remote SAS spawners and listen on specific ports
# Works in conjunction with template_tcplibrary.sas
#

tcpinbase=20000
maxunits=2
let tcpoutbase=${tcpinbase}+${maxunits}
counter=1
sasbase=10000
sasremoteport=5555
sasspawner=/opt/SAS_9.1.3/utilities/bin/sastcpd
sasspawner_OPTS="-service 5555 -sascmd /opt/SAS_9.1.3/sas -shell"


for server in vrdc3201 vrdc6401
do 
  let toport=${counter}+${tcpinbase}
  let fromport=${counter}+${tcpoutbase}
  let sasport=${counter}+${sasbase}
  ssh -o ClearAllForwardings=yes \
      -L ${toport}:127.0.0.1:${toport} \
      -L ${fromport}:127.0.0.1:${fromport} \
      -L ${sasport}:127.0.0.1:5555 \
      ${server}.ciser.cornell.edu  \
      "$sasspawner $sasspawner_OPTS & echo $! " &
  echo $counter = $!
 let counter+=1
done
