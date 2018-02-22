


clear all
set obs 100

gen bildung_0 = _n <= 50
replace bildung_0 = 2 if _n > 90

gen bildung_1 = _n <= 30 | _n > 60
replace bildung_1 = 2 if _n > 95
replace bildung_1 = 0 if bildung_0 == 2 & bildung_1 != 2

tab bildung_0 bildung_1 

/* twoway options
legend(order( 1 "Low Edu." 2 "Medium Edu." 5 "High Edu.") r(1)) ///
xlabel(0 "1st Gen." 1 "2nd Gen.") xtitle("") ///
ytitle("", axis(2)) ytitle("Relative Frequencies", axis(1))  ///
title("Educational Mobility between Generations") graphregion(color(white)) 

*by end or start
by(start, title("Educational Mobility between Generations")) graphregion(color(white)) 

*option color
color(dkgreen navy dkorange)

syntax var1 var2, by(end | start) color(list) , legend() title xtitle ytitle axis graphregion etc.
*/


clonevar xx_mob0 = bildung_0
clonevar xx_mob1 = bildung_1

bys xx_mob0 xx_mob1: gen xx_obs = _N

if "`relative'" == "relative" {
quietly: sum xx_obs
replace xx_obs = xx_obs / `r(N)' * 100
}

keep if xx_mob0 != xx_mob0[_n-1] | xx_mob1 != xx_mob1[_n-1]

sort xx_mob0 (xx_mob1)
gen xx_grp0 = xx_obs
replace xx_grp0 = xx_grp0 + xx_grp0[_n-1] if xx_grp0[_n-1] != .
gen xx_grpl0 = 0
replace xx_grpl0 = xx_grpl0 + xx_grp0[_n-1] if xx_grp0[_n-1] != .

sort xx_mob1 (xx_mob0)
gen xx_grp1 = xx_obs
replace xx_grp1 = xx_grp1 + xx_grp1[_n-1] if xx_grp1[_n-1] != .
gen xx_grpl1 = 0
replace xx_grpl1 = xx_grpl1 + xx_grp1[_n-1] if xx_grp1[_n-1] != .

gen xx_grpid = _n

reshape long xx_mob xx_grp xx_grpl, i(xx_grpid) j(xx_wave)

sort xx_grpid xx_wave

*Making Curves in between
bys xx_grpid: gen xx_diff = xx_grp[_n+1] - xx_grp if xx_grp[_n+1] != .
* twoway function pdf = 1/(1+exp(-(x) * 10)) , range( 0.95) /* function for curves*/
gen xx_sorting = _n
expand 10 if xx_diff != 0 & xx_diff != .
sort xx_sorting
replace xx_wave = xx_wave[_n-1] + 0.1 if xx_sorting == xx_sorting[_n-1]
replace xx_diff = . if xx_wave == 0
replace xx_diff = xx_diff * 1/(1+exp(-((xx_wave)-0.5) * 10))

*End-Variables
gen xx_diff_up = xx_grp + xx_diff 
gen xx_diff_low = xx_grpl + xx_diff 
replace xx_diff_up = xx_grp if xx_diff_up == .
replace xx_diff_low = xx_grpl if xx_diff_low == .

*bars for "start" and "end"
replace xx_sorting = _n
gen xx_start = xx_wave == 0
gen xx_end = xx_wave == 1
bys xx_mob xx_start (xx_diff): egen xx_start_low = min(xx_diff_low)
bys xx_mob xx_start (xx_diff): egen xx_start_up = max(xx_diff_up)
bys xx_mob xx_end (xx_diff): egen xx_end_low = min(xx_diff_low)
bys xx_mob xx_end (xx_diff): egen xx_end_up = max(xx_diff_up)

*by-option "start":
gen start = xx_mob if xx_wave == 0
bys xx_grpid: replace start = start[_n-1] if start[_n-1] != .
*for by-option "end":
gen end = xx_mob if xx_wave == 1
bys xx_grpid: egen xx_end_mob = max(end)
replace end = xx_end_mob


sort xx_sorting



*Color-Local
if "`color'" == "" {
quietly: tab xx_mob
local grey_levels = `r(r)'
local greys = round(13/`grey_levels',1)
foreach num of numlist 2 (`greys') 13 {
local color = "`color' gs`num'"
}
}

*Range-Plots
local graphs ""
local color1 = "`color'"
quietly: levelsof xx_mob, local(xx_paths)
foreach mob of local xx_paths {
quietly: gettoken grey color1:color1
levelsof xx_grpid if xx_mob == `mob' & xx_wave == 0, local(xx_graphs2)
foreach id of local xx_graphs2 {
local graphs "`graphs' (rarea xx_diff_up xx_diff_low xx_wave if xx_grpid == `id', color(`grey')) "
}
}
*Bar-Plots
quietly: levelsof xx_mob, local(xx_paths)
foreach mob of local xx_paths {
gettoken grey color:color
local graphs "`graphs' (rbar xx_start_up xx_start_low xx_wave if xx_wave <= 0 & xx_mob == `mob' , barwidth(0.1) lwidth(medthick) color(`grey')) "
local graphs "`graphs' (rbar xx_end_up xx_end_low xx_wave if xx_wave >= 1 & xx_mob == `mob' , barwidth(0.1) lwidth(medthick) color(`grey')) "
}

if "`options'" != "" {
local graphs "`graphs' , `options'"
}

twoway `graphs'


*Ziel-Graph
twoway ///
(rarea xx_diff_up xx_diff_low xx_wave if xx_grpid == 1, color(gs2%80) lwidth(vvthin)) ///
(rarea xx_diff_up xx_diff_low xx_wave if xx_grpid == 2, color(gs6%80) lwidth(vvthin)) ///
(rarea xx_diff_up xx_diff_low xx_wave if xx_grpid == 4, color(gs2%80) lwidth(vthin)) ///
(rarea xx_diff_up xx_diff_low xx_wave if xx_grpid == 5, color(gs6%80) lwidth(vvthin)) ///
(rarea xx_diff_up xx_diff_low xx_wave if xx_grpid == 3, color(gs10%80) lwidth(vvthin)) ///
(rarea xx_diff_up xx_diff_low xx_wave if xx_grpid == 6, color(gs10%80) lwidth(vvthin))  ///
(rbar xx_start_up xx_start_low xx_wave if xx_wave <= 0 & xx_mob == 0 , barwidth(0.1) color(gs2*.8) ) ///
(rbar xx_start_up xx_start_low xx_wave if xx_wave <= 0 & xx_mob == 1 , barwidth(0.1) color(gs6*.8) ) ///
(rbar xx_start_up xx_start_low xx_wave if xx_wave <= 0 & xx_mob == 2 , barwidth(0.1) color(gs10*.8) ) ///
(rbar xx_end_up xx_end_low xx_wave if xx_wave >= 1 & xx_mob == 0 , barwidth(0.1) color(gs2*.8) yaxis(2)) ///
(rbar xx_end_up xx_end_low xx_wave if xx_wave >= 1 & xx_mob == 1 , barwidth(0.1) color(gs6*.8) yaxis(2)) ///
(rbar xx_end_up xx_end_low xx_wave if xx_wave >= 1 & xx_mob == 2 , barwidth(0.1) color(gs10*.8) yaxis(2)),  ///
 legend(order( 1 "Low Edu." 2 "Medium Edu." 5 "High Edu.") r(1)) ///
xlabel(0 "1st Gen." 1 "2nd Gen.") xtitle("") ///
ytitle("", axis(2)) ytitle("Relative Frequencies", axis(1))  ///
title("Educational Mobility between Generations") graphregion(color(white)) 



