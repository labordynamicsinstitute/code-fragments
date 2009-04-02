/*============================================================*/
/* $Id$ */
/* $URL$ */
/* To cleanly unlock the database. From
   http://www.lexjansen.com/pharmasug/2005/posters/po33.pdf
   Uses the same call syntax as %trylock.
*/
/*============================================================*/
/* should go into a MACRO autocall location */


%macro unlock(member=,timeout=10,retry=3);
   %put Unlocking &member ...;
   lock &member clear;
   %put syslckrc=&syslckrc;
%mend unlock;
