/* $Id$ */
/* $URL$ */
/* $Author: vilhu001 $ */

/*------------------------------------------------------------
  check that this works on your system.
  All communication ports will be above this
  port, hard-coded as numbers.
------------------------------------------------------------*/
%let tcpinbase=20000;
%let maxunits=2;
%let tcpoutbase=%eval(&tcpinbase.+&maxunits.);
%let tcpwait=300;  /* in seconds */
%let sasbase=10000; /* port base for SAS spawner tunnels */
