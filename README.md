# Mismatch negativity under ketamine - DCM analysis code
_Code accompanying: Rosch et al (2017) NMDA receptor blockade causes regionally specific inhibitory changes during sensory short term learning in a roving auditory oddball paradigm_


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

![Standard and Deviant ERPs](https://cloud.githubusercontent.com/assets/12950773/25479254/2bad1094-2b3c-11e7-8104-3b70df384ece.png)

![Difference wave form (MMN)](https://cloud.githubusercontent.com/assets/12950773/25479257/2e7d8844-2b3c-11e7-924b-749be7366b6a.png)

![Scalp topographies](https://cloud.githubusercontent.com/assets/12950773/25479259/30c18e52-2b3c-11e7-95ed-5a52201acc1e.png)



### Invert Dynamic Causal Models (DCM) and perform Bayesian Model Reduction (BMR) to explain the effect of tone repetition 
```
ket_dcm
```

![DCM Inversion](https://cloud.githubusercontent.com/assets/12950773/25479274/3822e330-2b3c-11e7-9a42-7455810e4e7a.png)

![Model fits](https://cloud.githubusercontent.com/assets/12950773/25479282/3c1a7a48-2b3c-11e7-884c-b92b5e51c118.png)

![BMR results](https://cloud.githubusercontent.com/assets/12950773/25479263/3389143e-2b3c-11e7-9cc5-f90c39ce0ba4.png)

![Parametric effects](https://cloud.githubusercontent.com/assets/12950773/25479268/35e5e6ee-2b3c-11e7-8c83-1e419f293428.png)


### Run Parametric Empirical Bayesian (PEB) group analysis to explain the difference between ketamine and placebo
```
ket_peb
```

![BMC at the second level](https://cloud.githubusercontent.com/assets/12950773/25479286/3eded5ee-2b3c-11e7-8f54-57cac11f0047.png)

![Group effects of ketamine](https://cloud.githubusercontent.com/assets/12950773/25479289/417e7610-2b3c-11e7-9137-f88ff4a8181c.png)

### Simulate the ketamine effects on intrinsic connectivity parameters to visualise the resultant changes
```
ket_simulate
```

![Results of model simulation](https://cloud.githubusercontent.com/assets/12950773/25479295/4453ae96-2b3c-11e7-8956-d057002f418c.png)


## Other custom functions
* `ket_housekeeping` - this function defines the folder structures used for the analysis by all the ohter functions
* `ket_bmr_gen_model_space` - this function will generate the model space in terms of forward, backward and intrinsic connection used for DCM analysis at the first level (i.e. the effect of tone repetition)
* `ket_bmr_gen` - this function will generate the DCM structure required for Bayesian model reduction according to the model space in question (without inverting it)
* `ket_dcm_gm` - this function is used to invert a single DCM for the grand mean ERP wave forms - the posteriors of this inversion are subsequently used as the priors for the subject-specific analysis
* `ket_dcm_sgl` - this function will invert DCMs for single subjects, using the posteriors of the group inversion as priors
