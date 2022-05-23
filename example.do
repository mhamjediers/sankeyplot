*******************************************
** Examplary do-file for sankeyplot.ado
* Written by Maik Hamjediers
* Last Update: 23.05.2022
*******************************************


**********Generate Example-data
clear all
set obs 1000

gen edu_0 = _n <= 500
replace edu_0 = 2 if _n > 900

gen edu_1 = runiformint(0,2)

gen edu_2 = _n <= 30 | _n > 600
replace edu_2 = 2 if _n > 950
replace edu_2 = 0 if edu_0 == 2 & edu_2 != 2

gen edu_3 = runiformint(0,2)

expand 2, gen(sex)

lab def edu 0 "Low Edu." 1 "Medium Edu." 2 "High Edu."
lab val edu_0 edu_1 edu_2 edu_3 edu 

tab edu_0 edu_1

********** Show Plot

*Plain plot
sankeyplot edu_0 edu_1
//Legend-Entries are definied via the label of the input-Variables (here label edu of line 12)

*If-option
sankeyplot edu_0 edu_1 if sex == 0

*Relative Frequencies
sankeyplot edu_0 edu_1, percent 

*Bar-Label and its size
sankeyplot edu_0 edu_1, percent blabel blabsize(small)

*Colors
sankeyplot edu_0 edu_1, percent blabel colors(maroon%50 orange%50 navy%50) 

*Any twoway-Option in the option twoway(...)
sankeyplot edu_0 edu_1, percent twoway(legend(r(1)) ///
	xlabel(0 "1st Gen." 1 "2nd Gen.") xtitle("") ///
	title("Educational Mobility between Generations"))

*More than two "Generations/Waves"
sankeyplot edu_0 edu_1 edu_2 edu_3, percent twoway( ///
	legend(r(1) symx(*0.5) region(lc(white))) ///
	xlabel(0 "1st Gen." 1 "2nd Gen." 2 "3rd Gen." 3 "4th Gen.") xtitle("") ///
	ylabel(,angle(0)) ytitle("Relative Frequencies") xsize(10)  ///
	title("Educational Mobility between Generations") graphregion(color(white)))

**** Comments:
*Wide-wormat is needed
*Beware of missings

*any feedback/suggestions/problems is welcomed: maik.hamjediers@hu-berlin.de