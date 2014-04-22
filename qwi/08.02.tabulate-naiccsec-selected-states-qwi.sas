/* $Id$ */
/* $URL$ */
%include "config.sas";

/* this focusses the statistics on a single quarter */

%let snapshotqtime=62;

proc freq data=INTERWRK.qwi_extract_sample
     (where=( county='000' and  naicssec ne '90-99' and  naicssec ne '92' 
         and naicssec ne '00'
          and agegrp='A00'   and ownercode='A05'  and sex='0'
	 and qtime=&snapshotqtime.
         ));
table naicssec/out=OUTPUTS.qwi_states_naicssec;
weight b;
run;

proc print data=OUTPUTS.qwi_states_naicssec;
run;

