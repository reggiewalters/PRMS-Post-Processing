# PRMS-Post-Processing
4_UMass

This repository contains a Matlab script to perform an empirical post-processing routine to PRMS streamflow outputs modeling flows on the Tuolumne River.
It also contains a sub-routine (CPI.m) that calculates the simple current preciptation index.

The main script (PRMS_Post.m) uses several canned Matlab functions that will require some translation for use in other programming languages, but is simple enough to be generically useful.

The first 50 lines load and subset PRMS streamflow outputs as well as observed temperature and precipitation from the PRMS input file that was used for the model simulation.
