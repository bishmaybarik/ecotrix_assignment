/********************************************************************************
File Name: 05_ELMO_Calculation
Purpose: Finding the ELMO Measure for various caste and religion groups - Tamil Nadu
Authors: Aftab, Bishmay, Manya
********************************************************************************/

clear all

********************************************************************************
******************** RELIGION CALCULATION **************************************
********************************************************************************

use "$output/dta/level_01", clear
merge 1:1 hhid using "$output/dta/level_03"
cap drop _merge
merge 1:1 hhid using "$output/mpce/mpce"

keep hhid year sector state district nss_region mpce weights multiplier caste hoh_religion

keep if sector == 1 // This is what I found out after reading the documentation (Saving the rural districts only) // uncomment this 

cap drop if caste == 0
cap drop if hoh_religion == 0

*sorting the dataset by religion and calculating average mpce for each religion.
sort hoh_religion
egen rel_mpce_avg = mean(mpce), by(hoh_religion)

* collapse (mean) mpce, by (hoh_religion)

*sorting mpce in ascending order
sort mpce

tab hoh_religion
tab rel_mpce_avg

* Generating rearranged groups using weights
********************************************************************************
// Step 1: Calculate the total weight for each religion group
bysort hoh_religion: gen rel_total_wt = sum(weights)
by hoh_religion: replace rel_total_wt = rel_total_wt[_N]

// Step 2: Calculate the overall total weight
gen total_weight = sum(weights)
replace total_weight = total_weight[_N] // Ensure total_weight is the same for all observations

// Step 3: Calculate the percentage of weight for each religion group
gen percentage_rel = (rel_total_wt / total_weight) * 100

********************************************************************************
// Step 1: Sort by MPCE to arrange households by expenditure
sort mpce

// Step 2: Calculate cumulative weights to identify cutoffs
cap gen cum_weight = sum(weights)

// Step 3: Define weight cutoffs for each group. WE want the percentage of households to be the same in each group.
tab hoh_religion percentage_rel 

local cutoff1 = 0.000660877 * total_weight
local cutoff2 = 0.002167059 * total_weight
local cutoff3 = 0.006470317 * total_weight
local cutoff4 = 0.01705942 * total_weight
local cutoff5 = 0.02454807 * total_weight
local cutoff6 = 0.1085399 * total_weight
local cutoff7 = total_weight         // Final group covers remaining households

// Step 4: Assign groups based on cumulative weights (we have already sorted by mpce)
cap gen rel_regroup = .


replace rel_regroup = 2 if cum_weight <= `cutoff1'
replace rel_regroup = 1 if cum_weight > `cutoff1' & cum_weight <= `cutoff2'
replace rel_regroup = 3 if cum_weight > `cutoff2' & cum_weight <= `cutoff3'  
replace rel_regroup = 9 if cum_weight > `cutoff3' & cum_weight <= `cutoff4'
replace rel_regroup = 6 if cum_weight > `cutoff4' & cum_weight <= `cutoff5'
replace rel_regroup = 4 if cum_weight > `cutoff5' & cum_weight <= `cutoff6'
replace rel_regroup = 5 if cum_weight > `cutoff6' & cum_weight <= `cutoff7'

// Step 5: Verify the distribution
tab rel_regroup 
tab hoh_religion

// Step 1: Calculate the total weight for each religion group
bysort rel_regroup: gen relre_total_wt = sum(weights)
by rel_regroup: replace relre_total_wt = relre_total_wt[_N]

gen percentage_rel_regroup = (relre_total_wt / total_weight) * 100

tab percentage_rel_regroup
tab percentage_rel 


*now sorting data by `mpce` and `rel_regroup` 
sort mpce rel_regroup

*Identify any duplicate mpce values across groups
bysort mpce: gen same_mpce_r = (_N > 1)   // Creates a flag if `mpce` appears more than once

*Checking if duplicate `mpce` values exist across different groups
bysort mpce (rel_regroup): gen group_overlap_r = (rel_regroup[1] != rel_regroup[_N] & same_mpce_r)

*List results where overlap is detected
list mpce rel_regroup if group_overlap_r == 1 // there were no overlaps found

*Calculating mpce averages according to the new groups
sort rel_regroup
egen rel_regroup_avg = mean(mpce), by(rel_regroup)

* collapse (mean) mpce, by(rel_regroup)
* Calculating Theil's L for rel_mpce_avg (Between group inequality, I_B)

ineqdeco rel_mpce_avg
gen I_bet_r = 0.00362  

* Calculating Theil's L for rel_regroup_avg (Maximum between group inequality, I_B Max)
ineqdeco rel_regroup_avg 
gen I_betmax_r = 0.03575  

*calculating the ELMO
gen elmo_r = I_bet_r/I_betmax_r
di elmo_r


********************************************************************************
******************** CASTE CALCULATION *****************************************
********************************************************************************


sort caste
egen caste_mpce_avg = mean(mpce), by(caste)

*sorting mpce in ascending order
sort mpce


* Generating rearranged groups using weights
********************************************************************************
// Step 1: Calculate the total weight for each religion group
bysort caste: gen caste_total_wt = sum(weights)
by caste: replace caste_total_wt = caste_total_wt[_N]

// Step 2: We have already calculated cum weights to identify cutoffs


// Step 3: Calculate the percentage of weight for each religion group
gen percentage_caste = (caste_total_wt / total_weight) * 100

********************************************************************************
// Step 1: Sort by MPCE to arrange households by expenditure
sort mpce

// Step 2: Calculate cumulative weights to identify cutoffs
cap gen cum_weight = sum(weights)

// Step 3: Define weight cutoffs for each group. WE want the percentage of households to be the same in each group.
tab caste percentage_caste 


local cutoff1 = 0.1245782 * total_weight
local cutoff2 = 0.2122507  * total_weight
local cutoff3 = 0.2201799  * total_weight
local cutoff4 = total_weight   // Final group covers remaining households



tab caste_mpce_avg caste
// Step 4: Assign groups based on cumulative weights (we have already sorted by mpce)
cap gen caste_regroup = .

replace caste_regroup = 2 if cum_weight <= `cutoff1'
replace caste_regroup = 1 if cum_weight > `cutoff1' & cum_weight <= `cutoff2'
replace caste_regroup = 3 if cum_weight > `cutoff2' & cum_weight <= `cutoff3'  
replace caste_regroup = 9 if cum_weight > `cutoff3' & cum_weight <= `cutoff4'

// Step 5: Verify the distribution
tab caste_regroup 
tab caste

// Step 1: Calculate the total weight for each religion group
bysort caste_regroup: gen castere_total_wt = sum(weights) // doubt
by caste_regroup: replace castere_total_wt = castere_total_wt[_N] // doubt

gen percentage_caste_regroup = (castere_total_wt / total_weight) * 100

tab percentage_caste_regroup
tab percentage_caste 

* tab caste
* tab caste_mpce_avg

sort mpce caste_regroup

*Identify any duplicate mpce values across groups
bysort mpce: gen same_mpce_c = (_N > 1)   // Creates a flag if `mpce` appears more than once

*Checking if duplicate `mpce` values exist across different groups
bysort mpce (caste_regroup): gen group_overlap_c = (caste_regroup[1] != caste_regroup[_N] & same_mpce_c)

*List results where overlap is detected
list mpce caste_regroup if group_overlap_c == 1 // there were no overlaps found
*************************



*Calculating mpce averages according to the new groups
sort caste_regroup
egen caste_regroup_avg = mean(mpce), by(caste_regroup)

* collapse (mean) mpce, by(caste_regroup)
* Calculating Theil's L for caste_mpce_avg (Between group inequality, I_B)
ineqdeco caste_mpce_avg 
gen I_bet_c = 0.00295    

* Calculating Theil's L for caste_regroup_avg (Maximum between group inequality, I_B Max)
ineqdeco caste_regroup_avg 
gen I_betmax_c = 0.05571   

*calculating the ELMO
gen elmo_c = I_bet_c/I_betmax_c
di elmo_c
* Viewing the results 

label variable elmo_r "ELMO measure across religions"
label variable elmo_c "ELMO measure across castes"

collapse (mean) elmo_r elmo_c

list elmo_r
list elmo_c
