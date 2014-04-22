/* $Id$ */
/* $URL$ */
/* In order to run this, you will need to download either the QWIPU for the states in your sample 
     http://download.vrdc.cornell.edu/qwipu/
   or the consolidated all-states files 
     http://download.vrdc.cornell.edu/qwipu.experimental/all/
   and the experimental National QWIPU
     http://download.vrdc.cornell.edu/qwipu.national/

  This program assumes data/variable names in the QWI V3.5 format (prior to R2013Q2).
*/
%include "config.sas";

/* define the states in your sample. Examples below */
%let list1=ca fl id il md mt nc nj or tx wa;
%let list2=fl il md nc nj or tx wa ok sc va vt wi wv ar co ia in me nm;

/* we use "scientific" names for the statistics, preferred over the public-use names on the CSV files */
%include "./rename_qwipu_qwi.sas"/source2;


/* utility macro */
%macro select_states(list=);
%local  i;
 state in (
"%sysfunc(stfips(%scan(&list.,1)))"
%do i = 2 %to %sysfunc(countw(&list.));
, "%sysfunc(stfips(%scan(&list.,&i.)))"
%end;
)
%mend;

/* now grab the all-ages, all-sex, naics numbers from each of the displacement
states */

data INTERWRK.qwi_extract_sample;
set QWI.QWI_US_WIA_COUNTY_NAICSSEC_PRI
 (where=(county='000' and naicssec ne '90-99' and  naicssec ne '92' 
         /* and naicssec ne '00' */
         and agegrp='A00' and ownercode='A05' and sex='0' and %select_states(list=&list2))
 drop= qwi_geo qwi_ind naicssecfm ownerfm agegrpfm)
;
%rename_qwipu(naics=yes,sic=no);
length yyq $ 6;
yyq=put(year,4.)||'Q'||put(quarter,1.);
qtime=(year-1985)*4+quarter;
label qtime="Linear quarters (1985Q1=1)";
run;

