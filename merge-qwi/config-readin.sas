/* $Id: config-readin.sas 385 2012-05-29 21:24:44Z vilhu001 $ */
/* $URL: https://repository.vrdc.cornell.edu/CISER/mainweb/trunk/qwi.readin-progs/merging-files/config-readin.sas $ */
options sasautos = (!SASAUTOS,".");

%let release=R2014Q4;
%let clean=/data/archive/clean/qwipu/state;
%let base=&clean./data.&release.;

%mk_qwi_us(qwibase=&base.,libname=qwi_usA);

/* also parse other ones */
%mk_qwi_us(qwibase=&clean/data.R2014Q3,libname=qwi_usB);
*mk_qwi_us(qwibase=&clean/data.R2014Q2,libname=qwi_usC);
%mk_qwi_us(qwibase=&clean/data.R2014Q1,libname=qwi_usD);
%mk_qwi_us(qwibase=&clean/data.R2013Q4,libname=qwi_usE);

libname qwi_us (qwi_usA,qwi_usB,qwi_usD,qwi_usE);


