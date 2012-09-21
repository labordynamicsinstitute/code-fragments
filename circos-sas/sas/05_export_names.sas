%include "config.sas";

%let yrpair=0809;



proc export data=OUTPUTS.wide_names replace
  file="irs&yrpair._names.txt"
  dbms=csv;
  delimiter=",";
  putnames=no;
run;

