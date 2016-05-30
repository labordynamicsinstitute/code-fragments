/**************************************************************
 This file contains the SAS syntax to import all csv files into
 SAS tables.  To make these work, the directory = macro variable
 must be set to the directory location of the files and the libname= 
 macro variable should be set to the directory location where the
 SAS tables will go.  This program also assumes that the files have
 been unzipped from their state on the DVD and into the same directory.
****************************************************************/

 
/*****************************************************************
SAS import code for CSV files
Code will need the assignment of the &directory and &libname
location to work
 
For UNIX, you can also uncomment the second filename statement
and comment out the first filename statement.
******************************************************************/

%macro sas_import_qwi(demotype=,firmtype=,seriesid=,zip=gunzip,csvloc=,outputloc=);

%let unixpipe=PIPE;

libname OUTPUTS "&outputloc";

/* read in version.txt */
/* QWIRH_F AK 02 2000:1-2013:3 V4.0 R2014Q2 qwipu_ak_20140517_1128 */
%let versionfile=&csvloc./version_&demotype._&firmtype..txt;
%if %sysfunc(fileexist(&versionfile.)) %then %do;
  data _null_;
	infile "&versionfile.";
	length tmp1 $ 12 stateup $ 2 state $ 2 range $ 13 
		schema $ 5 release $ 7 vintage $ 22 ;
	input tmp1 stateup state range schema release vintage;
	call symput("_state",trim(left(stateup)));
	call symput("_range",trim(left(range)));
	call symput("_release",trim(left(release)));
	call symput("_vintage",trim(left(vintage)));
 run;

 %put State: &_state.;
 %put Range: &_range.;
 %put Release: &_release.;
 %put Vintage: &_vintage.;
%end;


%if ( "&zip." = "gunzip" ) %then %do;
  %let fullfile=&csvloc/qwi_&state._&demotype._&firmtype._&seriesid..csv.gz;
  filename csvfile pipe "gunzip -c &fullfile. ";
%end;
%else %if ( "&zip." = "bunzip2") %then %do;
  %let fullfile=&csvloc/qwi_&state._&demotype._&firmtype._&seriesid..csv.bz2;
  filename csvfile pipe "bunzip2 -c &fullfile. ";
%end;
%else %do;
  %let fullfile=&csvloc/qwi_&state._&demotype._&firmtype._&seriesid..csv;
  filename csvfile "&fullfile. ";
%end;
 
%if %sysfunc(fileexist(&fullfile.)) %then %do;
   %put === Reading in &fullfile. ===;
**  The following data step appends all csv files into a single SAS data table;
data OUTPUTS.qwi_&state._&demotype._&firmtype._&seriesid. (compress=yes
	 	label="State &_state. &_release. (&_range.)|&_vintage."	
		);
                infile csvfile firstobs=2 dsd dlm=',' lrecl=32767 ;
                        informat
periodicity $1.
seasonadj $1.
geo_level $1.
geography $8.
ind_level $1.
industry $5.
ownercode $3.
sex $1.
agegrp $3.
race $2.
ethnicity $2.
education $2.
firmage $1.
firmsize $1.
year best32.
quarter best32.
Emp best32.
EmpEnd best32.
EmpS best32.
EmpTotal best32.
EmpSpv best32.
HirA best32.
HirN best32.
HirR best32.
Sep best32.
HirAEnd best32.
SepBeg best32.
HirAEndRepl best32.
HirAEndR best32.
SepBegR best32.
HirAEndReplR best32.
HirAS best32.
HirNS best32.
SepS best32.
SepSnx best32.
TurnOvrS best32.
FrmJbGn best32.
FrmJbLs best32.
FrmJbC best32.
FrmJbGnS best32.
FrmJbLsS best32.
FrmJbCS best32.
EarnS best32.
EarnBeg best32.
EarnHirAS best32.
EarnHirNS best32.
EarnSepS best32.
Payroll best32.
sEmp best32.
sEmpEnd best32.
sEmpS best32.
sEmpTotal best32.
sEmpSpv best32.
sHirA best32.
sHirN best32.
sHirR best32.
sSep best32.
sHirAEnd best32.
sSepBeg best32.
sHirAEndRepl best32.
sHirAEndR best32.
sSepBegR best32.
sHirAEndReplR best32.
sHirAS best32.
sHirNS best32.
sSepS best32.
sSepSnx best32.
sTurnOvrS best32.
sFrmJbGn best32.
sFrmJbLs best32.
sFrmJbC best32.
sFrmJbGnS best32.
sFrmJbLsS best32.
sFrmJbCS best32.
sEarnS best32.
sEarnBeg best32.
sEarnHirAS best32.
sEarnHirNS best32.
sEarnSepS best32.
sPayroll best32.
                        ;
                        label
periodicity='Periodicity of report'
seasonadj='Seasonal Adjustment Indicator'
geo_level='Group: Geographic level of aggregation'
geography='Group: Geography code'
ind_level='Group: Industry level of aggregation'
industry='Group: Industry code'
ownercode='Group: Ownership group'
sex='Group: Gender'
agegrp='Group: Age group'
race='Group: race'
ethnicity='Group: ethnicity'
education='Group: education'
firmage='Group: Firm Age group'
firmsize='Group: Firm Size group'
year='Time: Year'
quarter='Time: Quarter'
Emp='Employment: Counts'
EmpEnd='Employment end-of-quarter: Counts'
EmpS='Employment stable jobs: Counts'
EmpTotal='Employment reference quarter: Counts'
EmpSpv='Employment stable jobs - previous quarter: Counts'
HirA='Hires All: Counts'
HirN='Hires New: Counts'
HirR='Hires Recalls: Counts'
Sep='Separations: Counts'
HirAEnd='End-of-quarter hires'
SepBeg='Beginning-of-quarter separations'
HirAEndRepl='Replacement hires'
HirAEndR='End-of-quarter hiring rate'
SepBegR='Beginning-of-quarter separation rate'
HirAEndReplR='Replacement hiring rate'
HirAS='Hires All stable jobs: Counts'
HirNS='Hires New stable jobs: Counts'
SepS='Separations stable jobs: Counts'
SepSnx='Separations stable jobs - next quarter: Counts'
TurnOvrS='Turnover stable jobs: Ratio'
FrmJbGn='Firm Job Gains: Counts'
FrmJbLs='Firm Job Loss: Counts'
FrmJbC='Firm jobs change: Net Change'
FrmJbGnS='Firm Gain stable jobs: Counts'
FrmJbLsS='Firm Loss stable jobs: Counts'
FrmJbCS='Firm stable jobs change: Net Change'
EarnS='Employees stable jobs: Average monthly earnings'
EarnBeg='Employees beginning-of-quarter : Average monthly earnings'
EarnHirAS='Hires All stable jobs: Average monthly earnings'
EarnHirNS='Hires New stable jobs: Average monthly earnings'
EarnSepS='Separations stable jobs: Average monthly earnings'
Payroll='Total quarterly payroll: Sum'
sEmp='Status: Employment: Counts'
sEmpEnd='Status: Employment end-of-quarter: Counts'
sEmpS='Status: Employment stable jobs: Counts'
sEmpTotal='Status: Employment reference quarter: Counts'
sEmpSpv='Status: Employment stable jobs - previous quarter: Counts'
sHirA='Status: Hires All: Counts'
sHirN='Status: Hires New: Counts'
sHirR='Status: Hires Recalls: Counts'
sSep='Status: Separations: Counts'
sHirAEnd='Status: End-of-quarter hires'
sSepBeg='Status: Beginning-of-quarter separations'
sHirAEndRepl='Status: Replacement hires'
sHirAEndR='Status: End-of-quarter hiring rate'
sSepBegR='Status: Beginning-of-quarter separation rate'
sHirAEndReplR='Status: Replacement hiring rate'
sHirAS='Status: Hires All stable jobs: Counts'
sHirNS='Status: Hires New stable jobs: Counts'
sSepS='Status: Separations stable jobs: Counts'
sSepSnx='Status: Separations stable jobs - next quarter: Counts'
sTurnOvrS='Status: Turnover stable jobs: Ratio'
sFrmJbGn='Status: Firm Job Gains: Counts'
sFrmJbLs='Status: Firm Job Loss: Counts'
sFrmJbC='Status: Firm jobs change: Net Change'
sFrmJbGnS='Status: Firm Gain stable jobs: Counts'
sFrmJbLsS='Status: Firm Loss stable jobs: Counts'
sFrmJbCS='Status: Firm stable jobs change: Net Change'
sEarnS='Status: Employees stable jobs: Average monthly earnings'
sEarnBeg='Status: Employees beginning-of-quarter : Average monthly earnings'
sEarnHirAS='Status: Hires All stable jobs: Average monthly earnings'
sEarnHirNS='Status: Hires New stable jobs: Average monthly earnings'
sEarnSepS='Status: Separations stable jobs: Average monthly earnings'
sPayroll='Status: Total quarterly payroll: Sum'
                        ;
                        input
periodicity
seasonadj
geo_level
geography
ind_level
industry
ownercode
sex
agegrp
race
ethnicity
education
firmage
firmsize
year
quarter
Emp
EmpEnd
EmpS
EmpTotal
EmpSpv
HirA
HirN
HirR
Sep
HirAEnd
SepBeg
HirAEndRepl
HirAEndR
SepBegR
HirAEndReplR
HirAS
HirNS
SepS
SepSnx
TurnOvrS
FrmJbGn
FrmJbLs
FrmJbC
FrmJbGnS
FrmJbLsS
FrmJbCS
EarnS
EarnBeg
EarnHirAS
EarnHirNS
EarnSepS
Payroll
sEmp
sEmpEnd
sEmpS
sEmpTotal
sEmpSpv
sHirA
sHirN
sHirR
sSep
sHirAEnd
sSepBeg
sHirAEndRepl
sHirAEndR
sSepBegR
sHirAEndReplR
sHirAS
sHirNS
sSepS
sSepSnx
sTurnOvrS
sFrmJbGn
sFrmJbLs
sFrmJbC
sFrmJbGnS
sFrmJbLsS
sFrmJbCS
sEarnS
sEarnBeg
sEarnHirAS
sEarnHirNS
sEarnSepS
sPayroll
                        ;
/*
                ** include data labels for all class variables **;
                ** this section has been commented out to minimize the size of output files  **;
length periodicityfm $20;
periodicityfm=trim(put(periodicity,$periodi.));
length seasonadjfm $30;
seasonadjfm=trim(put(seasonadj,$seasona.));
length geo_levelfm $40;
geo_levelfm=trim(put(geo_level,$geo_lev.));
length geographyfm $75;
geographyfm=trim(put(geography,$geograp.));
length ind_levelfm $40;
ind_levelfm=trim(put(ind_level,$ind_lev.));
length industryfm $120;
industryfm=trim(put(industry,$industr.));
length ownercodefm $20;
ownercodefm=trim(put(ownercode,$ownerco.));
length sexfm $20;
sexfm=trim(put(sex,$sex.));
length agegrpfm $16;
agegrpfm=trim(put(agegrp,$agegrp.));
length racefm $50;
racefm=trim(put(race,$race.));
length ethnicityfm $25;
ethnicityfm=trim(put(ethnicity,$ethnici.));
length educationfm $35;
educationfm=trim(put(education,$educati.));
length firmagefm $20;
firmagefm=trim(put(firmage,$firmage.));
length firmsizefm $20;
firmsizefm=trim(put(firmsize,$firmsiz.));
*/
run;
%end; /* end fileexist condition */
%else %do;
   %put "Not reading in &fullfile. - File does not exist";
%end;
 
/*****************************************************************
End of SAS syntax to import csv file:
******************************************************************/
%mend;

