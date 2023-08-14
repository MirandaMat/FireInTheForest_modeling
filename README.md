# FireInTheForest_modeling

## Introduction
When a model is based on randomness, it is not possible to trust the result of a single simulation because different simulations will certainly produce different results. In this case, it is necessary to run more than one simulation to estimate the average result and its stability. The forest fire model, for example, simulates the spread of fire in a forest, taking into account some areas without vegetation. As the initial state of the cells is chosen randomly, running the simulation again can produce different results.

Investigate the forest fire model and analyze the results related to the duration of the fire, the number of burned cells and the number of forest cells that survive at the end of the simulations. Repeat 50 simulations with different percentages of initial forest ranging from 0% to 100% to analyze the following scenarios:

1) The original model.

2) Using a neighborhood of Moore (8 neighbors), instead of von Neumann.

3) A burning cell is burned after two steps of time, instead of just one.

4) Changing the space to 100x100 cells. Compare this result with the others, assuming that four cells, in this case, occupy the same space as a cell in the original model, which means that the general area is the same in different resolutions.

5) There is a 90% probability that a cell will burn if it finds a neighbor on fire, adding another random component to the model.

Scenarios from two to five are changes independent of the original model. Deliver the source code, as well as a report comparing the different results.
