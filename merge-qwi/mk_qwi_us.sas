/* $Id: mk_qwi_us.sas 311 2011-10-21 19:52:46Z vilhu001 $ */
/* $URL: https://repository.vrdc.cornell.edu/CISER/mainweb/trunk/qwi.readin-progs/merging-files/mk_qwi_us.sas $ */

/* creates a composite QWI library */

%macro mk_qwi_us(states=all,qwibase=,libname=QWI_US);
%local state exist_states i;
/* the states for now are hard-coded. This shold be automated */
%if ( "&states" = "all" ) %then
  %let states=
ak al ar az ca co ct dc de fl ga hi ia id il in ks ky la ma md me mi mn mo
ms mt nc nd ne nh nj nm nv ny oh ok or pa ri sc sd tn tx ut va vt wa wi wv wy
;
%if ( "&qwibase." = "" ) %then %do;
%put %upcase(error)::: you should define qwibase! ;
data _null_;
call execute('endsas;');
run;
%end;

/* create individual libnames */
%let i=1 ;
%let exist_states=;
%do %while ("%scan(&states.,&i.)" ne "" ) ;
  %let state=%scan(&states.,&i.);
  %if %sysfunc(fileexist(&qwibase./&state.)) %then %do;
    libname qwi_&state. "&qwibase./&state.";
    %let exist_states=&exist_states. &state.;
  %end;
%let i=%eval(&i.+1);
%end;

/* create composite libname */
%if ( "&exist_states." ne "" ) %then %do;
libname &libname. (qwi_%scan(&exist_states.,1)
%let i =2 ;
%do %while ("%scan(&exist_states.,&i.)" ne "" ) ;
  %let state=%scan(&exist_states.,&i.);
     , qwi_&state. 
  %let i=%eval(&i.+1);
%end;
);
%end;


%mend;

