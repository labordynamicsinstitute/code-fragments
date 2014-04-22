/* $Id$ */
/* $URL$ */
/*Diagnostics: creating ratios of employed workers (m), accession and separation rates (ar, sr) and job creation-destruction (jc, jd) in select states to the national - by sex
The first step does it for all quarters, the second only for quarter 2 of each year*/

OPTIONS NOmprint NOmtrace NOmlogic NOmacrogen NOsymbolgen ;
%include "config-2.sas";

options ls=150;
%macro create_naicsmod;
	length naicsmod $ 10;
	naicsmod=naicssec;
	if naicssec in ( '11','21') then naicsmod="11-21";
	if naicssec in ( '22','48-49') then naicsmod="48-49,22";
	if naicssec in ( '55','56') then naicsmod="55-56";
	if naicssec in ('51','53','54','61','62','71','72') then naicsmod="excluded";

%mend;
/*Creating a data extract with the variables of interest*/
data data_extract_sample;
	set INPUTS.qwi_extract 
	(keep = state year quarter sex naicssec county agegroup a b e s m jc jd f);
	/* we want only the margins */
	if 
	/* naicssec margin */
	(not ( naicssec  in ( '90-99' , '92', '00'))
         and county="000" and sex="0" and agegroup="A00" )
	or
	/* age margin */
	(agegroup ne "A00"
	 and naicssec="00" and county="000" and sex="0" )
	/* sex margin */
	or
	(sex ne "0"
   	 and naicssec="00" and county="000" and agegroup="A00" )
	/* total by state */
	or
	(sex = "0"
   	 and naicssec="00" and county="000" and agegroup="A00" )
	;
	where state in ('12', '17', '24', '37', '34', '41', '48', '53', '05', '08', '19', '18', '23', '35', '40', '45', '51', '50', '55', '54');
	eb2=(e+b)/2;
	%create_naicsmod;
	constant=1;
run;

/* now do the same thing to get at the national data - from the completed data */
data data_extract_national;
	set INPUTS.qwi_national_wia
	(keep = /* state */ year quarter sex naicssec /* county */ agegroup
		 qwi_a qwi_ar qwi_eb2 qwi_s qwi_sr qwi_jcr qwi_jdr qwi_f 
		 st_qwi_ar st_qwi_sr st_qwi_jcr st_qwi_jdr ) 
	;
	/* keep only margins */
	if 
	/* naicssec margin */
	(not ( naicssec  in ( '90-99' , '92', '00'))
         and  sex="0" and agegroup="A00" )
	or
	/* agegroup margin */
	(agegroup ne "A00"
	 and naicssec="00" and  sex="0" )
	or
	/* sex margin */
	(sex ne "0"
   	 and naicssec="00" and  agegroup="A00" )
	/* total US */
	or
	(sex = "0"
   	 and naicssec="00"  and agegroup="A00" )
	;
	constant=1;
	%create_naicsmod;
run;
proc sort;
by year quarter naicssec agegroup sex ;
run;


/* aggregate up the sample to an aggregate figure */
proc summary data=data_extract_sample nway;
class  year quarter naicssec agegroup sex;
id constant;
var eb2 a b s a f jc jd;
output out=data_summary_sample sum=;
run;

/* compute rates */
data data_summary_sample;
set data_summary_sample;
jcr=jc/eb2;
jdr=jd/eb2;
ar=a/eb2;
sr=s/eb2;
run;

proc sort data=data_summary_sample nodupkey;
by  year quarter naicssec agegroup sex;
run;


/* merge data */
data OUTPUTS.displacement_pu_qwi_all;
	merge data_summary_sample (in=_a)
	     data_extract_national(in=_b);
	by  year quarter naicssec agegroup sex;
	_merge=_a+2*_b;
run;


proc freq;
title "After merge";
table _merge naicssec agegroup sex year*quarter;
run;
proc print data=OUTPUTS.displacement_pu_qwi_all(where=(_merge=1));
var naicssec agegroup sex year quarter;
run;


proc print data=OUTPUTS.displacement_pu_qwi_all(where=(naicssec='00'));
run;


/* naics table */
proc print data=OUTPUTS.displacement_pu_qwi_all(where=(naicssec = '00' and quarter=2));
id  agegroup sex year quarter;
var ar qwi_ar st_qwi_ar sr qwi_sr st_qwi_sr jcr qwi_jcr st_qwi_jcr jdr qwi_jdr st_qwi_jdr;
run;





