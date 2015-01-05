/*Code to create a small sequential access SAS data set
and then compress it using a named pipe*/
/* Original: Justin McCrary <justin.mccrary@gmail.com> */
/* Modified/adapted: Lars Vilhuber <lars.vilhuber@cornell.edu> */

data tmp;
   do i = 1 to 100;
     output;
   end;
run;
proc print data=tmp(obs=10);
run;

x 'mknod piper p';
x 'gzip < piper > justin.sas7sdat.gz &';
x 'ls -l piper';
libname fargo 'piper';

%put Still here.;
proc print data=tmp(obs=1);
title "Test print";
run;


data fargo.justin;
  set tmp;
run;

x 'rm piper';
