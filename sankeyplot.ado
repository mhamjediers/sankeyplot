*********************************
* Written by Maik Hamjediers 
* sankeyplot.ado Version 0.8
* Last update: 23.05.2022
*********************************

*any feedback/suggestions/problems is welcomed: maik.hamjediers@hu-berlin.de

cap program drop sankeyplot
program define sankeyplot
version 17
syntax varlist(min=2 numeric) [if], [PERCent COLors(string asis) BLABEL BLABSIZE(string) TWOWAYoptions(string asis)]

	quietly {
		
		preserve 
		
		tempfile sankeysave 
		save `sankeysave', replace
		
		*Do it potentially for sevaral waves
		local wave_file = 0
		local var_waves : list sizeof local(varlist)
		while `var_waves' > 1 {
			
			local wave_file = `wave_file' + 1
			
			use `sankeysave', clear
			if "`if'" != "" {
				keep `if'
			}	
			
			gettoken f  varlist : varlist
			clonevar xx_mob0 = `f'
			gettoken s  : varlist
			clonevar xx_mob1 = `s'
			
			bys xx_mob0 xx_mob1: gen xx_obs = _N
			
			if "`blabel'" != "" {
				foreach w of num 0 1 {
					sort xx_mob`w'
					gen xx_n = _n
					bys xx_mob`w' : egen xx_blabpos`w' = mean(xx_n)
					bys xx_mob`w' : gen xx_blabel`w' = _N
					drop xx_n
				}
				local blabel xx_blabel xx_blabpos
			}
			
			if "`percent'" != "" {
				count 
				replace xx_obs = xx_obs / `r(N)' * 100
				if "`blabel'" != "" {
					for any xx_blabel0 xx_blabel1 xx_blabpos1 xx_blabpos0: replace X = X /  `r(N)' * 100
				}
			}

			sort xx_mob0 (xx_mob1)
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

			reshape long xx_mob xx_grp xx_grpl `blabel', i(xx_grpid) j(xx_wave)

			sort xx_grpid xx_wave

			*Making Curves in between
			bys xx_grpid: gen xx_diff = xx_grp[_n+1] - xx_grp if xx_grp[_n+1] != .
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
			
			*Adjusting waves in between to avoid overlap with bars
			bys xx_grpid (xx_wave): replace xx_wave = xx_wave + (0.5 - xx_wave)/10 
			expand 2 if xx_start == 1 | xx_end == 1, gen(bar)
			replace xx_wave = 0 if xx_start == 1 & bar == 1
			replace xx_wave = 1 if xx_end == 1 & bar == 1
			bys bar xx_grpid (xx_wave): gen xx_drop = 1 if bar == 1 & xx_mob != xx_mob[_n+1] & xx_mob != xx_mob[_n-1]
			drop if xx_drop == 1
			drop xx_drop 
			
			tempfile `wave_file'
			save ``wave_file'', replace
	
			local var_waves : list sizeof local(varlist)
		}
		
		
		use `1', clear
		gen xx_wave_int = 1
		*Append potentially multiple waves
		if `wave_file' > 1 {
			foreach w of num 2 (1) `wave_file' {
				append using ``w'', gen(xx_appended)
				replace xx_wave = xx_wave + (`w' - 1) if xx_appended == 1
				replace xx_wave_int = `w' if xx_wave_int == .
				drop xx_appended 
			}
			*Resulting multiple observations of bars in the middle
			bys bar xx_mob xx_wave (xx_wave_int): gen xx_drop = _n if bar == 1
			drop if xx_drop > 1 & xx_drop != .
			drop xx_drop
		}
		
		sort xx_wave_int xx_sorting
			
		***** Drawing the Graph
		
		*Color-Local
		if "`colors'" == "" {
			quietly: tab xx_mob
			local grey_levels = `r(r)'
			local greys = round(13/`grey_levels',1)
			foreach num of numlist 2 (`greys') 13 {
				local colors = "`colors' gs`num'%80"
			}
		}
		
		local xx_lbe : value label xx_mob
		
		local graph_n = 0
		*Range-Plots
		local graphs ""
		local color1 = "`colors'"
		quietly: levelsof xx_mob, local(xx_paths)
		foreach mob of local xx_paths {
			quietly: gettoken col color1:color1
			levelsof xx_wave_int, local(xx_waves)
			foreach w of local xx_waves {
				levelsof xx_grpid if xx_mob == `mob' & xx_start == 1 & bar == 0 & xx_wave_int == `w', local(xx_graphs2)
				foreach id of local xx_graphs2 {
					local graphs "`graphs' (rarea xx_diff_up xx_diff_low xx_wave if xx_grpid == `id' & bar == 0 & xx_wave_int == `w', color(`col') lwidth(vvthin)) "
					local graph_n = `graph_n' + 1
				}
		}
		}
		*Bar-Plots
		quietly: levelsof xx_mob, local(xx_paths)
		foreach mob of local xx_paths {
			gettoken col colors:colors
			local graphs "`graphs' (rbar xx_start_up xx_start_low xx_wave if xx_start == 1 & bar == 1 & xx_mob == `mob' , barwidth(0.1) color(`col') lwidth(thin)) "
			local graph_n = `graph_n' + 1
			local legtext`mob' : label `xx_lbe' `mob'
			local legendlab `legendlab' `graph_n' "`legtext`mob''"
			local graphs "`graphs' (rbar xx_end_up xx_end_low xx_wave if xx_end == 1 & bar == 1 & xx_mob == `mob' , barwidth(0.1) color(`col') lwidth(thin)) "
			local graph_n = `graph_n' + 1
		}
		*Scatter-Plot (label)
		if "`blabel'" != "" { 
			if "`blabsize'" == "" {
				local blabsize normal
			}
			local graphs "`graphs' (scatter xx_blabpos xx_wave if (xx_start == 1 | xx_end == 1) & bar == 1 , m(none) mlabel(xx_blabel) mlabpos(0) mlabsize(`blabsize')) "
			local graph_n = `graph_n' + 1
		}
		twoway `graphs', `twowayoptions' legend(order(`legendlab'))
		
		restore
	}

end


