# sankeyplot.ado (Version 0.81)
Stata ado-file to create sankeyplots (flow-charts).
- it takes at least to categorical numerical variables in wide-format as input, but more than two are possible
- beware of potential missing data; either omit them via an "if-specification" or code them as an additional category
- Optional options so far:
  * `if`
  * `PERCent`: Relative frequencies instead of absolute number of observations 
  * `BLABEL`: Show absolute number of observations or relative frequencies as labels of start- and end-bars (default is no blabel)
  * `BLABSIZE()`: Size of blabel-labels (default is blabsize(normal)
  * `BARWIDTH()`: Width of start- and end-bars (default is barwidth(0.1))
  * `COLORS()`: Specify colors; default are grey-tones with 80% opacity 
  * `TWOWAYoptions()`: Specify most of the usual twoway-options
- Example graph:
![example_graph](https://user-images.githubusercontent.com/36712245/169912249-d910e199-e2c0-42f9-99f4-985c1c56588e.png)

# example.do
Stata-do-file with simulated examplary data and syntax
