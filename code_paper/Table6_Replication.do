*Original Author: Gabriel Tourek
*Original File:  Table6.do (Death & Birthweight Regressions.do)
*Original Date of Creation: 7.20.11
	*Modified By: Laura Stilwell
		*Modified By: Francine Loza
	*Modified on: 4.20.2014
		*Modified on: 6.11.2014

/* ----------------------------------------------------------------------------
 
Replication File for Table6.do of Table 6 of Hanna, Duflo, Greenstone (2015): 
	"Up in Smoke: The Influence of Household Behavior on the Long Run Impact of 
	Improved Cooking Stoves" 
 	
---------------------------------------------------------------------------- */	

clear matrix
clear all 
set more off 
set mem 500m
set matsize 5000
pause off

*****************************************************************
* Create tempfiles for samples
*****************************************************************

* Primary Cook sample
use "$CodeData/Merged/ADHealth&FEV_MoOwnStove_Replication.dta", clear 
keep if primarycook==1 | primarycook_bl == 1
tempfile sample1
save `sample1', replace

* Children Whole Sample
use "$CodeData/Merged/CHHealth_MoOwnStove_Replication.dta",clear
tempfile sample2
save `sample2', replace

** Primary cooks for health expenditures
use "$CodeData/Merged/HealthExp_MoOwnStove_Replication.dta", clear
keep if primarycook==1
tempfile healthexp_adults
save `healthexp_adults', replace

** Children for health expenditures
use "$CodeData/Merged/HealthExp_MoOwnStove_Replication.dta", clear
keep if kid==1
tempfile healthexp_children
save `healthexp_children', replace

** Child Death Sample
use "$CodeData/Pregnancy/ChildDeaths_all_Replication.dta",clear 
tempfile childdeath
save `childdeath', replace

** Birthweight Sample
use "$CodeData/Merged/Birthweight_all_Replication.dta", clear
tempfile birthweight
save `birthweight', replace

** Primary Cook average treatment 2/3 off are coming from here
use "$CodeData/Merged/Average_Treatment_Effects_Adult_Replication.dta", clear
keep if FEV_primarycook == 1 | primarycook == 1 | FEV_primarycook_bl == 1 | primarycook_bl == 1
tempfile sample1_average
save `sample1_average', replace

*Children average treatment
use "$CodeData/Merged/Average_Treatment_Effects_Children_Replication.dta", clear
tempfile sample2_average
save `sample2_average', replace

keep if (olderchild == 0 | FEV_olderchild == 0)
tempfile sample3_average
save `sample3_average', replace


*****************************************************************
** Regressions and Graphs
*****************************************************************

use `sample1', clear

**********
** FEV variables
**********

* Varlist labels
local fev1_99 "FEV1"
local fvc_99 "FVC"
local fev1fvc_99_label "FEV1/FVC"
local yvar "fev1_99 fev1fvc_99"

local count 1 
foreach y of varlist `yvar' {

	sum `y' if treat==0 [aw=weight], mean 
	local m = r(mean)
	
	reg `y' treat v_mo_control* , cluster(hhid_M)
	if `count'==1 outreg2 treat using "$OutMainT/Table6/Table6A", keep(treat) nocons nor2 excel paren(se) bdec(3) title("Table 6A: Red Form Effect of Program on Health") addstat(Control Group Mean, `m') replace
	if `count'!=1 outreg2 treat using "$OutMainT/Table6/Table6A", keep(treat) nocons nor2 excel paren(se) bdec(3) addstat(Control Group Mean, `m') append

	local count = `count'+1
}			

**********
** Cough or Cold
**********

*Local variable labels
local cold_or_cough_label	"Cold or Cough"
local yvar "cold_or_cough anyillness"

foreach y of varlist `yvar' {

	sum `y' if treat==0 [aw=weight], mean 
	local m = r(mean)
	
	reg `y' treat v_mo_control* , cluster(hhid_M)
	outreg2 using "$OutMainT/Table6/Table6A", keep(treat) nocons nor2 excel paren(se) bdec(3) addstat(Control Group Mean, `m') append

}	

**********
** Health Expenditures
**********

use `healthexp_adults', clear
 
local var "ihealthexpAD_lstmo_99"

*Control group mean
sum `var' if treat==0 , mean 
local m = `r(mean)'
		
reg `var' treat `var'_BLfix `var'_BLmissing v_mo_control* [aw=weight], cluster(hhid_M)
outreg2 using "$OutMainT/Table6/Table6A", keep(treat) nocons nor2 excel paren(se) bdec(3) addstat(Control Group Mean, `m') append


******************************************************************
* Child Regressions
******************************************************************

use `sample2', clear

* Local labels
local bmi_z_99_2_label "Standardized Body Mass Index"
local y "bmi_z_99_2"

**********
* BMI
**********
sum `y' if treat==0 [aw=weight], mean 
local m = r(mean)
	
reg `y' treat v_mo_control*, cluster(hhid_M)
outreg2 using "$OutMainT/Table6/Table6A", keep(treat) nocons nor2 excel paren(se) bdec(3) addstat(Control Group Mean, `m') append

**********
* Other Health Variables
**********

*Local variable labels 
local cough_label	"Cough"
local fever_consult_label 	"Consulted Health Provider about Fever"
local anyillness_label		"Any Illness"

local yvar "cough fever_consult anyillness "

foreach y in `yvar' {
	
	sum `y' if treat==0 [aw=weight], mean 
	local m = r(mean)
	
	reg `y' treat v_mo_control* , cluster(hhid_M)
	outreg2 using "$OutMainT/Table6/Table6A", keep(treat) nocons nor2 excel paren(se) bdec(3) addstat(Control Group Mean, `m')  append

}

**********
** Child Health Expenditures
**********
use `healthexp_children', clear

local var "ihealthexpCH_lstmo_99"

sum `var' if treat==0 [aw=weight], mean 
local m = r(mean)

reg `var' treat `var'_BLfix `var'_BLmissing v_mo_control* [aw=weight], cluster(hhid_M)
outreg2 using  "$OutMainT/Table6/Table6A", keep(treat) nocons nor2 excel paren(se) bdec(3) addstat(Control Group Mean, `m') append


**********
** Child Attendance Variables
**********
use `sample2', clear

*Local variable labels 
local missdays_illness_label "Missed days"
local missdays_illness_num_label "Number of missing days" 

local yvar "missdays_illness_num"

foreach y in `yvar' {
	
	sum `y' if treat==0 [aw=weight], mean 
	local m = r(mean)
	
	reg `y' treat v_mo_control* , cluster(hhid_M)
	outreg2 using "$OutMainT/Table6/Table6A", keep(treat) nocons nor2 excel paren(se) bdec(3) addstat(Control Group Mean, `m')  append

}

**************************************************************
** PANEL C: Pregnancy and Infant Outcomes
**************************************************************

** BIRTH WEIGHT 
use `birthweight', clear

local yvar "birthweight_99"
foreach var in `yvar' {
	sum `var' if treat==0 , mean 
	local m = r(mean)
	reg `var' treat v_mo_control* , cluster(hhid_M)
	outreg2 using "$OutMainT/Table6/Table6A", keep(treat) nocons nor2 excel addstat(Control Group Mean, `m') paren(se) bdec(3) append
}

** CHILD DEATH
use `childdeath', clear

local yvar "inf_mort stillbirth_miscarriage"
foreach var in `yvar' {
	sum `var' if treat==0 , mean 
	local m = r(mean)
	reg `var' treat v_mo_control*, cluster(hhid_M)
	outreg2 using "$OutMainT/Table6/Table6A", keep(treat) nocons nor2 excel addstat(Control Group Mean, `m')  paren(se) bdec(3) append
}


*****************************************************************
** TABLE 6B: REGRESSIONS 
*****************************************************************

** Primary Cook Sample: Average Treatment Effects
use `sample1_average', clear

sum average_var if treat==0 [aw=weights], mean 
local m = r(mean)
	
reg average_var treat average_var_BLfix average_var_BLmissing v_mo_control* [aweight=weights] , cluster(hhid_M)
outreg2 using "$OutMainT/Table6/Table6B", keep(treat) nocons excel addstat(Control Group Mean, `m') ctitle("Primary Cooks") paren(se) bdec(3) replace

reg average_var treatXBINYRstoveown_moALL_0to12 - treatXBINYRstoveown_moALL_37to48 average_var_BLfix average_var_BLmissing v_mo_control* [aweight = weights], cluster(hhid_M)  
outreg2 using "$OutMainT/Table6/Table6B", keep(treat*) nocons excel addstat(Control Group Mean, `m') ctitle("Primary Cooks") paren(se) bdec(3) append

******************************************************************

** Child Sample: Average Treatment Effects
use `sample2_average', clear

sum `y' if treat==0 [aw=weights], mean 
local m = r(mean)
	
reg average_var treat average_var_BLfix average_var_BLmissing v_mo_control* [aweight=weights] , cluster(hhid_M)
outreg2 treat average_var_BLmissing average_var_BLfix using "$OutMainT/Table6/Table6B", keep(treat) nocons excel ctitle("Children") addstat(Control Group Mean, `m') paren(se) bdec(3) append

reg average_var treatXBINYRstoveown_moALL_0to12 - treatXBINYRstoveown_moALL_37to48 average_var_BLfix average_var_BLmissing v_mo_control* [aweight = weights], cluster(hhid_M)  
outreg2 using "$OutMainT/Table6/Table6B", keep(treat*) nocons excel  addstat(Control Group Mean, `m') ctitle("Children") paren(se) bdec(3) append


