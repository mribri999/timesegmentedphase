# Time Segmented Phase Estimation

The basic idea is that if MRI data is sampled over time (since RF pulse), 
such that (1) t(k) and t(-k) are equal and (2) the surrounding samples have
similar time, then the phase over time can be estimated using time segmentation
of the data.

Here is an overview of steps to use this code.

## A) Load a Sampling Trajectory
This is an example 3D cones sampling trajectory, with kx,ky,kz locations, normalized
to +/-0.5 inverse pixels.  Note that the pixel size may vary between x,y and z.  The
samples here are every 2μs, so it is easy to generate the times for the kx,ky,kz.

## B) Load some Sample Data
Dataset is image-domain, and is complex-valued (simple coil combination).  

## C) Generate a Gridded t(k) 

