/* $Id$ */
/* $URL$ */
/* $Author: vilhu001 $ */

/*------------------------------------------------------------
  This contains the user and (encrypted/hashed) 
  password for the remote site(s).
  
  This file should be copied to config_user.sas
  and the default values replaced.
------------------------------------------------------------*/
%let remoteuser=ME;
%let remotepwd={sas001}DKISUED;

/*------------------------------------------------------------
  the encrypted password should be generated using
  the following SAS program, which can be run
  on the command line:


  proc PWENCODE in="TOPSECRET"; run;
 
  The output should be pasted into the &remotepwd 
  macro variable, above.
------------------------------------------------------------*/
