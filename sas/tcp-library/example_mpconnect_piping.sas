
/* $Id$ */
/* $URL$ */
/* $Author$ */
/* from
http://support.sas.com/onlinedoc/913/getDoc/en/connref.hlp/a002213148.htm
modified for Linux. 
*/
/* -----------  DATA Step - Process P1  ----- */
signon p1 sascmd='!sascmd';
rsubmit p1  wait=no;

libname outLib sasesock ":2345"; 

/* create data set - and write to pipe */
data outLib.Intermediate;
   do i=1 to 5;
       put 'Writing row ' i;            
       output;
   end;
run;
endrsubmit;

/* -----------  DATA Step - Process P2  ----- */

signon p2 sascmd='!sascmd';
rsubmit p2  wait=no;

libname inLib sasesock ":2345";
libname outLib "."; 

data outLib.Final;
set inLib.Intermediate; 
   do j=1 to 5;
        put 'Adding data ' j;	         
        n2 = j*2; 
        output;
   end;
run;
endrsubmit;
waitfor p1 p2;

rget p1;
rget  p2;
/* -------------------------------------------- */
