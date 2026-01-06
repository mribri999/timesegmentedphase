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


% D) Remove DC phase, and Retain

display_text = sprintf('Correcting DC phase');
disp(display_text);
phcorr = 0*segment_images;
phcorr(:,:,:,1) = angle(segment_images(:,:,:,1));
corr_images = segment_images;
for seg=1:num_segments
  corr_images(:,:,:,seg)=corr_images(:,:,:,seg).*exp(-i*phcorr(:,:,:,1));end;

% E) Phase Correct Other Segments

% -- Define filter for smoothing
kernel_size = [7 7 7]; 	      % Size of the filter kernel
kernel_sigma = kernel_size/2;           % Standard deviation of the Gaussian
smooth_kernel = fspecial3('gaussian', kernel_size, kernel_sigma);

for segcorr = 2:num_segments
  display_text = sprintf('Correcting Segment %d of %d',segcorr,num_segments);
  disp(display_text);

  % -- Get image component, and find "delta" phase (accrual since last)
  seg_image = corr_images(:,:,:,segcorr);
  seg_delta_phase = angle(corr_images(:,:,:,segcorr));
  signcorr = find(abs(seg_delta_phase)>pi/2);			% Pix to flip
  seg_image(signcorr) =-seg_image(signcorr);		 	% Flip sign

  % -- LPF for delta phase
  smooth_delta_phase = imfilter(seg_image,smooth_kernel,'replicate');
  phcorr(:,:,:,segcorr)=angle(smooth_delta_phase);

  % -- Display raw and smoothed-corrected phases
  %disp3dmp(cat(1,corr_images(:,:,:,segcorr),smooth_delta_phase));

  % -- Remove delta phase
  for seg=segcorr:num_segments
    corr_images(:,:,:,seg)=corr_images(:,:,:,seg).* ...
		exp(-i*angle(phcorr(:,:,:,segcorr)));
  end;

end;



