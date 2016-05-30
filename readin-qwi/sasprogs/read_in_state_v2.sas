/* $Id: read_in_state_v2.sas 478 2013-04-29 02:58:10Z vilhu001 $ */
/* this program needs to be used for vintages
   newer than or equal to R2011Q1, due to 
   changes in the directory structure
*/

options compress=yes;
/* this is a proper macro definition since 2011-04-19 */
%include "&progbase./sas_import_module.sas";

%macro read_state(start=,end=,state=,type=sa se rh,ftype=f fa fs,zip=gunzip);
%local i j STATE;

%if ( "&state." ~= "" ) %then %do;
  %let start=%sysfunc(stfips(&state.));
  %let end=&start.;
%end;

%do fips=&start. %to &end.;
 
 %let STATE=%sysfunc(fipstate(&fips));
 %let state=%lowcase(&STATE);
 %put state=&state.;

 data _null_;
 call system("[[ -d &outbase/&state. ]] || mkdir &outbase/&state.");
 run;

 %let i=1;
 %do %until ( "%scan(&type.,&i.)" = "" );
   %let _type=%scan(&type.,&i.);

   %let j=1;
   %do %until ( "%scan(&ftype.,&j.)" = "" );
     %let _ftype=%scan(&ftype.,&j.);

   /* standard set of variables */

   %sas_import_qwi(demotype=&_type.,firmtype=&_ftype.,seriesid=gs_n4_op_u,zip=&zip.,csvloc=&importbase./&state./&_type./&_ftype.,outputloc=&outbase./&state.);

     %let j=%eval(&j.+1);
   %end; /* end while condition */
   %let i=%eval(&i.+1);
 %end; /* end while condition */
%end; /* end fips loop */


%mend;

%read_state(state=&sysparm.,type=sa ,ftype=f fa fs);



