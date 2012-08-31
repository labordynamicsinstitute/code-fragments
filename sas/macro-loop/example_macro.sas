/* $Id$ */
/* $URL$ */
/* example macro, used to test the core macro of this code fragment*/

%macro example_macro(param1=,param2=,output=);
data &output.;
	k=&i.*&j.;
	output;
run;
%mend;
