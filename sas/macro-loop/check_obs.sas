/* $Id$ */
/* $URL$ */
/*BEGINCCC
	This utility macro simply uses the SAS7BDAT metadata
        to put the number of obs into a global macro variable.
CCCEND*/

%macro check_obs(filename);

%global nobs;

%let dsid = %sysfunc(open(&filename.));
%let nobs=%sysfunc(attrn(&dsid,nobs));
%let rc = %sysfunc(close(&dsid));

%put Variable NOBS contains the number of observations (=&nobs.);
%mend;
