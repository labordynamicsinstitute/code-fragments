%include "config.sas";

%let yrpair=0809;

proc sort data=INPUTS.stateinflow&yrpair. out=stateinflow&yrpair.;
by state_code_dest;
run;

proc print data=stateinflow&yrpair.(obs=50);
run;

data OUTPUTS.wide_names(rename=(f1=f01 f2=f02 f4=f04 f5=f05 f6=f06 f8=f08 f9=f09) drop=f3 f7 f14 f43 f52 f57);
	length row $ 3 f1-f57 $ 14;
	set stateinflow&yrpair.;
        by state_code_dest;
	keep row f:;
        retain f1-f57;

	array xf(1:57) $ f1-f57;

	if first.state_code_dest then do i=1 to 57;
		xf(i)=.;
	end;

	if _n_=1 then do;
	row="row";
	do i = 1 to 57;
	xf(i)=fipstate(i);
	end;
        output;
	end;

	do i = 1 to 57;
	state_code_dest_num=state_code_dest*1;
	row=fipstate(state_code_dest_num);
        if state_code_dest='00' then row="US";
        if state_code_dest='57' then row="FO";
     
	if state_code_origin = i then xf(i)=return_num;
	end;

	if last.state_code_dest and state_code_dest > 0 then output;
run;

proc print data=OUTPUTS.wide_names;
run;


