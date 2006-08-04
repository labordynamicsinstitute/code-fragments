/* $Id$ */
/* $URL$ */
/* $Author$ */

/*
    This works for SMP machines.

    Nomenclature:
      n&i. : node jobs - execute computation
      c&i. : collecting jobs - gather results

      TO_N: (writing) to remote node
      FROM_N: (reading) from remote node

*/

options mprint symbolgen ;
libname OUTPUTS '.';

/*------------------------------------------------------------
  MP/Connect config 
------------------------------------------------------------*/
options sascmd='sas -work /tmp' autosignon;

/*------------------------------------------------------------
 this should not be set to no 
------------------------------------------------------------*/
%let mpconnect=yes;

/*------------------------------------------------------------
  check that this works on your system.
  All communication ports will be above this
  port, hard-coded as numbers.
------------------------------------------------------------*/
%let tcpinbase=2000;
%let maxunits=1;
%let tcpoutbase=%eval(&tcpinbase.+&maxunits.);
%let tcpwait=30;  /* in seconds */

/*------------------------------------------------------------
  the actual execution unit 
------------------------------------------------------------*/

%macro runit;
            %let thisdir=%sysget(PWD);

/*============================================================
  Listening processing units
*/
%do i=1 %to &maxunits.;
        %if ( &mpconnect = yes ) %then %do;
            /*---------- SIGNON ----------*/
            SIGNON n&i. sascmd="sas -altlog local_n_&i..log -work /tmp";
            %syslput thisdir=&thisdir.;
            %syslput i=&i.;
	    %syslput tcpinbase=&tcpinbase.;
	    %syslput tcpoutbase=&tcpoutbase.;
	    %syslput tcpwait=&tcpwait.;
            RSUBMIT n&i. WAIT=NO;
	    
	    libname TO_N sasesock ":%eval(&tcpinbase.+&i.)"  TIMEOUT=&tcpwait.;
	    libname FROM_N sasesock ":%eval(&tcpoutbase.+&i.)"  TIMEOUT=&tcpwait.;

        %end; /* end of mpconnect config */


proc sort data=TO_N.one out=two;
by j;
run;

data FROM_N.two;
     set two;
     length handler 3;
     handler=&i.;
run;

        %if ( &mpconnect = yes ) %then %do;
            ENDRSUBMIT;
        %end; /* end of mpconnect config */
%end; /* end i loop */

/*============================================================ 
   now we need the jobs that collect them again.

*/

        %if ( &mpconnect = yes ) %then %do;
	  %do i=1 %to &maxunits.;
            /*---------- SIGNON ----------*/
            SIGNON c&i. sascmd="sas -altlog local_c_&i..log -work /tmp";
            %syslput thisdir=&thisdir.;
            %syslput maxunits=&maxunits.;
	    %syslput tcpoutbase=&tcpoutbase.;
	    %syslput tcpwait=&tcpwait.;
            %syslput i=&i.;
            RSUBMIT c&i. WAIT=NO inheritlib=(OUTPUTS=OUTPUTS);
	    
	    libname FROM_N sasesock ":%eval(&tcpoutbase.+&i.)" TIMEOUT=&tcpwait.;
	    %end;

	    data OUTPUTS.final_cluster_&i.;
	       set FROM_N.two;
	       run;

            ENDRSUBMIT;
        %end; /* end of mpconnect config */


/*============================================================
   the listening jobs have been spawned off.
   Now we should feed them.
*/

%let i=1;
libname TO_N sasesock ":%eval(&tcpinbase.+&i.)";
data TO_N.one;
        do i =1 to 1000;
        j=ranuni(today());
	segment=mod(i,&maxunits.)+1;
        output;
        end;
run;


/*============================================================
   The jobs have been fed, now we wait for them to complete
   this could be made more efficient - what signals can
   we look for?
*/

        %if ( &mpconnect = yes ) %then %do;
           WAITFOR _ALL_
%do i=1 %to &maxunits.;
           n&i.
	   c&i.
%end;
          ;

/*------------------------------------------------------------
  Collect the logs for this step.
------------------------------------------------------------*/
%do i=1 %to &maxunits.;
           RGET n&i;
           RGET c&i;
%end;

/*------------------------------------------------------------
  If this is the end, turn off the compute nodes
------------------------------------------------------------*/
%do i=1 %to &maxunits.;
           SIGNOFF n&i;
           SIGNOFF c&i;
%end;
        %end; /* end of mpconnect config */

               
%mend;
%runit;

