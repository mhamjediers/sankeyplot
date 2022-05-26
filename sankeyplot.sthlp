{smcl}
{* *! version 1.0 26may2022}{...}
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

   If data is in long format:

   {cmd:sankeyplot} {var} {it:clustervar} {it:domainvar} {ifin} {cmd:, long} [{help sankeyplot##comopt:{it:options}}]


{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{cmdab:perc:ent}}relative frequencies instead of absolute number of observations{p_end}{...}
{synopt :{cmdab:barw:idth(}#{cmdab:)}}width of bars (default is barwidth(0.1)){p_end}{...}
{synopt :{cmdab:col:ors(}{help colorstyle}list{cmd:)}}list of colors in the order of categories{p_end}{...}
{synopt :{cmdab:flowcol:ors(}{help colorstyle}list{cmd:)}}list of colors in the order of categories for the flows{p_end}{...}
{synopt :{cmdab:opac:ity(}#{cmdab:)}}controls the opacity of all colors{p_end}{...}
{synopt :{cmdab:baropt:ions(}{help barlook_options}{cmdab:)}}change look of bars (applies to all bars){p_end}{...}
{synopt :{cmdab:flowopt:ions(}{help area_options}{cmdab:)}}change look of flows (applies to all flows){p_end}{...}

     {it:Bar labels}
{synopt :{cmdab:blabel(vallabel|catlabel)}}adds labels to bars{p_end}{...}
{synopt :{cmdab:blabsize(}{help textsizestyle}{cmdab:)}}barlabels: size of text{p_end}{...}
{synopt :{cmdab:blabcolor(}{help colorstyle}{cmdab:)}}barlabels: color and opacity of text{p_end}{...}
{synopt :{cmdab:blabformat(}{help %fmt}{cmd:)}}barlabels: format label values per %fmt{p_end}{...}

{synopt :{it:twoway_options}}Any options documented in  {manhelpi twoway_options G-3}{p_end}{...}

{synoptline}
{p2colreset}

{marker description}{...}
{title:Description}


{hi:sankeyplot} creates a sankey diagram, which visualizes flow of the values of {break}  one variable to another. 

In the default setting, the command assumes the data to be in the wide format  {break} (each variable presents a domain). The command takes two or more categorical {break} variables as input, which should represent the same set of values across {break} domains (e.g., waves or generations).

If the data that should be plotted is in the long format (obsverations represent {break} domains), specify the {cmd:long}-option and three variables: the categorical {break} variable that should be plotted, an identifier of the clusters (e.g., pid), {break} and a domain variable (e.g., wave).

{marker comopt}{...}
{title:Options}

{phang}
{cmd:percent} specifies to plot the relative frequencies of the levels of the plotted variables. The default is to plot absolute frequencies.

{phang}
{cmd:barwidth(}{it:#}{cmd:)} specifies the width of the bar. The default is {cmd:barwidth(0.1)}; values greater than 0.5 are not allowed.

{phang}
{cmd:colors({it:colorstylelist})}  specifies the colors and opacity of the bars and flows. List the colors in the increasing order of the values of the plotted variables.

{phang}
{cmd:flowcolors({it:colorstylelist})}  allow to colors and opacity of flows, independently of the option {cmd:colors()}. List the colors in the increasing order of the values of the plotted variables.

{phang}
{cmd:opacity(}{it:#}{cmd:)} specifies the opacity of the colors of bars and flows. The default is {cmd:opacity(80)}.

{phang}
{cmd:baroptions(}{it:barlook_options}{cmd:)} allows most of the {help barlook_options} to change the look of the bars. Note that any specified option in {cmd:baroptions()} affect all bars; specifying for instance {cmd:baroptions(color(navy))} overrides any specification of the above option {cmd:colors()} and depicts all bars in {it:navy}.

{phang}
{cmd:flowoptions(}{it:area_options}{cmd:)} allows most of the {help area_options} to change the look of the flows. Note that any specified option in {cmd:flowoptions()} affect all flows; specifying for instance {cmd:flowoptions(color(navy))} overrides any specification of the above options {cmd:colors()} and {cmd:flowcolors()} and depicts all flows in {it:navy}.

{phang}
{cmd:blabel(vallabel|catlabel)} adds either value-labels or the labels of the plotted categories to all bars. If {cmd:vallabel} and {cmd:percent} are specified, relative frequencies are shown in the bars; otherwise {cmd:vallabel} shows absolute frequencies. {break}
{cmd:blabformat({it:%fmt})}, {cmd:blabsize({it:textsizestyle})}, and {cmd:blabcolor({it:colorstyle})} specify details about how the bar labels are presented. See {help format}, {manhelpi textsizestyle G-4}, and {manhelpi colorstyle G-4}.

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
{phang2}{cmd:. sankeyplot edu_0 edu_1, percent  /// }{p_end}
{phang2}{cmd:.  blabel(vallabel) blabformat(%3.1g) /// }{p_end}
{phang2}{cmd:. 	colors(gs6%70 gs10%70 gs14%70) /// }{p_end}
{phang2}{cmd:. 	legend(r(1) symx(*0.5) region(lc(white))) /// }{p_end}
{phang2}{cmd:. 	xlabel(0 "1st Gen." 1 "2nd Gen.") xtitle("") /// }{p_end}
{phang2}{cmd:. 	ylabel(,angle(0)) ytitle("Relative Frequencies") xsize(7)  /// }{p_end}
{phang2}{cmd:. 	title("Educational Mobility Across Generations") }{p_end}

{pstd}Highlighting the stream in the middle {p_end}
{phang2}{cmd:. {stata "sankeyplot edu_0 edu_1, flowcol(gs12%80 maroon gs12%80)"}}{p_end}

{pstd}Plotting more than two variables {p_end}
{phang2}{cmd:. {stata "sankeyplot edu_0 edu_1 edu_2"}}{p_end}

{pstd}If data is in long format ({stata "sankeyplot_eg 3":{it:click to run}}) {p_end}
{phang2}{cmd:. sankeyplot edu_ id wave, long}{p_end}

{title:Acknowledgements}

Thanks to Daniele Florean for useful comments.


{title:Author}

{pstd}
Maik Hamjediers, Department of Social Sciences, Humboldt-Universität zu Berlin. {browse "mailto:maik.hamjediers@hu-berlin.de"}
{p_end}