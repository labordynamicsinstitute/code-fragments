/* $Id$ */
/* $URL$ */
/* $Author: vilhu001 $ */

/*------------------------------------------------------------
  check that this works on your system.
  All communication ports will be above this
  port, hard-coded as numbers.
------------------------------------------------------------*/
%let tcpinbase=20000;
%let maxunits=1;
%let tcpoutbase=%eval(&tcpinbase.+&maxunits.);
%let tcpwait=300;  /* in seconds */
%let sasbase=10000; /* port base for SAS spawner tunnels */
%let smp=yes; /* smp=yes means everything runs on the local machine */
              /* smp=no means you need to set up inter-node communication */
