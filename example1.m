%
%	Demonstrate with example.
%
% A) Load Sampling Trajectory (3D cones) and times

load time_kxyz;
disp('Loaded Sample Trajectory and Times');
disp(size(samp_times));

% B) Load Sample Data
% Note pixels are 0.5x0.5x1.5mm, and this is a 336x336x336 matrix.
% Also note that there are actually only 112 z-slices.  So the acquisition
% has anisotropic resolution and FOV.

load sampledata;		% 336x336x336 matrix
disp('Loaded Sample Data');
disp(size(source_image));


% C) Generate Time-Segmented Components 
%
% Requires memory... but just do several
num_segments=8;
segment_images = zeros([size(source_image) num_segments]);

for seg=1:num_segments
  segment_images(:,:,:,seg) = time_segment(source_image,samp_times, ...
							seg,num_segments);  
end;






