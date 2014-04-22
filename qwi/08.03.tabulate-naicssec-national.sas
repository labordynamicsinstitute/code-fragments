/* $Id$ */
/* $URL$ */
%include "config.sas";

proc contents data=INPUTS.qwi_national_wia;
run;


proc freq data=INPUTS.qwi_national_wia
     (where=(county='000' and naicssec ne '90-99' and  naicssec ne '92' 
         and naicssec ne '00'
          and agegroup='A00'   and ownercode='A05'  and sex='0'));
table naicssec/out=INTERWRK.national_naicssec;
weight qwi_eb2;
run;

proc print data=INTERWRK.national_naicssec;
run;

