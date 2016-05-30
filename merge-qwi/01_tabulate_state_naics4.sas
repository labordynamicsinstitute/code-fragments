/* $Id: 02_merge_us_county_naicssec.sas 312 2011-10-24 13:36:18Z vilhu001 $ */
/* $URL: https://repository.vrdc.cornell.edu/CISER/mainweb/trunk/qwi.readin-progs/merging-files/02_merge_us_county_naicssec.sas $ */
%include "./mk_qwi_us.sas";
%include "./mk_qwi_us_dataset.sas";
%include "config-readin.sas"/source2;

x mkdir &base./us;


libname OUTPUTS "&base./us" ;
options compress=yes;

/* now call the 2nd macro, specifying a qwi suffix to create a US view on that file */
%mk_qwi_us_dataset(states=all,qwilib=QWI_US,suffix=sa_fs_gs_n4_op_u,
                   outlib=OUTPUTS);
