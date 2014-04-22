/* $Id$ */
/* $URL$ */
/* This configuration file identifies locations used elsewhere. Adjust to your situation */

%let basedata=/data/clean;
%let qwi=&basedata./qwipu/state/data.R2012Q1; /* where QWI is stored */
%let interwrk=./data/interwrk; /* temporary data */
%let outputs=./data/outputs; /* permanent output files */

x mkdir -p &interwrk.;
x mkdir -p &outputs.;


libname interwrk "&interwrk.";
libname outputs "&outputs.";
libname qwi "&qwi./us";
libname qwinat "&basedata./qwipu.national/us";

libname inputs (qwi,qwinat,interwrk);

options fullstimer compress=yes;
