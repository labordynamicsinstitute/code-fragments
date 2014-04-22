/* $Id$ */
/* $URL$ */
/* renames most variables to their internal short names */

%macro rename_qwipu(naics=yes,sic=no);

rename
HirA		=a 		 /* Accessions: Counts 		= Hires All: Counts */
agegrp  	=agegroup 	 /* Group: Age group code (wia) 		= Group: Age group code (wia) */
agegrpfm  	=agegroupfmt 	 /* Group: Age group name (wia) 		= Group: Age group name (wia) */
Emp		=b 		 /* Beginning-of-period employees: Counts 		= Employment: Counts */
EmpEnd  	=e 		 /* End-of-period employees: Counts 		= Employment end-of-quarter: Counts */
EmpS		=f 		 /* Full-quarter employees: Counts 		= Employment stable jobs: Counts */
HirAS		=fa 		 /* Full-quarter employees: Flows in 		= Hires All stable jobs: Counts */
FrmJbGnS  	=fjc 		 /* Full-quarter job creation: Counts 		= Firm Gain stable jobs: Counts */
FrmJbLsS  	=fjd 		 /* Full-quarter job destruction: Counts 		= Firm Loss stable jobs: Counts */
FrmJbCS  	=fjf 		 /* Full-quarter employees: Net change 		= Firm Change stable jobs: Net Change */
SepS		=fs 		 /* Full-quarter employees: Flows out 		= Separations stable jobs: Counts */
TurnOvrS  	=ft 		 /* Full Quarter Turnover: Ratio 		= Turnover stable jobs: Ratio */
HirN		=h 		 /* New hires: Counts 		= Hires New: Counts */
HirNS		=h3 		 /* Full-quarter new hires: Counts 		= Hires New stable jobs: Counts */
FrmJbGn  	=jc 		 /* Job creation: Counts 		= Firm Job Gains: Counts */
FrmJbLs  	=jd 		 /* Job destruction: Counts 		= Firm Job Loss: Counts */
FrmJbC  	=jf 		 /* Net job flows: Counts 		= Firm jobs change: Net Change */
EmpTotal  	=m 		 /* Flow employment: Counts 		= Employment reference quarter: Counts */
qwi_ind  	=qwi_industry_code/* Group: QWI NAICS Industry Code 		= Group: QWI NAICS Industry Code */
ownercode  	=qwi_owner_code 	 /* Group: Ownership group code 		= Group: Ownership group code */
ownerfm  	=qwi_owner_codefmt/* Group: Ownership group name 		= Group: Ownership group name */
HirR		=r 		 /* Recalls: Counts 		= Hires Recalls: Counts */
Sep		=s 		 /* Separations: Counts 		= Separations: Counts */

%if ("&sic." = "yes") %then %do;
sicdiv =sic_division  	/* Group: SIC Division code 		= Group: SIC Division code */
%end;

sHirA		=status_a 	/* Status: Accessions: Counts 		= Status: Hires All: Counts */
sEmp		=status_b 	/* Status: Beginning-of-period employees: Counts 		= Status: Employment: Counts */
sEmpEnd  	=status_e 	/* Status: End-of-period employees: Counts 		= Status: Employment end-of-quarter: Counts */
sEmpS		=status_f 	/* Status: Full-quarter employees: Counts 		= Status: Employment stable jobs: Counts */
sHirAS  	=status_fa 	/* Status: Full-quarter employees: Flows in 		= Status: Hires All stable jobs: Counts */
sFrmJbGnS  	=status_fjc 	/* Status: Full-quarter job creation: Counts 		= Status: Firm Gain stable jobs: Counts */
sFrmJbLsS  	=status_fjd 	/* Status: Full-quarter job destruction: Counts 		= Status: Firm Loss stable jobs: Counts */
sFrmJbCS  	=status_fjf 	/* Status: Full-quarter employees: Net change 		= Status: Firm stable jobs change: Net Change */
sSepS		=status_fs 	/* Status: Full-quarter employees: Flows out 		= Status: Separations stable jobs: Counts */
sTurnOvrS  	=status_ft 	/* Status: Full-quarter turnover: Counts 		= Status: Turnover stable jobs: Ratio */
sHirN		=status_h 	/* Status: New hires: Counts 		= Status: Hires New: Counts */
sHirNS  	=status_h3 	/* Status: Full-quarter new hires: Counts 		= Status: Hires New stable jobs: Counts */
sFrmJbGn  	=status_jc 	/* Status: Job creation: Counts 		= Status: Firm Job Gains: Counts */
sFrmJbLs  	=status_jd 	/* Status: Job destruction: Counts 		= Status: Firm Job Loss: Counts */
sFrmJbC  	=status_jf 	/* Status: Net job flows: Counts 		= Status: Firm jobs change: Net Change */
sEmpTotal  	=status_m 	/* Status: Flow employment: Counts 		= Status: Employment reference quarter: Counts */
sHirR		=status_r 	/* Status: Recalls: Counts 		= Status: Hires Recalls: Counts */
sSep		=status_s 	/* Status: Separations: Counts 		= Status: Separations: Counts */
sPayroll  	=status_w1 	/* Status: Total quarterly payroll: Sum 		= Status: Total quarterly payroll: Sum */
sEarnHirAC  	=status_z_dwa 	/* Status: Accessions: Average change in monthly earnings 		= Status: Hires All: Average change in monthly earnings */
sEarnSepC  	=status_z_dws 	/* Status: Separations: Average change in monthly earnings 		= Status: Separations: Average change in monthly earnings */
sNEmpHirA  	=status_z_na 	/* Status: Accessions: Average periods of non-employment 		= Status: Hires All: Average quarters of non-employment */
sNEmpHirN  	=status_z_nh 	/* Status: New hires: Average periods of non-employment 		= Status: Hires New: Average quarters of non-employment */
sNEmpHirR  	=status_z_nr 	/* Status: Recalls: Average periods of non-employment 		= Status: Hire Recalls: Average quarters of non-employment */
sNEmpSep  	=status_z_ns 	/* Status: Separations: Average periods of non-employment 		= Status: Separations: Average periods of non-employment */
sEarnEnd  	=status_z_w2 	/* Status: End-of-period employees: Average monthly earnings 		= Status: Employees end-of-quarter : Average monthly earnings */
sEarnS  	=status_z_w3 	/* Status: Full-quarter employees: Average monthly earnings 		= Status: Employees stable jobs: Average monthly earnings */
sEarnHirAS  	=status_z_wfa 	/* Status: Accessions to full-quarter status: Average monthly earnings 		= Status: Hires All stable jobs: Average monthly earnings */
sEarnSepS  	=status_z_wfs 	/* Status: Separations from full-quarter status: Average monthly earnings 		= Status: Separations stable jobs: Average monthly earnings */
sEarnHirNS  	=status_z_wh3 	/* Status: Full-quarter new hires: Average monthly earnings 		= Status: Hires New stable jobs: Average monthly earnings */
Payroll  	=w1 		/* Total quarterly payroll: Sum 		= Total quarterly payroll: Sum */
EarnHirAC  	=z_dwa 		/* Accessions: Average change in monthly earnings 		= Hires All: Average change in monthly earnings */
EarnSepC  	=z_dws 		/* Separations: Average change in monthly earnings 		= Separations: Average change in monthly earnings */
NEmpHirA  	=z_na 		/* Accessions: Average periods of non-employment 		= Hires All: Average quarters of non-employment */
NEmpHirN  	=z_nh 		/* New hires: Average periods of non-employment 		= Hires New: Average quarters of non-employment */
NEmpHirR  	=z_nr 		/* Recalls: Average periods of non-employment 		= Hire Recalls: Average quarters of non-employment */
NEmpSep  	=z_ns 		/* Separations: Average periods of non-employment 		= Separations: Average periods of non-employment */
EarnEnd  	=z_w2 		/* End-of-period employees: Average monthly earnings 		= Employees end-of-quarter : Average monthly earnings */
EarnS   	=z_w3		/* Full-quarter employees: Average monthly earnings 		= Employees stable jobs: Average monthly earnings */
EarnHirAS  	=z_wfa 		/* Accessions to full-quarter status: Average monthly earnings 		= Hires All stable jobs: Average monthly earnings */
EarnSepS  	=z_wfs 		/* Separations from full-quarter status: Average monthly earnings 		= Separations stable jobs: Average monthly earnings */
EarnHirNS  	=z_wh3 		/* Full-quarter new hires: Average monthly earnings 		= Hires New stable jobs: Average monthly earnings */
;

%mend;
