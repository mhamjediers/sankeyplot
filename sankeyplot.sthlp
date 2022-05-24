{smcl}
{* *! version 0.825 24 May 2022}{...}
{vieweralsosee "[G] graphics" "mansection G graphics"}{...}
{vieweralsosee "" "--"}{...}
{viewerjumpto "Syntax" "sankeyplot##syntax"}{...}
{viewerjumpto "Description" "sankeyplot##description"}{...}
{viewerjumpto "Options" "sankeyplot##comopt"}{...}
{viewerjumpto "Examples" "sankeyplot##examples"}{...}


{hline}
help for {hi:sankeyplot}
{hline}

{title:Title}

{pstd}{hi:sankeyplot} {hline 2} Sankey plot for visualizing flow between two or more domains of categorical variables

{marker:syntax}{...}
{title:Syntax}

{cmd:sankeyplot} {varlist} {ifin} [{cmd:,} {help sankeyplot##comopt:{it:options}}]

{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{cmdab:perc:ent}}relative frequencies instead of absolute number of observations{p_end}{...}
{synopt :{cmdab:barwidth(}#{cmdab:)}}width of bars (default is barwidth(0.1)){p_end}{...}
{synopt :{cmdab:col:ors(}{help colorstyle}list{cmd:)}}list of colors in the order of categories (applying opacity recommended).{p_end}{...}
{synopt :{cmdab:barlwidth(}{help linewidthstyle}{cmd:)}}thickness of outline of bars{p_end}{...}
{synopt :{cmdab:curvelwidth(}{help linewidthstyle}{cmd:)}}thickness of outline of curves in between bars{p_end}{...}
 
     Bar label
{synopt :{cmdab:blabel}}adds labels to bars{p_end}{...}
{synopt :{cmdab:blabformat(}({help %fmt})}format label values per %fmt{p_end}{...}
{synopt :{cmdab:blabsize(}({help textsizestyle})}barlabels: size of text{p_end}{...}
{synopt :{cmdab:blabcolor(}({help colorstyle})}barlabels: color and opacity of text{p_end}{...}

{synopt :{it:twoway_options}}Any options documented in  {manhelpi twoway_options G-3}{p_end}{...}

{synoptline}
{p2colreset}

{marker description}{...}
{title:Description}


{hi:sankeyplot} creates a sankey diagram, which visualizes flow of the values of one variable to another. It takes two or more categorical variables that should represent the same set of values across domains (e.g., waves or generations).


{marker comopt}{...}
{title:Options}

{phang}
{cmd:percent} specifies to plot the relative frequencies of the levels of the plotted variables. The default is to plot absolute frequencies.

{phang}
{cmd:barwidth(}{it:#}{cmd:)} specifies the width of the bar. The default is {cmd:barwidth(0.1)}, with values greater than 0.5 not allowed.

{phang}
{cmd:colors({it:colorstylelist})}  specifies the colors and opacity of the bars and curves. List the colors in the increasing order of the values of the plotted variables.

{phang}
{cmd:barlwidth({it:linewidthstyle})} and {cmd:curvelwidth({it:linewidthstyle})} change the thickness of the outline of the bars and curves respectively. 

{phang}
{cmd:barlabel} adds labels to all bars. If {cmt:percent} is specified, relative frequencies are shown in the bars; otherwise the bars are labeled with absolute frequencies. {cmd:blabformat({it:%fmt})}, {cmd:blabsize({it:textsizestyle})}, and {cmd:blabcolor({it:colorstyle})} specify detailes about the bar labels are presented. See {help format}, {manhelpi textsizestyle G-4}, and {manhelpi colorstyle G-4}.

{phang}
{it:twoway_options} allows for the inclusion of any additional {help twoway_options:graphing options} such as titles, axes, added lines, etc.

{marker examples}{...}
{title:Examples}

{pstd}Setup ({stata "sankeyplot_eg 1":{it:click to run}}) {p_end}
{phang2}{cmd:. clear}{p_end}
{phang2}{cmd:. set obs 987}{p_end}
{phang2}{cmd:. gen edu_0 = _n <= 500}{p_end}
{phang2}{cmd:. replace edu_0 = 2 if _n > 900}{p_end}
{phang2}{cmd:. gen edu_1 = runiformint(0,2)}{p_end}
{phang2}{cmd:. lab def edu 0 "Low Edu." 1 "Medium Edu." 2 "High Edu."}{p_end}
{phang2}{cmd:. lab val edu_0 edu_1 edu}{p_end}

{pstd}Simple run {p_end}
{phang2}{cmd:. {stata "sankeyplot edu_0 edu_1"}}{p_end}

{pstd}Adding options ({stata "sankeyplot_eg 2":{it:click to run}}) {p_end}
{phang2}{cmd:. sankeyplot edu_0 edu_1, percent blabel blabformat(%3.1g) /// }{p_end}
{phang2}{cmd:. 	colors(gs6%50 gs10%50 gs14%50) /// }{p_end}
{phang2}{cmd:. 	legend(r(1) symx(*0.5) region(lc(white))) /// }{p_end}
{phang2}{cmd:. 	xlabel(0 "1st Gen." 1 "2nd Gen.") xtitle("") /// }{p_end}
{phang2}{cmd:. 	ylabel(,angle(0)) ytitle("Relative Frequencies") xsize(7)  /// }{p_end}
{phang2}{cmd:. 	title("Educational Mobility Across Generations") }{p_end}


{pstd}Plotting more than two variables {p_end}
{phang2}{cmd:. {stata "sankeyplot edu_0 edu_1 edu_2"}}{p_end}


{title:Acknowledgements}

Thanks to Daniele Florean for useful comments.


{title:Author}

{pstd}
Maik Hamjediers, Department of Social Sciences, Humboldt-Universität zu Berlin. {browse "mailto:maik.hamjediers@hu-berlin.de"}
{p_end}
