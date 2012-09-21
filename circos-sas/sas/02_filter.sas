%include "config.sas";

%let yrpair=0809;


proc sort data=INPUTS.stateinflow&yrpair. out=stateinflow&yrpair.;
by state_code_dest;
run;

data OUTPUTS.wide_filtered(rename=(f1=f01 f2=f02 f4=f04 f5=f05 f6=f06 f8=f08 f9=f09) drop=f3 f7 f14 f43 f52 f57);
	length row $ 3;
	set stateinflow&yrpair.;
        by state_code_dest;
	keep row f:;
        retain f1-f57;

	array xf(1:57) f1-f57;

	if first.state_code_dest then do i=1 to 57;
		xf(i)=.;
	end;



	do i = 1 to 57;
	row="f"||state_code_dest;
	/* filter out the stayers */
	if state_code_origin = i 
          and state_code_origin ne state_code_dest 
	  then xf(i)=return_num;
	end;

	if last.state_code_dest and state_code_dest > 0 then output;
run;

proc print data=OUTPUTS.wide_filtered;
run;


proc export data=OUTPUTS.wide_filtered replace
  file="irs&yrpair._filter.txt"
  dbms=csv;
  delimiter=",";
run;

