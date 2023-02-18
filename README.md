<p align="center"> frame_postprocess
  
## What is it?
`frame_postprocess` is an open-source python package that facilitates the postprocessing of seismic nonlinear response history analyses (NLRHA) of 2D OpenSees models of moment frames.
    
`frame_postprocess` was the main post-processing tool in following publications:  
  
- *Galvis, F. A. (2022). “Seismic Risk and Post-Earthquake Recovery of Older Tall Buidings with Welded Steel Moment Frames.”Ph.D. thesis. John A. Blume Earthquake Engineering Center, Stanford University.*
  
- *Galvis, F. A., Deierlein, G. G., Yen, W., and Molina Hutt, C., Correal J. F., (2022). Detailed Database of Tall Pre-Northridge Steel Moment Frames for Earthquake Performance Evaluations. (In review).*
  
- *Galvis, F. A., Deierlein, G. G., Zsarnoczay3, A., and Molina Hutt, C., (2022). Seismic screening method for tall pre-Northridge welded steel moment frames based on the collapse risk of a realistic portfolio. (In preparation).*

## What can I use it for?

### Plotting frame elevations  
The package has multiple functions to read and store in the proper format the output files from OpenSees tcl models. These outputs are conveniently stored in .csv files appropiate for the loss assessment package `pelicun` (https://github.com/NHERI-SimCenter/pelicun). Detailed results that include hinge rotations, damage index for welded connections, and panel zone response and stored in a unique HDF file.

### Plotting frame elevations  
The package is capable of plotting 2D frames with any of the following configurations:

- *Setbacks*
- *Podiums*
- *Atriums*
- *Interrupted columns lines*
- *Atypical story heights*
  
The reponse of beam hinges, column hinges, splices, and panel zones can be presented as shown in Figure 1. For welded steel moment frames, the package treats the connection damage index (see SteelFractureDI material in OpenSees) as an engineering demand parameter (EDPs).

<p align="center"> <img src="https://user-images.githubusercontent.com/35354704/219899899-54c45a93-8b23-4cd0-9b0c-e9764732daf1.png" align="middle" height=300 /></p>
<p align="center"> Figure 1. Example collapse mechanisms plotted with frame_postprocessing functions. 

### Plotting EDP responses
The EDPs can be easily plotted in height overlaying relevant statistics for collapse and non-collapse simulations as shown in Figure 2 and Figure 3. 

<p align="center"> <img src="https://user-images.githubusercontent.com/35354704/219899794-80b0b823-202a-4439-b3dd-7b7c0a6a9089.png" align="middle" height=300 /></p>
<p align="center"> Figure 2. Example EDP results for the non-collapse NLRHAs of a building in a scenario earthquake analysis. 

<p align="center"> <img src="https://user-images.githubusercontent.com/35354704/219899775-115b82c0-87aa-4a93-bf6b-20a1e5d21210.png" align="middle" height=300 /></p>
<p align="center"> Figure 3. Example EDP results for the collapse NLRHAs of a building in a scenario earthquake analysis.   

### Calculating fragility curver from multi-stripe analysis 
`frame_postprocess` also includes functions to compute and plot the collapse fragility function of a structure from the results of a multi-stripe analysis (Figure 4).

<p align="center"> <img src="https://user-images.githubusercontent.com/35354704/219899767-674a7127-e7e6-4e3a-8c8f-9361f606ff39.png" align="middle" height=300 /></p>
<p align="center"> Figure 4. Example collapse fragility curve from the results of a multi-stripe analysis.   
  
## How can I get started?

The **Example/1_Raw_NLRHA_results** folder includes raw OpenSees results from a tcl model created by the package galvisf/ModelerWSMFA. These results are collected by the Juyter notebook *Example_frame_postprocess_collect.ipynb* and stored in the folder **Example/2_Collected_NLRHA_results**. Juyter notebook *Example_frame_postprocess_plot.ipynb* generates the figures shown above for the example building and store them in **Example/3_Output_figures**.
More examples can be found on the supplemental material for the publications listed above.

## Installation  

`frame_postprocess` is available at the Python Package Index (PyPI). You can simply install it using `pip` as follows:

```
pip install frame_postprocess
```  
  
## License

`frame_postprocess` is distributed under the MIT license, see [LICENSE](https://opensource.org/licenses/MIT).

## Contact

Francisco Galvis, galvisf@alumni.stanford.edu 
