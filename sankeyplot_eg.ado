*! version 1.0  26may2022  Maik Hamjediers
*! Examples for sankeyplot.ado

program define sankeyplot_eg
args ex
	*Generate example data
    if `ex' == 1 {
		clear
		set obs 987
		gen id = _n
		gen edu_0 = _n <= 500
		replace edu_0 = 2 if _n > 900
		gen edu_1 = runiformint(0,2)

		gen edu_2 = _n <= 30 | _n > 600
		replace edu_2 = 2 if _n > 950
		replace edu_2 = 0 if edu_0 == 2 & edu_2 != 2

		lab def edu 0 "Low Edu." 1 "Medium Edu." 2 "High Edu."
		lab val edu_0 edu_1 edu_2 edu
	}
	*Plot with options
	if `ex' == 2 {
		sankeyplot edu_0 edu_1, percent ///
			blabel(vallabel) blabformat(%3.1g) ///
			colors(gs6%70 gs10%70 gs14%70) ///
			legend(r(1) symx(*0.5) region(lc(white))) ///
			xlabel(0 "1st Gen." 1 "2nd Gen.") xtitle("") ///
			ylabel(,angle(0)) ytitle("Relative Frequencies") xsize(7)  ///
			title("Educational Mobility Across Generations")
	}
	*Long
	if `ex' == 3 {
		reshape edu_, i(id) j(wave)
		sankeyplot edu_ id wave , long
	}
end 


*any feedback/suggestions/problems is welcomed: maik.hamjediers@hu-berlin.de