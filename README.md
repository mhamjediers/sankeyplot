## sankeyplot, version 1.0

Stata module to create Sankey digramms

Download module in Stata:
> ssc install sankeyplot

Example graph:
![example_graph](https://user-images.githubusercontent.com/36712245/169912249-d910e199-e2c0-42f9-99f4-985c1c56588e.png)


## Description
'sankeyplot' creates a sankey diagram, which visualizes flow of the values of one variable to another. 

In the default setting, the command assumes that the data is given in a wide format  (each variable presents a domain). The command takes two or more categorical variables as input, which should represent the same set of values aross domains (e.g., waves or generations).

If the data that should be plotted is in a long format (obsverations represent domains), specify the long-option and three variables as the input: the categorical variable that should be plotted, an identifier of the observations (e.g., pid), and a domain variable (e.g., wave).

Altough it is most common to visualize flows among variables with the same set of values, specifying two different set of values is also possible. Yet, note that the legend and colors will be based on the variable mentioned in varlist. If two different variables are used it is recommended to use the options blabel(catlabel) and legend(off).


