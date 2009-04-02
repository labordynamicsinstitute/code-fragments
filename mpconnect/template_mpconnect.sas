/* $Id$ */
/* $URL$ */
/* $Author$ */
options mprint symbolgen sascmd='sas -work /tmp' autosignon;
%let mpconnect=no;
%macro runit;
            %let thisdir=%sysget(PWD);

%do i=1 %to 10;
        %if ( &mpconnect = yes ) %then %do;
            /*---------- SIGNON ----------*/
            SIGNON run&i.;
            %syslput thisdir=%QUOTE(&thisdir.)/REMOTE=run&i.&j.;
            %syslput i=&i.;
            RSUBMIT run&i. WAIT=NO;
        %end; /* end of mpconnect config */

data one;
        do i =1 to 1000;
        j=ranuni(today());
        output;
        end;
run;

proc sort data=one out=two;
by j;
run;

data _null_;
        file "&thisdir./&i..txt";
        set two;
        put i;
run;
        %if ( &mpconnect = yes ) %then %do;
            ENDRSUBMIT;
        %end; /* end of mpconnect config */
%end; /* end i loop */

        %if ( &mpconnect = yes ) %then %do;
           WAITFOR _ALL_
%do i=1 %to 10;
           run&i.
%end;
          ;
%do i=1 %to 10;
           RGET run&i;
           SIGNOFF run&i;
%end;
        %end; /* end of mpconnect config */

               
%mend;
%runit;
