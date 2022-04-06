********************************
* #StateOfMind:
* Family Meal Frequency Moderates the Association
*Between Time on Social Networking Sites
* and Well-Being Among U.K. Young Adults
********************************

*Wave3.
*Household file: gross household income before interview.
use "N:\UKHLS\Datasets\c_hhresp.dta", clear
keep c_hidp c_fihhmngrs_dv c_tenure_dv c_ncars   
xtile c_incomeq4 = c_fihhmngrs_dv, nq(5)
sort c_hidp 
save "N:\Temp\File0.dta", replace

*Enumeration file.

use "N:\UKHLS\Datasets\c_indall.dta", clear
keep c_hidp pidp c_sex c_psu c_strata c_newper c_newentrant c_psnenub_xw c_livpar c_newmum c_newdad ///
c_livesp_dv c_cohab_dv c_single_dv 
sort pidp
save "N:\Temp\File1.dta", replace

*W4outcome.

use "N:\UKHLS\Datasets\d_indresp.dta", clear 
keep pidp d_dvage d_scghq2_dv d_indscub_xw d_ypesta d_scwemwba d_scwemwbb d_scwemwbc d_scwemwbd d_scwemwbe d_scwemwbf d_scwemwbg d_psu d_strata
gen base = inrange(d_scwemwba,1,5) & inrange(d_scwemwbb,1,5) & inrange(d_scwemwbc,1,5) & inrange(d_scwemwbd,1,5) & inrange(d_scwemwbe,1,5)
generate d_wemwbs=-2
replace d_wemwbs=(d_scwemwba+d_scwemwbb+d_scwemwbc+d_scwemwbd+d_scwemwbe+d_scwemwbf+d_scwemwbg) if base==1
generate Wave4=1
sort pidp
save "N:\Temp\Wave4.dta", replace

*49739
*Individual respondents.
use "N:\UKHLS\Datasets\c_indresp.dta", clear 
keep c_hidp pidp c_dvage c_sex c_scghqa  c_scghqb  c_scghqc c_scghqd c_scghqe c_scghqf  c_scghqg c_scghqh c_scghqi c_scghqj c_scghqk c_scghql c_scghq1_dv ///
c_netpuse c_closenum c_socweb c_netcht c_plivpar c_indinub_xw c_indscub_xw  c_parmar c_fibenothr_dv  c_sampst ///
c_scflag_dv c_adstatus c_hiqual_dv c_hhorig c_scghq2_dv c_indscub_lw ///
c_lvrel1 c_lvrel9 c_lvrel2 c_lvrel10 c_lvrel3 c_lvrel4 c_lvrel5 c_lvrel6 c_lvrel7 c_lvrel8 c_lvrel96 c_jbstat c_ff_jbstat c_edtype c_famsup c_whorufam c_eatlivu

*Merge in Household Data.
sort c_hidp
merge m:1 c_hidp using "N:\Temp\File0.dta"
keep if _merge==1|_merge==3
drop _merge

sort pidp

*Analysis file.
gen flag1=0
replace flag1=1 if inrange(c_dvage,16,21)
keep if flag1==1
gen flag2=0
replace flag2=1 if c_adstatus==5         /* non-productive */
keep if flag2==1
gen flag3=0
replace flag3=1 if c_indscub_xw!=0
keep if flag3==1
gen flag4=1
replace flag4=0 if (c_netcht==-1 | c_whorufam<0|c_whorufam==5)
replace flag4=0 if (c_socweb==2 & c_netpuse==7)                /* no access to internet */
keep if flag4==1
gen flag5=1
replace flag5=0 if c_plivpar==2       
keep if flag5==1
gen flag6=0
replace flag6=1 if (c_eatlivu>=0 & c_famsup>=0)  & (c_ncars>=0)
keep if flag6==1
merge 1:1 pidp using "N:\Temp\Wave4.dta"
keep if _merge==1|_merge==3
keep if _merge==3
keep if base==1        /* valid wellbeing */

*Demographics.
generate c_agegroup=0
replace c_agegroup=1 if inrange(c_dvage,16,19)
replace c_agegroup=2 if inrange(c_dvage,20,24)

*social media usage.
*belong to a social website.
*tab1 c_socweb

*hours per day.
*tab1 c_netcht
gen c_net_hours=-2
replace c_net_hours=-1 if c_netcht<0
replace c_net_hours=0 if (c_netcht==1|(c_socweb==2))
replace c_net_hours=1 if inrange(c_netcht,2,3)
replace c_net_hours=2 if inrange(c_netcht,4,5)
label define net_hourslbl 0 "none" 1 "less than 4" 2 "4+hours"
label values c_net_hours net_hourslbl

*FamilySupport.
generate c_fam=-11
replace c_fam=1 if c_famsup==1
replace c_fam=2 if (c_famsup==2)
replace c_fam=3 if (c_famsup==3)
label define c_famlbl 1 "most/all" 2 "some" 3 "none" 
label values c_fam c_famlbl

**income
xtile c_incomeq = c_fihhmngrs_dv, nq(5)

generate cars2=-2
replace cars2=-2 if c_ncars<0
replace cars2=0 if c_ncars==0
replace cars2=1 if c_ncars==1
replace cars2=2 if c_ncars>=2
label define carslbl 0 "0" 1 "1" 2 "2+"
label values cars2 carslbl
gen c_agegroup2=0
replace c_agegroup2=1 if inrange(c_dvage,16,18)
replace c_agegroup2=2 if inrange(c_dvage,19,21)
recode c_whorufam (1=1) (2=2) (3=3) (4=4) (5=-2)
mvdecode c_whorufam, mv(-9 -8 -2)

*Analysis.

svyset, clear
svyset[pweight=d_indscub_xw],psu(d_psu) strata(d_strata) singleunit(centered)
replace d_indscub_xw=1 if (d_indscub_xw==0)
*Alpha: Wellbeing.
alpha d_scwemwba d_scwemwbb d_scwemwbc d_scwemwbd d_scwemwbe d_scwemwbf d_scwemwbg, item

*****************************
*Table 1.
*Correlates of SNS use.
****************************

*sample sizes (unweighted)
tab c_net_hours
tab c_socweb c_net_hours
tab c_sex c_net_hours
tab c_agegroup2 c_net_hours
tab c_incomeq c_net_hours
tab cars2 c_net_hours
tab c_eatlivu c_net_hours
recode c_famsup (3=2)                                            
tab c_famsup c_net_hours
recode c_whorufam (4=3)                                         
tab c_whorufam c_net_hours

*Weighted analyses (Table 1: Cyberpsychology: checked).
svy:tab c_net_hours
svy:tab c_socweb c_net_hours, per row  
svy:tab c_sex c_net_hours, per row 
svy:tab c_agegroup2 c_net_hours, per row  
svy:tab c_incomeq c_net_hours, per row  
svy:tab cars2 c_net_hours, per row  
svy:tab c_eatlivu c_net_hours, per row  
svy:tab c_famsup c_net_hours, per row  
svy:tab c_whorufam c_net_hours, per row 


*****************************
*Table 2.
*****************************

*Model 1.
svy:regress d_wemwbs ib1.c_net_hours         
testparm  i.c_net_hours
svy:regress d_wemwbs ib4.c_eatlivu       
testparm  i.c_eatlivu

*Model 2 (Main effects).
svy:regress d_wemwbs ib1.c_net_hours i.c_sex ib4.c_eatlivu c_agegroup2 i.c_incomeq i.cars2    /*Model 2 */
testparm  i.c_net_hours
testparm  i.c_eatlivu

*Model 3 (Interaction).
svy:regress d_wemwbs ib1.c_net_hours##ib4.c_eatlivu i.c_sex  c_agegroup2 i.c_incomeq i.cars2 /*Model 3 */
testparm i.c_eatlivu#i.c_net_hours


*********************
*APPENDIX TABLE A1. 
*(strength of Family support)
*********************

*Model 1.
svy:regress d_wemwbs ib1.c_net_hours         
testparm  i.c_net_hours
svy:regress d_wemwbs i.c_famsup      

*Model 2 (Main effects).
svy:regress d_wemwbs ib1.c_net_hours i.c_sex i.c_famsup c_agegroup2 i.c_incomeq i.cars2    /*Model 2 */
testparm  i.c_net_hours
testparm  i.c_famsup

*Model 3 (Interaction).
svy:regress d_wemwbs ib1.c_net_hours##i.c_famsup i.c_sex  c_agegroup2 i.c_incomeq i.cars2 /*Model 3 */
testparm i.c_famsup#i.c_net_hours


*********************
*APPENDIX TABLE A2. 
*(family identity)
*********************

*Model 1
svy:regress d_wemwbs ib1.c_net_hours         
testparm  i.c_net_hours
svy:regress d_wemwbs i.c_whorufam      
testparm  i.c_whorufam


*Model 2 (Main effects).
svy:regress d_wemwbs ib1.c_net_hours i.c_sex i.c_whorufam c_agegroup2 i.c_incomeq i.cars2    /*Model 2 */
testparm  i.c_net_hours
testparm  i.c_whorufam

*Model 3 (Interaction).
svy:regress d_wemwbs ib1.c_net_hours##i.c_whorufam i.c_sex  c_agegroup2 i.c_incomeq i.cars2 /*Model 3 */
testparm i.c_whorufam#i.c_net_hours











