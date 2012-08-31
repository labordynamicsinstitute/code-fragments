/* $Id$ */
/* $URL$ */
/* run a loop of macros, driven by a data set */

%include "check_obs.sas";
%include "example_macro.sas";

/* create a dataset. In a real-world example, this would
   be a dataset of parameters. You don't want this to be
   too big (100s, not 1000s of records)
*/

data param;
	do i = 1 to 10;
	do j = i*2;
	output;
	end;
	end;
run;


%macro run_loop;
/* get number of obs in the parameter datasets */

%check_obs(param);

/* run loop over dataset */

%do i=1 %to &nobs.;

/* get the parametesr*/

data _null_;
	set param;
	if _n_=&i. then do;
		call symput('j',trim(left(j)));
		call symput('i',trim(left(i)));
	end;
run;

/* now that we have the parameters, we call the macro
  that does the actual work.*/

%example_macro(param1=&i.,param2=&j.,output=myloop);

/* in some cases, we want to store the data in a composite dataset*/
/* you will want to ensure that the generic dataset gets augmented to
   have the parameters as variables */

data myloop;
	set myloop;
	length i j 3;
	i=&i.;
	j=&j.;
run;
proc append base=outputs data=myloop;
run;

%end; /*end i loop */

%mend;
%run_loop;

/* print the result */
proc print data=outputs;
run;

