/* $Id$ */
/* $URL$ */
/* $Author$ */

/*
    This does the same work as template_tcplibrary.sas,
    but does NOT use the ESOCK stuff - only sequential,
    but parallel processing

*/

options mprint symbolgen ;
libname OUTPUTS '.';
%include "config_grid.sas";
/* include "config_user.sas"; not needed */ 

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
   In this program, the data get created before the 
   MP Connect - no streaming, remember.
*/


data OUTPUTS.master
%do i=1 %to &maxunits.;
  WORK.one_&i.
%end;
	;
        do i =1 to &samplesize.;
        j=ranuni(today());
	segment=mod(i,&maxunits.)+1;
	if segment = 1 then output WORK.one_1;
%do i=2 %to &maxunits.;
  else if segment = &i. then output WORK.one_&i. ;
%end;
	output OUTPUTS.master;
        end;
run;



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
            RSUBMIT n&i. WAIT=NO inheritlib=(OUTPUTS=OUTPUTS WORK=LWORK);
	    
	    proc sort data=LWORK.one_&i. out=two;
	    by j;
	    run;

	    data LWORK.two_&i.;
	         set two;
		 length handler 3;
		 handler=&i.;
	    run;

            ENDRSUBMIT;
        %end; /* end of mpconnect config */
%end; /* end i loop */

/*============================================================
   The jobs have been fed, now we wait for them to complete
   this could be made more efficient - what signals can
   we look for?
*/

        %if ( &mpconnect = yes ) %then %do;
           WAITFOR _ALL_
%do i=1 %to &maxunits.;
           n&i.
%end;
          ;

/*------------------------------------------------------------
  Collect the logs for this step.
------------------------------------------------------------*/
%do i=1 %to &maxunits.;
           RGET n&i;
%end;

/*------------------------------------------------------------
  If this is the end, turn off the compute nodes
------------------------------------------------------------*/
%do i=1 %to &maxunits.;
           SIGNOFF n&i;
%end;
        %end; /* end of mpconnect config */



/*============================================================ 
   We skip the jobs that collect them - they were just
   there so they could listen.

*/

/*------------------------------------------------------------
  Combine all the node files back together.
------------------------------------------------------------*/

	    data OUTPUTS.final_cluster_all;
		 set
%do i=1 %to &maxunits.;
	           WORK.two_&i.
%end;
		;
	       run;

	    proc freq data=OUTPUTS.final_cluster_all;
	    table segment handler segment*handler;
	    run;

               
%mend;
%runit;

