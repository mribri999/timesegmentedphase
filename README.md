# Time Segmented Phase Estimation

The basic idea is that if MRI data is sampled over time (since RF pulse), 
such that (1) t(k) and t(-k) are equal and (2) the surrounding samples have
similar time, then the phase over time can be estimated using time segmentation
of the data.

Here is an overview of steps to use this code.  First note that you can get data files (~150MB) from a [shared google folder here](https://drive.google.com/drive/folders/1iPdpgdrvwR8-4gm9VGjoHD1XT3VljDLf?usp=sharing).

## A) Load Sampling Trajectory Time (Gridded)
This is an example 3D cones sampling trajectory, with kx,ky,kz locations, normalized
to +/-0.5 inverse pixels.  Note that the pixel size may vary between x,y and z.  The
samples here are every 2μs, so it is easy to generate the times for the kx,ky,kz.
Included is the sampling time, gridded to a 3D matrix, so that gridding itself is
not necessary here.

## B) Load some Sample Data
Dataset is image-domain, and is complex-valued (simple coil combination).  
It is easily Fourier transformed to k-space.

## C) Generate Time-Segment windows W[k(t)]
The windows here are Hamming windows over time, such that adjacent time windows
add to 1.0, so that after full correction in the image domain, the segments can
be simply added to combine.

## D) Show the Images/Phases for Windowed Time Segments

## E) Demodulate the Low-Resolution Image Phase



