/* $Id$ */
/* $URL$ */
%include "config.sas";

PROC EXPORT DATA= INPUTS.qwi_national
     (where=(/* county='000' and */ naicssec ne '90-99' and  naicssec ne '92' 
         /* and naicssec ne '00' */
          and agegrp='A00' /*  and ownercode='A05' */ and sex='0'))
            OUTFILE= "%sysfunc(pathname(interwrk))/qwi_national_extract.dta"
            DBMS=DTA REPLACE;
RUN;

PROC EXPORT DATA= INTERWRK.qwi_extract_sample
     	    OUTFILE= "%sysfunc(pathname(interwrk))/qwi_extract_sample.dta"
            DBMS=DTA REPLACE;
RUN;
