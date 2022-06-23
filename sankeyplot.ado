*! version 1.0  16june2022  Maik Hamjediers

cap program drop sankeyplot
program define sankeyplot
version 15
	#delimit ;
	syntax varlist(min=2 numeric) [if] [in] , 
	[PERCent 
	MISSing
	FORCE
	LONG
	COLors(string asis) FLOWCOLors(string asis) OPACity(real 80) 
	BARWidth(real 0.1) 
	*
	BLABEL(string) BLABSIZE(string) BLABFORMAT(string asis) BLABCOLOR(string asis)
	FLOWLABEL(string) FLOWLABSIZE(string) FLOWLABFORMAT(string asis) FLOWLABCOLOR(string asis)
	FLOWOPTions(string asis) BAROPTions(string asis)
	]
	;
    #delimit cr

	quietly {
		
		*Check if barwidth less than 0.5
		if `barwidth' >= 0.5 {
			dis in red "option barwidth() incorrectly specified; needs to by smaller than 0.5"
			error 198
		}
		
		*Check if flowalabel correctly specified
		if "`flowlabel'" != "" {
			if "`flowlabel'" != "left" & "`flowlabel'" != "right" {
				dis in red `""option flowlabpos must be either "left" or "right" ""'
				error 198
			}
		}
		
		preserve 

		if "`if'" != "" {
			keep `if'
		}	
		if "`in'" != "" {
			keep `in'
		}	
		
		keep `varlist'
		
		*Check if three variables are definied when using the option long
		local n_vars : list sizeof local(varlist)
		if "`long'" != "" & `n_vars' < 3 {
			error 102
		}
		if "`long'" != "" & `n_vars' > 3 {
			error 103
		}
		if "`long'" != "" & `n_vars' == 3 {
			tokenize `varlist' 
			reshape wide `1', i(`2') j(`3')
			unab varlist: _all
			local varlist: list varlist - 2
		}
		
		*Check how many levels of categorical variables
		if "`force'" == "" {
			if "`long'" != "" {
				tokenize `varlist'
				levelsof `1' 
				if `r(r)' > 7 {
					dis in red "Variable `1' has more than 7 distinct levels, which undermines the readability of the graph."
					dis in red "If you want to use this variable, specify force-option; generating the graph might take long"
					error 134
				}
			}
			else {
				foreach v of local varlist {
					levelsof `v'
					if `r(r)' > 7 {
						dis in red "Variable `v' has more than 7 distinct levels, which undermines the readability of the graph."
						dis in red "If you want to use this variable, specify force-option; generating the graph might take long"
						error 134
					}
				}
			}
		}
		
		*Omitt missings if specified
		local mivarlist : subinstr local varlist " " ", ", all 
		if "`missing'" != "missing" {
			drop if mi(`mivarlist')
		}
		if "`missing'" == "missing" {
			capture assert  mi(`mivarlist') == 0
			if _rc == 9 {
				noisily: dis as text "note: missing values in variables produce unbalanced bars and potential flows into empty bars"
			}
		}
		
		tempfile sankeysave 
		save `sankeysave', replace
		
		*Do it potentially for sevaral waves
		local wave_file = 0
		local var_waves : list sizeof local(varlist)
		while `var_waves' > 1 {
			
			local wave_file = `wave_file' + 1
			
			use `sankeysave', clear
			
			gettoken f  varlist : varlist
			clonevar xx_mob0 = `f'
			gettoken s  : varlist
			clonevar xx_mob1 = `s'
			
			bys xx_mob0 xx_mob1: gen xx_obs = _N
			
			if "`blabel'" != "" {
				*check if either catlabel or vallabel
				if "`blabel'" != "catlabel" & "`blabel'" != "vallabel" {
					dis in red `"option blabel must be either "catlabel" or "vallabel""'
					error 198
				}
				foreach w of num 0 1 {
					sort xx_mob`w'
					gen xx_n = _n
					bys xx_mob`w' : egen xx_blabpos`w' = mean(xx_n)
					*Value label
					bys xx_mob`w' : gen xx_vallabel`w' = _N
					*Category label
					gen xx_catlabel`w' = ""
					levelsof xx_mob`w', local(xx_paths)
					local xx_lbe : value label xx_mob`w'
					foreach mob of local xx_paths {
						local labtext`mob' : label `xx_lbe' `mob'
						replace xx_catlabel`w' = "`labtext`mob''" if xx_mob`w' == `mob'
					}
					drop xx_n
				}
					local blabel_vars xx_blabpos xx_vallabel xx_catlabel
			}
			
			
			if "`percent'" != "" {
				count 
				replace xx_obs = xx_obs / `r(N)' * 100
				if "`blabel'" != "" {
					for any xx_vallabel0 xx_vallabel1 xx_blabpos1 xx_blabpos0: replace X = X /  `r(N)' * 100
				}
			}

			sort xx_mob0 (xx_mob1)
			keep if xx_mob0 != xx_mob0[_n-1] | xx_mob1 != xx_mob1[_n-1]

			*Marking starting points
			sort xx_mob0 (xx_mob1)
			gen xx_grp0 = xx_obs
			replace xx_grp0 = xx_grp0 + xx_grp0[_n-1] if xx_grp0[_n-1] != . // to
			gen xx_grpl0 = 0
			replace xx_grpl0 = xx_grpl0 + xx_grp0[_n-1] if xx_grp0[_n-1] != . // from
			
			*Marking ending points
			sort xx_mob1 (xx_mob0)
			gen xx_grp1 = xx_obs
			replace xx_grp1 = xx_grp1 + xx_grp1[_n-1] if xx_grp1[_n-1] != . // to
			gen xx_grpl1 = 0
			replace xx_grpl1 = xx_grpl1 + xx_grp1[_n-1] if xx_grp1[_n-1] != . //from

			gen xx_grpid = _n //id of each stream

			reshape long xx_mob xx_grp xx_grpl `blabel_vars', i(xx_grpid) j(xx_wave)
			*Cleaning
			drop xx_obs
			keep xx_*
		

			*Making Curves in between
			bys xx_grpid (xx_wave): gen xx_diff = xx_grp[_n+1] - xx_grp if xx_grp[_n+1] != . //difference from starting to end point
			gen xx_sorting = _n
			expand 10 if xx_diff != 0 & xx_diff != . //10 Points for the curves
			sort xx_sorting
			replace xx_wave = xx_wave[_n-1] + 0.1 if xx_sorting == xx_sorting[_n-1]
			replace xx_diff = . if xx_wave == 0
			replace xx_diff = xx_diff * 1/(1+exp(-((xx_wave)-0.5) * 10)) //curve-function

			*Defining rarea for flows
			gen xx_diff_up = xx_grp + xx_diff 
			gen xx_diff_low = xx_grpl + xx_diff 
			replace xx_diff_up = xx_grp if xx_diff_up == .
			replace xx_diff_low = xx_grpl if xx_diff_low == .

			*Defining rbar
			replace xx_sorting = _n
			gen xx_start = xx_wave == 0
			gen xx_end = xx_wave == 1
			bys xx_mob xx_start (xx_diff): egen xx_start_low = min(xx_diff_low)
			bys xx_mob xx_start (xx_diff): egen xx_start_up = max(xx_diff_up)
			bys xx_mob xx_end (xx_diff): egen xx_end_low = min(xx_diff_low)
			bys xx_mob xx_end (xx_diff): egen xx_end_up = max(xx_diff_up)

			sort xx_sorting
			
			*Adjusting the starting and end-point of the waves with respect to the barwidth
			bys xx_grpid (xx_wave): replace xx_wave = xx_wave + (0.5 - xx_wave)/(1/`barwidth')
			expand 2 if xx_start == 1 | xx_end == 1, gen(bar)
			replace xx_wave = 0 if xx_start == 1 & bar == 1
			replace xx_wave = 1 if xx_end == 1 & bar == 1
			bys bar xx_mob xx_wave (xx_start_low xx_start_up): gen xx_drop = 1 if bar == 1 & xx_start_low == xx_start_low[_n-1] & xx_start_up == xx_start_up[_n-1]
			*bys bar xx_mob xx_wave: gen xx_drop = 1 if bar == 1 & xx_mob != xx_mob[_n+1] & xx_mob != xx_mob[_n-1]
			drop if xx_drop == 1
			drop xx_drop 
			
			
			*Generating flowlabels
			if "`flowlabel'" == "right"{
				gen xx_flowlabpos = (xx_diff_up + xx_diff_low) / 2 if xx_end == 1
				gen xx_flowlab = xx_diff_up - xx_diff_low if xx_end == 1
			}
			if "`flowlabel'" == "left"{
				gen xx_flowlabpos = (xx_diff_up + xx_diff_low) / 2 if xx_start == 1
				gen xx_flowlab = xx_diff_up - xx_diff_low if xx_start == 1
			}
			
			tempfile `wave_file'
			save ``wave_file'', replace
	
			local var_waves : list sizeof local(varlist)
		}
		
		*Merging data if more than two domains are specified
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
		lab var xx_wave "Domain"
		
			
		***** Drawing the Graph
		gr_setscheme
		
		*Color-Local
		if "`colors'" != "" { // filling up, if not enough specified
			local n_col : list sizeof local(colors)
			local n_col = `n_col' + 1
			levelsof xx_mob
			foreach c of numlist `n_col' (1) `r(r)' {
				local colors = "`colors' `.__SCHEME.color.p`c''%`opacity'"
			}
		}
		if "`colors'" == "" {
			levelsof xx_mob
			foreach c of numlist 1 (1) `r(r)' {
				local colors = "`colors' `.__SCHEME.color.p`c''%`opacity'"
			}
		}
		if "`flowcolors'" != "" { // filling up, if not enough specified
			local n_col : list sizeof local(flowcolors)
			local n_col = `n_col' + 1
			levelsof xx_mob
			foreach c of numlist `n_col' (1) `r(r)' {
				local flowcolors = "`flowcolors' `.__SCHEME.color.p`c''%`opacity'"
			}
		}
		if "`flowcolors'" == "" {
			local flowcolors "`colors'"
		}
		
		*Default line width of flows should be vvthin:
		if "`flowoptions'" == "" {
			local flowoptions "lwidth(vvthin)"
		}
		else {
			if regexm(`"""`flowoptions'""', "lc") == 0  ///
			&  regexm(`"""`flowoptions'""', "lw") == 0  ///
			&  regexm(`"""`flowoptions'""', "lp") == 0 ///
			&  regexm(`"""`flowoptions'""', "la") == 0 ///
			&  regexm(`"""`flowoptions'""', "lsty") == 0  {
				local flowoptions `flowoptions' lwidth(vvthin)
			}
		}
		
		local graph_n = 0
		
		*Range-Plots
		local graphs ""
		quietly: levelsof xx_mob, local(xx_paths)
		foreach mob of local xx_paths {
			quietly: gettoken col flowcolors:flowcolors
			levelsof xx_wave_int, local(xx_waves)
			foreach w of local xx_waves {
				levelsof xx_grpid if xx_mob == `mob' & xx_start == 1 & bar == 0 & xx_wave_int == `w', local(xx_graphs2)
				foreach id of local xx_graphs2 {
					local graphs "`graphs' (rarea xx_diff_up xx_diff_low xx_wave if xx_grpid == `id' & bar == 0 & xx_wave_int == `w', color(`col') `flowoptions' ) "
					local graph_n = `graph_n' + 1
				}
			}
		}
		*Bar-Plots
		quietly: levelsof xx_mob, local(xx_paths)
		foreach mob of local xx_paths {
			gettoken col colors:colors
			local graphs "`graphs' (rbar xx_start_up xx_start_low xx_wave if xx_start == 1 & bar == 1 & xx_mob == `mob' , barwidth(`barwidth') color(`col') `baroptions' ) "
			local graph_n = `graph_n' + 1
			local xx_lbe : value label xx_mob
			if "`xx_lbe'" != "" {
				local legtext`mob' : label `xx_lbe' `mob'
				local legendlab `graph_n' "`legtext`mob''" `legendlab' 
			}
			else {
				local legendlab `graph_n' "`mob'" `legendlab' 

			}
			
			local graphs "`graphs' (rbar xx_end_up xx_end_low xx_wave if xx_end == 1 & bar == 1 & xx_mob == `mob' , barwidth(`barwidth') color(`col') `baroptions' ) "
			local graph_n = `graph_n' + 1
		}
		*Scatter-Plot (label)
		*blabel
		if "`blabel'" != "" { 
			if "`blabsize'" == "" {
				local blabsize medium
			}
			if "`blabformat'"=="" {
				local blabformat %9.2g
			}
			if "`blabcolor'"=="" {
				local blabcolor black
			}
			local graphs "`graphs' (scatter xx_blabpos xx_wave if (xx_start == 1 | xx_end == 1) & bar == 1 , m(none) mlabel(xx_`blabel') mlabpos(0) mlabformat(`blabformat') mlabsize(`blabsize') mlabcolor(`blabcolor')) "
			local graph_n = `graph_n' + 1
		}
		*flowlabel
		if "`flowlabel'" != "" { 
			if "`flowlabsize'" == "" {
				local flowlabsize small
			}
			if "`flowlabformat'"=="" {
				local flowlabformat %9.2g
			}
			if "`flowlabcolor'"=="" {
				local flowlabcolor black
			}
			if "`flowlabel'" == "left" {
				local mlabpos "right"
			}
			if "`flowlabel'" == "right" {
				local mlabpos "left"
			}
			local graphs "`graphs' (scatter xx_flowlabpos xx_wave if (xx_start == 1 | xx_end == 1) & bar != 1, m(none) mlabel(xx_flowlab) mlabpos(`mlabpos') mlabformat(`flowlabformat') mlabsize(`flowlabsize') mlabcolor(`flowlabcolor')) "
			local graph_n = `graph_n' + 1
		}
		
		*xlabel
		if regexm(`"`options'"', "xlabel") == 0 {
			levelsof xx_wave if bar == 1, local(xlabel)
			local options `options' xlabel(`xlabel')
		}
		
		twoway `graphs', `options' legend(order(`legendlab')) 
		
		restore
	}

end


