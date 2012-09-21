%include "config.sas";

%let yrpair=0809;



proc export data=OUTPUTS.wide replace
  file="irs&yrpair..txt"
  dbms=csv;
  delimiter=",";
run;

