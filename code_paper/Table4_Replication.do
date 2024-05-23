*Original Author: Gabriel Tourek
*Original File: Table4.do.do
*Filename: Table4_Replication.do
*Original Date of Creation: 8.14.11
*Updated by Mahvish Shaukat on 9.13.11
	*Modified By: Laura Stilwell
		*Update By: Francine Loza
	*Modified on: 4.08.2014
		*Updated on: 6.10.2014


/* ----------------------------------------------------------------------------
 
Replication File for Table4.do of Table 4 of Hanna, Duflo, Greenstone (2015): 
	"Up in Smoke: The Influence of Household Behavior on the Long Run Impact of 
	Improved Cooking Stoves" 
 	
---------------------------------------------------------------------------- */	

clear matrix
clear all 
set more off 

/* 	OBJECTIVES: 
		- Run regressions and output graphs for COad99 and COad99_v2 for adult 
		women, primary cooks, and children

	STRUCTURE: 
		1. Prepare Samples
		2. Regressions and Graphs
		3. Checks
		
*/ 

local var COad99_2 


/* ----------------------------------------------------------------------------
						 	 1. PREPARE SAMPLES
---------------------------------------------------------------------------- */
* Samples: All and Lottery1 excluding Lottery2 winners at endline

use "$CodeData/Merged/ADCO_MoOwnStove_Replication.dta",clear 

* For graphs create matrix for stoveown_mo1 values to use through Lottery1 graphs
preserve
keep stoveown_mo1_6cat
duplicates drop stoveown_mo1_6cat, force
sort stoveown_mo1_6cat
mkmat stoveown_mo1_6cat if stoveown_mo1_6cat!=., matrix(S) //matrix of Lottery1 months owned stove values
mat S2 = (3.5\9.5)
restore
	
* Create tempfiles for samples 1:All 2:Excluding Lottery2 winners at endline

* All primary cooks
keep if primarycook==1 | primarycook_bl==1
tempfile sample2
save `sample2', replace 

* Children Whole Sample
use "$CodeData/Merged/CHCO_MoOwnStove_Replication.dta",clear
rename COch99 COad99
rename COch99_BLfix COad99_BLfix
rename COch99_BLmissing COad99_BLmissing
rename COch99_2 COad99_2
rename COch99_2_BLfix COad99_2_BLfix
rename COch99_2_BLmissing COad99_2_BLmissing
tempfile sample3
save `sample3', replace

/* ----------------------------------------------------------------------------
					       2. REGRESSIONS AND GRAPHS
---------------------------------------------------------------------------- */
* For each sample, run regressions and create graphs
foreach i in  2 3 {	

	use `sample`i'',clear
	if `i'==2 local ctitle "Primary Cooks"
	if `i'==3 local ctitle "Children"
	
	*Generate control group means and store in a local macro to append to tables
	sum `var' if treat==0 [aw=weight], mean 
	local m = r(mean)
	
	* Generate the number of observations in each bin 
	sum `var' if BINYRstoveown_moALL_0to12 ==1
	local bin1 = r(N)
	sum `var' if BINYRstoveown_moALL_13to24==1
	local bin2= r(N)
	sum `var' if BINYRstoveown_moALL_25to36==1
	local bin3= r(N)
	sum `var' if BINYRstoveown_moALL_37to48==1
	local bin4= r(N)

	*Panel A
	reg `var' treat `var'_BLfix `var'_BLmissing v_mo_control* [aw=weight], cluster(hhid_M)
	if `i'==2 outreg2 using "$OutMainT/Table4/Table4", keep(treat) nocons addstat (Control Group Mean, `m') excel title("Table 4A: Red Form Effect of Stove Offer on CO Exposure") ctitle(`ctitle') paren(se) bdec(3) replace
	if `i'!=2 outreg2 using "$OutMainT/Table4/Table4", keep(treat) nocons addstat (Control Group Mean, `m') excel title("Table 4A: Red Form Effect of Stove Offer on CO Exposure") ctitle(`ctitle') paren(se) bdec(3) append
	
	*Panel B
	reg `var' treatXBINYRstoveown_moALL_0to12 - treatXBINYRstoveown_moALL_37to48 `var'_BLfix `var'_BLmissing v_mo_control* [aw=weight], cluster(hhid_M)
	test treatXBINYRstoveown_moALL_0to12 = treatXBINYRstoveown_moALL_13to24
	local f1= r(F)
	local p1= r(p)
	test treatXBINYRstoveown_moALL_0to12 = treatXBINYRstoveown_moALL_25to36
	local f2= r(F)
	local p2= r(p)
	test treatXBINYRstoveown_moALL_0to12 = treatXBINYRstoveown_moALL_37to48
	local f3= r(F)
	local p3= r(p)
	
	#delimit; 
	outreg2 using "$OutMainT/Table4/Table4",  
	addstat(Control Group Mean, `m' , F-stat Yr1=Yr2, `f1', Prob>F Yr1=Yr2, `p1'
	, F-stat Yr1=Yr3, `f2', Prob>F Yr1=Yr3, `p2'
	, F-stat Yr1=Yr4, `f3', Prob>F Yr1=Yr4, `p3'
	, No. of Obs in Bin 1, `bin1'
	, No. of Obs in Bin 2, `bin2'
	, No. of Obs in Bin 3, `bin3'
	, No. of Obs in Bin 4, `bin4'
	) keep(treatXBINYRstoveown_moALL_0to12 treatXBINYRstoveown_moALL_13to24 treatXBINYRstoveown_moALL_25to36 
		treatXBINYRstoveown_moALL_37to48)
	nocons excel ctitle(" ") paren(se) bdec(3) append ;
	#delimit cr

}
