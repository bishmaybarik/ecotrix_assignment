/***************************************************************
File: 03_gini_gen.do
Purpose: Generating Gini Coefficients for every rural district in Tamil Nadu
Authors: Aftab, Bishmay, Manya
****************************************************************/

clear all

* Merging calculated mpce data set and level_01 data 
use "$output/dta/level_01.dta", clear
merge 1:1 hhid using "$output/mpce/mpce.dta"

*Keeping just the relevant variables
keep hhid state district mpce weights sector

keep if state == 33 // (Tamil Nadu's State Code)

* Keeping only the Rural Regions of Tamil Nadu
keep if sector == 1 // This is what I found out after reading the documentation

// Cleaning the districts as well now

gen district_name = ""

replace district_name = "Thiruvallur" if district == 1
replace district_name = "Chennai" if district == 2
replace district_name = "Kancheepuram" if district == 3
replace district_name = "Vellore" if district == 4
replace district_name = "Tiruvannamalai" if district == 5
replace district_name = "Viluppuram" if district == 6
replace district_name = "Salem" if district == 7 
replace district_name = "Namakkal" if district == 8
replace district_name = "Erode" if district == 9
replace district_name = "The Nilgiris" if district == 10
replace district_name = "Dindigul" if district == 11
replace district_name = "Karur" if district == 12
replace district_name = "Tiruchirappalli" if district == 13
replace district_name = "Perambalur" if district == 14
replace district_name = "Ariyalur" if district == 15
replace district_name = "Cuddalore" if district == 16
replace district_name = "Nagapattinam" if district == 17
replace district_name = "Thiruvarur" if district == 18
replace district_name = "Thanjavur" if district == 19
replace district_name = "Pudukkottai" if district == 20
replace district_name = "Sivaganga" if district == 21
replace district_name = "Madurai" if district == 22
replace district_name = "Theni" if district == 23
replace district_name = "Virudhunagar" if district == 24
replace district_name = "Ramanathapuram" if district == 25
replace district_name = "Thoothukkudi" if district == 26
replace district_name = "Tirunelveli" if district == 27
replace district_name = "Kanniyakumari" if district == 28
replace district_name = "Dharmapuri" if district == 29
replace district_name = "Krishnagiri" if district == 30
replace district_name = "Coimbatore" if district == 31
replace district_name = "Tiruppur" if district == 32

* Gini Calculation


* First, sort the data by district
sort district

* Generate a variable to store Gini coefficients for each district
gen gini_district = .

* Loop over each district and calculate the Gini coefficient
levelsof district, local(districts)

foreach d in `districts' {
    * Calculate the Gini for the current district
    // ineqdeco mpce [pweight=weights] if district == `d' // with weights
	ineqdeco mpce if district == `d'
    
    * Store the Gini in the gini_district variable for that district
    replace gini_district = r(gini) if district == `d'
}

keep district_name gini_district
duplicates drop 

save "$output/final/district_gini.dta", replace

export delimited "$output/Shapefile/dist_gini.csv", replace

/*
* Creating Heatmaps

* Step 1: Load the Gini data
use "$output/final/district_gini.dta", clear

* Standardize the district names (convert to lowercase)
gen district_name_low = lower(trim(district_name))

* Step 2: Load the shapefile
shp2dta using "$output/Shapefile/TN_Shapefile/tamil_nadu.shp", ///
    database("$output/Shapefile/TN_Shapefile/tamil_nadu.dbf") ///
    coordinates("$output/Shapefile/TN_Shapefile/tamil_nadu_coord.dta") ///
    genid(id)

use "$output/Shapefile/TN_Shapefile/tamil_nadu.dbf", clear

* Standardize the shapefile district names
gen name_std = lower(trim(Name))

* Step 3: Fuzzy merge Gini data with shapefile data
gen match_score = .
gen matched_name = ""

* Loop over districts in the Gini data to perform fuzzy matching
forvalues i = 1/`=_N' {
    quietly {
        local district_name = district_name[`i']
        qui {
            gen dist_score = -strdist(name_std, "`district_name'")
            sort dist_score
            replace match_score[`i'] = dist_score[1]
            replace matched_name[`i'] = name_std[1]
        }
    }
}

* Merge the best match
merge m:1 matched_name using "/path/to/gini_data.dta"

* Step 4: Plot the heatmap using spmap
spmap gini_district using "$output/Shapefile/TN_Shapefile/tamil_nadu_coord.dta", ///
    id(id) fcolor(Blues) ocolor(black) legend(title("District Gini Coefficients"))
*/

