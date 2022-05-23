# sankeyplot.ado (Version 0.8)
Stata ado-file to create sankeyplot (flow-charts).
- it takes at least to categorical numerical variables in wide-format as input, but more than two are possible
- beware of potential missing data; either omit them via an "if-specification" or code them as an additional category
- Optional options so far:
  * `if`
  * `PERCent`: Relative frequencies instead of absolute number of observations 
  * `BLABEL`: Show absolute number of observations or relative frequencies as labels of start- and end-bars (default is no blabel)
  * `BLABSIZE()`: Size of blabel-labels (default is blabsize(normal)
  * `COLORS()`: Specify colors; default are grey-tones with 80% opacity 
  * `TWOWAYoptions()`: Specify most of the usual twoway-options

![example graph](https://github.com/mhamjediers/sankeyplot/blob/master/example_graph.png?raw=true)

# example.do
Stata-do-file with simulated examplary data and syntax
