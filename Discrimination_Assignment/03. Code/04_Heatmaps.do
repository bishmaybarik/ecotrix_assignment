/******************************************************************************
File: 04_Heatmaps.do
Purpose: Creating MPCE Heatmaps
Names: Aftab, Bishmay, Manya
******************************************************************************/

clear all

* Importing the district gini csv file
import delimited "$output/Shapefile/dist_gini.csv", clear

* Making all districts lower case
replace district_name = lower(trim(district_name))

* Generating variable column
cap gen id_gini = _n

* Saving the dataset
save "$output/Shapefile/dist_gini.dta", replace

* Changing the directory to shapefile folder

cd "$output/Shapefile/DISTRICT_BOUNDARY" 

* Load the shapefile data and convert it using shp2dta
shp2dta using tamilnadu_final.shp, data(district_data) coordinates(district_coords.dta) genid(id) replace

* Making district_name names into lower cases
use "$output/Shapefile/DISTRICT_BOUNDARY/district_data.dta", clear

* Thoothukkudi has now become Tuticorin
replace District = "Thoothukkudi" if District == "TUTICORIN"
replace District = "The Nilgiris" if District == "N|LGIRIS"

* Making alphabets lower cases
gen district_name = lower(trim(District))

* Generating varible
gen id_shp = _n

tempfile fuzzy_matched

******************* Performing Fuzzy Matching *************************

reclink district_name using "$output/Shapefile/dist_gini.dta", idm(id_shp) idu(id_gini) gen(score)

* There's a faulty matching. Fixing it manually

drop if district_name == "tiruvall@r@r"
drop if district_name == "tiruppatt@r"

******************* Generating Heatmaps ******************************

* Set color scheme with 4 intervals in shades of orange to red
spmap gini_district using district_coords, id(id) fcolor(OrRd) clmethod(custom) ///
    clbreaks(0.12 .23 .28 .34 .40) ocolor(gs6 ..) ///
    title("MPCE Rural Districts Gini Coefficients") legtitle("Gini Coefficient")

* Save the graph as a PNG file in the specified directory
graph export "$figure/stata_tn_graph.png", replace
