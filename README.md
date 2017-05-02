# Mismatch negativity under ketamine - DCM analysis code
_Code accompanying: Rosch et al (2017) NMDA receptor blockade causes selective prefrontal disinhibition in a roving auditory oddball paradigm_


This repository contains code that can be used to reproduce a dynamic causal modelling analysis for mismatch negativity and repetition suppression event related potentials measured with EEG in healthy probands under the influence of the NMDA receptor blocker ketamine. This code was used for the above manuscript to delineate regionally specific changes in intra-cortical coupling that underlie the observed ketamine effects. 
__When running the code, you will need to download and unzip the folder, and define the home-folder in the ket_housekeeping function__ 

The code runs on [Matlab](https://uk.mathworks.com/) (tested with 2016b) and requires the following freely available packages to run
* [Statistic Parametric Mapping](http://www.fil.ion.ucl.ac.uk/spm/) - This academic freeware implements the DCM analysis applied here 


## Custom routines included in this repository
The repository includes a number of different routines to be run manually to reproduce the different analysis steps included in the manuscript above. Most of these will produce a visual output and are further explained below. 

### Perform sensor space analysis across the different conditions
```
ket_sensorspace
```
This routine performs the 'standard' sensor space ERP analysis based on the data provided (in the SPM-specific MEEG format, in the `~/SPM-ready Data/` folder) The figures it produces were the basis for _Fig 2_ in the manuscript accompanying this code. The first section will identify time periods of significant difference between (a) the deviant and the last standard, and (b) between the first and the last standard, stringently corrected for multiple comparisons. All ERPs and periods of significant difference will be plotted as below.

<img src="https://cloud.githubusercontent.com/assets/12950773/25479254/2bad1094-2b3c-11e7-8104-3b70df384ece.png" alt="Standard and Deviant ERPs" width="500">

The second section will calculate the difference waveform between the first (i.e. deviant) and the last (i.e. standard 36) tone of the sequence (i.e. the mismatch negativity, *MMN*) and test for significant differences in peak amplitude. All testing up until this point is done at the *Fz* electrode, according to literature standards. 

<img src="https://cloud.githubusercontent.com/assets/12950773/25479257/2e7d8844-2b3c-11e7-924b-749be7366b6a.png" alt="Difference wave form (MMN)" width="500">

The last section will plot all EEG channels over time for the three standard - deviant difference waves (left to right: **D1-S2**, **D1-S6**, **D1-S36**); with placebo in the top row and ketamine in the bottom row. This illustrates an overall reduction of the ERPs caused by ketamine across the scalp and for all of the different conditions. 

<img src="https://cloud.githubusercontent.com/assets/12950773/25479259/30c18e52-2b3c-11e7-95ed-5a52201acc1e.png" alt="Scalp topographies" width="500">

### Invert Dynamic Causal Models (DCM) and perform Bayesian Model Reduction (BMR) to explain the effect of tone repetition 
```
ket_dcm
```
This routine will perform a 2-stage DCM inversion for the data described in the section above: In the first instance, a single DCM will be inverted for the repetition effects across grand mean averages of the ERP. This grand mean inversion is saved and posterior estimates of the parameters are then used as priors for inverting individual subject DCMs.
Each participant's ERPs will then be inverted in individual DCMs for the ketamine and the placebo condition separately. The inversion can take approximately *~30 minutes per subject* and drug-condition and should produce the visual output seen below.  

<img src="https://cloud.githubusercontent.com/assets/12950773/25479274/3822e330-2b3c-11e7-9a42-7455810e4e7a.png" alt="DCM Inversion" width="500">

After all models have been inverted, the routine will also display the first principal eigenmodes of the model fits for each of the subjects, again separately for ketamine and placebo-controlled conditions. For best effects, this should be run with [cbrewer](https://uk.mathworks.com/matlabcentral/fileexchange/34087-cbrewer---colorbrewer-schemes-for-matlab) installed to show paired colour codes shown below and corresponding to the colours in the manuscript. 

![Model fits](https://cloud.githubusercontent.com/assets/12950773/25479282/3c1a7a48-2b3c-11e7-884c-b92b5e51c118.png)

Based on the individually inverted (full) DCMs for the placebo condition, we then perform Bayesian model reduction, eliminating redundant model parameters and inferring which parameters are changed by repetition effects. The results will be shown in terms of free energy distribution over the model space, which consists of 3 sets of 8 models (i.e. combinations of the basis functions (3): monophasic decay, phasic response, or both; and synaptic parameters that are modulated (8): no extrinsic, forward, backward, or forward/backward modulations with and without intrinsic modulations). The winning model is that with the highest free energy, which is the full model (i.e. both basis functions, forward, backward and intrinsic effects). 

<img src="https://cloud.githubusercontent.com/assets/12950773/25479263/3389143e-2b3c-11e7-9cc5-f90c39ce0ba4.png" alt="BMR results" width="500">

The estimated parameter values for the reduced model were then averaged across participants (using Bayesian parameter averaging) to show the repetition-dependent parameter changes. 

<img src="https://cloud.githubusercontent.com/assets/12950773/25479268/35e5e6ee-2b3c-11e7-8c83-1e419f293428.png" alt="Parametric effects" width="500">


### Run Parametric Empirical Bayesian (PEB) group analysis to explain the difference between ketamine and placebo
```
ket_peb
```
This routine takes the DCMs inverted at the first level (or the DCMs provided in this repository) and estimates shared group effects across individual DCMs using parametric empirical Bayes. These group effects represent the effect of ketamine in this study design, and are estimated using different combinations of free parameters: broadly this model space for the ketamine effect is divided into modulations of extrinsic (between-source) and intrinsic (within-source) coupling parameters. 
The routine will run the different second level models, and display the free energy distribution over the model space (for Bayesian model comparison). 

<img src="https://cloud.githubusercontent.com/assets/12950773/25479286/3eded5ee-2b3c-11e7-8f54-57cac11f0047.png" alt="BMC at the second level" width="500">

Selecting the winning model (one where only intrinsic connections are allowed to change depending on the drug condition), we then perform Baysian model reduction to remove redundant model parameters and provide the best estimate for which connections are altered by ketamine across all subjects The standard SPM function will provide the following output. 

<img src="https://cloud.githubusercontent.com/assets/12950773/25479289/417e7610-2b3c-11e7-9137-f88ff4a8181c.png" alt="Group effects of ketamine" width="500">

### Simulate the ketamine effects on intrinsic connectivity parameters to visualise the resultant changes
```
ket_simulate
```
In order to further explore the effect of the parameters identified on the PEB analysis we can simulate the model output for a range of parameter combinations. Here we take the grand mean model inversion as the starting pont and then push the STG and IFG inhibitory parameters to the values estimated in the PEB - this shows that much of the measured effect can be reproduced by modulations of just these parameters. 

![Results of model simulation](https://cloud.githubusercontent.com/assets/12950773/25479295/4453ae96-2b3c-11e7-8956-d057002f418c.png)


## Other custom functions
* `ket_housekeeping` - this function defines the folder structures used for the analysis by all the ohter functions
* `ket_bmr_gen_model_space` - this function will generate the model space in terms of forward, backward and intrinsic connection used for DCM analysis at the first level (i.e. the effect of tone repetition)
* `ket_bmr_gen` - this function will generate the DCM structure required for Bayesian model reduction according to the model space in question (without inverting it)
* `ket_dcm_gm` - this function is used to invert a single DCM for the grand mean ERP wave forms - the posteriors of this inversion are subsequently used as the priors for the subject-specific analysis
* `ket_dcm_sgl` - this function will invert DCMs for single subjects, using the posteriors of the group inversion as priors
