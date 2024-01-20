![StataMin](https://img.shields.io/badge/stata-2015-blue) ![issues](https://img.shields.io/github/issues/mhamjediers/sankeyplot) ![license](https://img.shields.io/github/license/mhamjediers/sankeyplot) ![Stars](https://img.shields.io/github/stars/mhamjediers/sankeyplot) ![version](https://img.shields.io/github/v/release/mhamjediers/sankeyplot) 

## sankeyplot, version 1.2

Stata module to create Sankey digramms

Available on the Statistical Software Components (SSC). 
To download and install the module in Stata type:
```bash
ssc install sankeyplot
```

### Suggested citation:
Hamjediers, M. (2022): SANKEYPLOT: Stata module to produce Sankey diagramms. [Statistical Software Components S459089](https://econpapers.repec.org/software/bocbocode/S459089.htm), Boston College Department of Economics.


## Description
'sankeyplot' creates a sankey diagram, which visualizes flow of the values of one variable to another. 

In the default setting, the command assumes that the data is given in a wide format  (each variable presents a domain). The command takes two or more categorical variables as input, which should represent the same set of values aross domains (e.g., waves or generations).

If the data that should be plotted is in a long format (obsverations represent domains), specify the long-option and three variables as the input: the categorical variable that should be plotted, an identifier of the observations (e.g., pid), and a domain variable (e.g., wave).

Altough it is most common to visualize flows among variables with the same set of values, specifying two different set of values is also possible. Yet, note that the legend and colors will be based on the variable mentioned in varlist. If two different variables are used it is recommended to use the options blabel(catlabel) and legend(off).

## Exemplary graphs

<img src="https://user-images.githubusercontent.com/36712245/174764980-baf5a813-1e35-4eb6-8f36-668882c37869.png"  width="600" height="400" />
<img src="https://user-images.githubusercontent.com/36712245/174764999-9adb189d-e441-4534-afff-5df9d2a89d67.png"  width="600" height="342" />
<img src="https://user-images.githubusercontent.com/36712245/174765004-178544f0-e2d2-42b8-bfa1-a2fc6db6d395.png"  width="600" height="300" />
