/* $Id$ */
/* $URL$ */
/* $Author$ */

/*
    This does the same work as template_tcplibrary.sas,
    but does NOT use the MP/Connect stuff - straight through 
    processing.

*/

options mprint symbolgen ;
libname OUTPUTS '.';

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
%let mpconnect=no;
%let maxunits=1;
%let i=1;

/*------------------------------------------------------------
  the actual execution unit 
------------------------------------------------------------*/

%macro runit;

/*------------------------------------------------------------
  This is the master feeder. It gets started last in the 
  MP/Connect version
------------------------------------------------------------*/

data OUTPUTS.master
	;
        do i =1 to &samplesize.;
        j=ranuni(today());
	segment=mod(i,&maxunits.)+1;
	output OUTPUTS.master;
        end;
run;

/*------------------------------------------------------------
   NODE ROUTINE
   This is what the nodes do.
------------------------------------------------------------*/

	    proc sort data=OUTPUTS.master out=two;
	    by j;
	    run;

	    data OUTPUTS.final_cluster_all;
	         set two;
		 length handler 3;
		 handler=&i.;
	    run;

/*------------------------------------------------------------
  Obviously, no need to collect the data. This just provides
  the same statistics as the original data.
------------------------------------------------------------*/   

	    proc freq data=OUTPUTS.final_cluster_all;
	    table segment handler segment*handler;
	    run;

               
%mend;
%runit;

