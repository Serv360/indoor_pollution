*File: Table3.do
* Original Filename: Table3.do 
* Author: Gabriel Tourek
    * Updated by: Mahvish Shaukat
	* Updated by: Francine Loza
* Date: 08.14.2011
    * Date: 09.13.2011
	* Date: 06.05.2014


/* ----------------------------------------------------------------------------
 
Replication File for Table3.do of Table 3 of Hanna, Duflo, Greenstone (2015): 
	"Up in Smoke: The Influence of Household Behavior on the 
	Long Run Impact of Improved Cooking Stoves" 
 	
---------------------------------------------------------------------------- */	

clear matrix
clear all 
set more off 
set matsize 10000

**********
** All and Lottery1 exluding Lottery2 winners at endline * 
**********

use "$CodeData/Merged/StoveVar_MoOwnStove_Replication.dta",clear 

** Generate variable for 75% or more of meals gooked on a good stove
gen goodmeals_prop=mealslowpol_good_2/n_meals_lastweek
replace goodmeals_prop=0 if (mealslowpol_good_2==0 & n_meals_lastweek==0)
gen goodmeals75= 0 if !missing(goodmeals_prop)
replace goodmeals75= 1 if goodmeals_prop>=0.75 & !missing(goodmeals_prop)

local yvar "stovebuilt anystove goodcond mealslowpol_good_2 goodmeals75"

* Loop over the outcome variables to generate the control group means and output
local i=1 
foreach y of varlist `yvar' {

		* Generate control group means and store in a local macro, to append to tables
		sum `y' if treat==0 [aw=weight], mean 
		local m = r(mean)
		
		* Generate the number of observations in each bin 
		sum `y' if treatXBINYRstoveown_moALL_0to12 ==1
		local bin1 = r(N)
		sum `y' if treatXBINYRstoveown_moALL_13to24==1
		local bin2= r(N)
		sum `y' if treatXBINYRstoveown_moALL_25to36==1
		local bin3= r(N)
		sum `y' if treatXBINYRstoveown_moALL_37to48==1
		local bin4= r(N)
		
		** PANEL A
		reg `y' treat v_mo_control* [aw=weight], cluster(hhid_M)
		if `i'==1 outreg2 using "$OutMainT/Table3/Table3A", keep(treat) nocons excel paren(se) bdec(3) replace
		if `i'!=1 outreg2 using  "$OutMainT/Table3/Table3A", keep(treat) nocons excel paren(se) bdec(3) append

		** PANEL B
		reg `y' treatXBINYRstoveown_moALL_0to12 - treatXBINYRstoveown_moALL_37to48 v_mo_control* [aw=weight], cluster(hhid_M)  
		
		test treatXBINYRstoveown_moALL_0to12 = treatXBINYRstoveown_moALL_13to24
		local f1= r(F)
		local p1= r(p)
		test treatXBINYRstoveown_moALL_0to12 = treatXBINYRstoveown_moALL_25to36
		local f2= r(F)
		local p2= r(p)
		test treatXBINYRstoveown_moALL_0to12 = treatXBINYRstoveown_moALL_37to48
		local f3= r(F)
		local p3= r(p)
	
		if `i'==1 outreg2 using "$OutMainT/Table3/Table3B",   ///
		addstat(Control Group Mean, `m' , F-stat Yr1=Yr2, `f1', Prob>F Yr1=Yr2, `p1' /// 
		, F-stat Yr1=Yr3, `f2', Prob>F Yr1=Yr3, `p2' ///
		, F-stat Yr1=Yr4, `f3', Prob>F Yr1=Yr4, `p3' ///
		, No. of Obs in Bin 1, `bin1' ///
		, No. of Obs in Bin 2, `bin2' ///
		, No. of Obs in Bin 3, `bin3' ///
		, No. of Obs in Bin 4, `bin4' ///
		) keep (treatXBINYRstoveown_moALL_0to12 treatXBINYRstoveown_moALL_13to24 treatXBINYRstoveown_moALL_25to36 treatXBINYRstoveown_moALL_37to48) ///
		nocons excel paren(se) bdec(3) replace 
				
		if `i'!=1 outreg2 using "$OutMainT/Table3/Table3B",  ///
		addstat(Control Group Mean, `m' , F-stat Yr1=Yr2, `f1', Prob>F Yr1=Yr2, `p1' ///
		, F-stat Yr1=Yr3, `f2', Prob>F Yr1=Yr3, `p2' ///
		, F-stat Yr1=Yr4, `f3', Prob>F Yr1=Yr4, `p3' ///
		, No. of Obs in Bin 1, `bin1' ///
		, No. of Obs in Bin 2, `bin2' ///
		, No. of Obs in Bin 3, `bin3' ///
		, No. of Obs in Bin 4, `bin4' ///
		) keep (treatXBINYRstoveown_moALL_0to12 treatXBINYRstoveown_moALL_13to24 treatXBINYRstoveown_moALL_25to36 treatXBINYRstoveown_moALL_37to48) ///
		nocons excel paren(se) bdec(3) append
		
		local i = `i' + 1
		
}
