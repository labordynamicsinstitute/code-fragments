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
%let maxunits=2;
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

	    proc sort data=TO_N.one out=two;
	    by j;
	    run;

	    data FROM_N.two;
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
            /*---------- SIGNON ----------*/
            SIGNON c&i. sascmd="sas -altlog local_c_&i..log -work /tmp";
            %syslput thisdir=&thisdir.;
            %syslput maxunits=&maxunits.;
	    %syslput tcpoutbase=&tcpoutbase.;
	    %syslput tcpwait=&tcpwait.;
            %syslput i=&i.;
            RSUBMIT c&i. WAIT=NO inheritlib=(OUTPUTS=OUTPUTS WORK=LWORK);
	    
	    libname FROM_N sasesock ":%eval(&tcpoutbase.+&i.)" TIMEOUT=&tcpwait.;
	    data LWORK.final_cluster_&i.;
	       set FROM_N.two;
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
  TO_N&i..one
%end;
	;
        do i =1 to 1000;
        j=ranuni(today());
	segment=mod(i,&maxunits.)+1;
	if segment = 1 then output TO_N1.one;
%do i=2 %to &maxunits.;
  else if segment = &i. then output TO_N&i..one ;
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

