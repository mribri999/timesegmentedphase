%
%	Time Segmented Phase Extraction:  Example 1
%
%	Please see GitHub mribri999/timesegmentedphase.
%
%	This example loads a sample complex image
%	and the timing for the sampling trajectory in
%	k-space.  Time segments are used to extract the
% 	spatiotemporally accruing phase.


% ==== A) Load Sampling Trajectory (3D cones) and times
load time_kxyz;
disp('Loaded Sample Trajectory and Times');
disp(size(samp_times));


% ==== B) Load Sample Data
% Note pixels are 0.5x0.5x1.5mm, and this is a 336x336x336 matrix.
% Also note that there are actually only 112 z-slices.  So the acquisition
% has anisotropic resolution and FOV.

load sampledata;		% 336x336x336 matrix
disp('Loaded Sample Data');
disp(size(source_image));


% ==== C) Generate Time-Segmented Components 
% This Requires memory... (makes a copy of the 3D image for
% each time segment), but is explicit for understanding the approach.
num_segments=8;							
segment_images = zeros([size(source_image) num_segments]);	% Allocate

for seg=1:num_segments
  segment_images(:,:,:,seg) = time_segment(source_image,samp_times, ...
							seg,num_segments);  
end;


% ==== D) Phase Correct Segments
phase_est = 0*segment_images;	% Allocate to store phase accroal
corr_segments = segment_images;	% Corrected images, start

% -- Define filter for spatial smoothing
kernel_size = [7 7 7]; 	      % Size of the filter kernel
kernel_sigma = kernel_size/2;           % Standard deviation of the Gaussian
smooth_kernel = fspecial3('gaussian', kernel_size, kernel_sigma);

% -- Loop through segments, extracting phase difference
for curr_segment = 1:num_segments
  display_text = sprintf('Correcting Segment %d of %d',curr_segment,num_segments);
  disp(display_text);

  % -- Get image component, and find "delta" phase (accrual since last)
  seg_image = corr_segments(:,:,:,curr_segment);
  seg_delta_phase = angle(corr_segments(:,:,:,curr_segment));

  % -- For 1st segment, phase is the "DC" phase
  % -- For others, correct sign changes, low-pass filter to extract.
  if (curr_segment > 1)
    sign_flip = find(abs(seg_delta_phase)>pi/2);	% Pix to flip
    seg_image(sign_flip) =-seg_image(sign_flip);	% Flip sign

    % -- LPF sign-corrected component to extract delta phase
    smooth_delta_phase = imfilter(seg_image,smooth_kernel,'replicate');
    phase_est(:,:,:,curr_segment)=angle(smooth_delta_phase);
  else
    phase_est(:,:,:,curr_segment)=seg_delta_phase;
  end;

  % -- Display raw and smoothed-corrected phases
  %disp3dmp(cat(1,corr_segments(:,:,:,curr_segment),smooth_delta_phase));

  % -- Remove delta phase from current and all remaining segments
  for phcorr_segment=curr_segment:num_segments
    corr_segments(:,:,:,phcorr_segment)= ...
      corr_segments(:,:,:,phcorr_segment).* ...
	exp(-i*phase_est(:,:,:,curr_segment));
  end;

end;

% ==== E) Combine the corrected segments & display
corrected_image = sum(corr_segments,4);
disp3d(cat(2,source_image,corrected_image));



