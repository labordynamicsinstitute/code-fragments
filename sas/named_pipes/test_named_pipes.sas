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
filename nwrpipe pipe 'gzip < piper > justin.sas7sdat.gz &';
libname fargo 'piper';

data _null_;
  infile nwrpipe;
run;  

data fargo.justin;
  set tmp;
run;

x 'rm piper';
