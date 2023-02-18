<p align="center"> frame_postprocess
  
## What is it?
`frame_postprocess` is an open-source python package that facilitates the postprocessing of seismic nonlinear response history analyses (NLRHA) of 2D OpenSees models of moment frames.
    
`frame_postprocess` was the main post-processing tool in following publications:  
  
- *Galvis, F. A. (2022). “Seismic Risk and Post-Earthquake Recovery of Older Tall Buidings with Welded Steel Moment Frames.”Ph.D. thesis. John A. Blume Earthquake Engineering Center, Stanford University.*
  
- *Galvis, F. A., Deierlein, G. G., Yen, W., and Molina Hutt, C., Correal J. F., (2022). Detailed Database of Tall Pre-Northridge Steel Moment Frames for Earthquake Performance Evaluations. (In review).*
  
- *Galvis, F. A., Deierlein, G. G., Zsarnoczay3, A., and Molina Hutt, C., (2022). Seismic screening method for tall pre-Northridge welded steel moment frames based on the collapse risk of a realistic portfolio. (In preparation).*

## What can I use it for?
### Plotting frame elevations  
The package is capable of plotting 2D frames with any of the following configurations:

- *Setbacks*
- *Podiums*
- *Atriums*
- *Interrupted columns lines*
- *Atypical story heights*
  
The reponse of beam hinges, column hinges, splices, and panel zones can be presented as shown in Figure 1. For welded steel moment frames, the package treats the connection damage index (see SteelFractureDI material in OpenSees) as an engineering demand parameter (EDPs).
 
<p align="center"> <img src="https://user-images.githubusercontent.com/35354704/219894152-d1ba1126-5a30-4715-937b-3bb2f000602c.png" align="middle" height=300 /></p>
<p align="center"> Figure 1. Example collapse mechanisms plotted with frame_postprocessing functions. 

### Plotting EDP responses
The EDPs can be easily plotted in height overlaying relevant statistics for collapse and non-collapse simulations as shown in Figure 2 and Figure 3. 

<p align="center"> <img src="https://user-images.githubusercontent.com/35354704/219894246-3f321921-318e-4932-bed0-ac7ca52eb383.png" align="middle" height=300 /></p>
<p align="center"> Figure 2. Example EDP results for the non-collapse NLRHAs of a building in a scenario earthquake analysis. 

<p align="center"> <img src="https://user-images.githubusercontent.com/35354704/219894322-00057ab1-2438-42ad-bb4e-e41d3e5e2acd.png" align="middle" height=300 /></p>
<p align="center"> Figure 3. Example EDP results for the collapse NLRHAs of a building in a scenario earthquake analysis.    
### Calculating fragility curver from multi-stripe analysis 
`frame_postprocess` also includes functions to compute and plot the collapse fragility function of a structure from the results of a multi-stripe analysis (Figure 4).
 
<p align="center"> <img src="https://user-images.githubusercontent.com/35354704/202242564-2c0335b3-5606-4451-9961-990533ad0e56.png" align="middle" height=300 /></p>
<p align="center"> Figure 4. Example collapse fragility curve from the results of a multi-stripe analysis.   
  
## How can I get started?

A Juyter notebook that generates the figures shown above for one building is included to demostrate the use of the package.
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
