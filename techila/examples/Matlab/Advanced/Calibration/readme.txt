More information about this example can be found here:

http://www.techilatechnologies.com/multi-asset-calibration/

To use:

Run script 'mainMultiUnderlAssets' in MATLAB

Files
- mainMultiUnderlAssets.m: Main script
- calibrationSettingsMultiUnderlAssets.m: sub-function, accessed from the main file. This function is used to specify all the settings.
- loadInitialParametersMultiUnderlAssets.m: sub-function, accessed from the main file
- calibration.m: sub-function, accessed from the main file
- pricingError.m: sub-function, accessed from calibration.m
- MonteCarloPricing.m: sub-function, accessed from pricingError.m. This function prices options with given parameter values using multiple variance reduction techniques.
- plotresults.m: sub-function, accessed from cloudend. This function updates the graphs used to visualize the result data.

Files under /codes/data, not needed once the data sets have been generated
- IVSurfGeneration.m: used to generate data file for the problem   
- loadSurfaceParameters.m: sub-function ran from IVSurfGeneration.m. 
- priceDataMultiAssets.mat: A data struct for "market implied volatility surfaces" for which models are calibrated. This data is accessed from mainMultiUnderlAssets.m. Generated by IVSurfGeneration.m. 
- generateInitialParameters.m: Generates initial parameter values for 100 assets. 