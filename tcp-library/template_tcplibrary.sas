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
%include "config_grid.sas";
%include "config_user.sas";

/*------------------------------------------------------------
  Size of the test run in this program
------------------------------------------------------------*/
%let samplesize=1000000;
/*------------------------------------------------------------
  MP/Connect config 
------------------------------------------------------------*/
options sascmd='sas -work /tmp' autosignon;

/*------------------------------------------------------------
 this should not be set to no 
------------------------------------------------------------*/
%let mpconnect=yes;


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

            /*---------- SIGNON depends on SMP setting ----------*/
	    %if ( "&smp" = "yes" ) %then %do;
               SIGNON n&i. sascmd="sas -altlog local_n_&i..log -work /tmp" 
	    %end;
	    %else %do;
               %let n&i.=localhost %eval(&sasbase.+&i.);
               SIGNON n&i. user=&remoteuser. password="&remotepwd.";
	    %end;

            %syslput thisdir=&thisdir.;
            %syslput i=&i.;
	    %syslput tcpinbase=&tcpinbase.;
	    %syslput tcpoutbase=&tcpoutbase.;
	    %syslput tcpwait=&tcpwait.;
            RSUBMIT n&i. WAIT=NO;
	    
	    libname TO_N sasesock ":%eval(&tcpinbase.+&i.)"  TIMEOUT=&tcpwait.;
	    libname FROM_N sasesock ":%eval(&tcpoutbase.+&i.)"  TIMEOUT=&tcpwait.;

	    proc sort data=TO_N.one_&i. out=two;
	    by j;
	    run;

	    data FROM_N.two_&i.;
	         set two;
		 length handler 3;
		 handler=&i.;
	    run;

            ENDRSUBMIT;
        %end; /* end of mpconnect config */
%end; /* end i loop */

/*============================================================ 
   now we need the jobs that collect them again.

*/

     %do i=1 %to &maxunits.;
        %if ( &mpconnect = yes ) %then %do;
            /*---------- SIGNON here is always the SMP version ----------*/
            SIGNON c&i. sascmd="sas -altlog local_c_&i..log -work /tmp";
            %syslput thisdir=&thisdir.;
            %syslput maxunits=&maxunits.;
	    %syslput tcpoutbase=&tcpoutbase.;
	    %syslput tcpwait=&tcpwait.;
            %syslput i=&i.;
            RSUBMIT c&i. WAIT=NO inheritlib=(OUTPUTS=OUTPUTS WORK=LWORK);
	    
	    libname FROM_N sasesock ":%eval(&tcpoutbase.+&i.)" TIMEOUT=&tcpwait.;
	    data LWORK.final_cluster_&i.;
	       set FROM_N.two_&i.;
	       run;

            ENDRSUBMIT;
        %end; /* end of mpconnect config */
      %end; /* end of i-maxunits */



/*============================================================
   the listening jobs have been spawned off.
   Now we should feed them - PUSH model.
*/

%do i=1 %to &maxunits.;
  libname TO_N&i. sasesock ":%eval(&tcpinbase.+&i.)";
%end;

data OUTPUTS.master
%do i=1 %to &maxunits.;
  TO_N&i..one_&i.
%end;
	;
        do i =1 to &samplesize.;
        j=ranuni(today());
	segment=mod(i,&maxunits.)+1;
	if segment = 1 then output TO_N1.one_1;
%do i=2 %to &maxunits.;
  else if segment = &i. then output TO_N&i..one_&i. ;
%end;
	output OUTPUTS.master;
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

/*------------------------------------------------------------
  Combine all the node files back together.
------------------------------------------------------------*/

	    data OUTPUTS.final_cluster_all;
		 set
%do i=1 %to &maxunits.;
	           WORK.final_cluster_&i.
%end;
		;
	       run;

	    proc freq data=OUTPUTS.final_cluster_all;
	    table segment handler segment*handler;
	    run;

               
%mend;
%runit;

