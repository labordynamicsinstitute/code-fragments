/* from http://support.sas.com/rnd/scalability/tricks/connect.html#pipsrem */
%include "config_user.sas";
*let p1=p 10001;
options sascmd='!sascmd -work /space/tmp' autosignon;
%let p2=host2.a.b.com;
%let p3=host3.a.b.com;
%let p4=host4.a.b.com;

libname out1 sasesock ":5000" TIMEOUT=60;
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
libname out2 sasesock ":pipe2";
libname out3 sasesock ":pipe3";
libname out4 sasesock ":pipe4";
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

/* signon to four remote hosts; each will run a sort */
signon p1 /* user=vilhuber password="&remotepwd" */;

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
signon p2;
signon p3;
signon p4;
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

/* p1-p4 gets their input from data step running in  */
/* client/parent session                             */
rsubmit p1 wait=no;
/* libname in1 sasesock "delorimier:5000"; */
 libname in1 sasesock ":5000" TIMEOUT=60; 
 libname out1 sasesock ":5005" TIMEOUT=60;
 proc sort data=in1.foo out=out1.foo;
 by k;
 run;
endrsubmit;

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
rsubmit p2 wait=no;
 libname in2 sasesock "parent.b.c.com:pipe2";
 libname out2 sasesock ":pipe6";
 proc sort data=in2.foo out=out2.foo;
 by k;
 run;
endrsubmit;

rsubmit p3 wait=no;
 libname in3 sasesock "parent.b.c.com:pipe3";
 libname out3 sasesock ":pipe7";
 proc sort data=in3.foo out=out3.foo;
 by k;
 run;
endrsubmit;

rsubmit p4 wait=no;
 libname in4 sasesock "parent.b.c.com:pipe4";
 libname out4 sasesock ":pipe8";
 proc sort data=in4.foo out=out4.foo;
 by k;
 run;
endrsubmit;
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

/* create a session to do the final merge */
signon localM sascmd='!sascmd -work /space/tmp';
rsubmit localM wait=no;
 libname in1 sasesock ":5005" TIMEOUT=60;
/*
 libname in1 sasesock "p:5005";
 libname in2 sasesock "host2.a.b.com:pipe6";
 libname in3 sasesock "host3.a.b.com:pipe7";
 libname in4 sasesock "host4.a.b.com:pipe8";
*/
 data bar;                   
    set in1.foo; by k; output;
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    set in2.foo; by k; output;
    set in3.foo; by k; output;
    set in4.foo; by k; output;
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
run;
endrsubmit;


/* hash original data set and pipe subsets to each   */
/* of the four sorts                                 */
data out1.foo /* out2.foo out3.foo out4.foo */;
 drop i j;
 length x $ 80;
 x = repeat(" ", 79);
 j = 0;
 do i=1 to 50000000;
   k=ranuni(1);
   if ( j = 0 ) then
     output out1.foo;
/*
   else if ( j = 1 ) then
     output out2.foo;
   else if ( j = 2 ) then
     output out3.foo;
   else output out4.foo;
   j = j + 1;
*/
   if ( j = 4 ) then j = 0;
  end;
run;


waitfor _ALL_ p1 /* p2 p3 p4 */ localM;


rget p1; signoff p1; 
/*
signoff p2;
signoff p3;
signoff p4;
*/
rget localM; signoff localM;

