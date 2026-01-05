% function [corr_image,ex_field_map]=ring_b0_corr
%		(source_image,num_rings,sample_kradius,sample_times,field_map)
%
%	Function does a mostly memory efficient approach to hierarchical
%	deblurring using ring filters (actually spherical shells in 3D), 
%	and removing residual phase to autofocus the image.
%
%	If sample_kradius and sample_times are provided, then a field map
%	is extracted by averaging the unwrapped phase changes at 
%	each ring, for each pixel.
%
%	If a field map is additionally provided then the function
%	INSTEAD uses the field map to unwrap the rings, which is basically
%	the time-segmented correction proposed by Noll 1991.
%
%	INPUT:
%		source_image = 3D image to correct.
%		num_rings = number of rings to use.
%		sample_kradius, sample_times = "t(kr)" trajectory
%		field_map = field map in Hz
%	OUTPUT:
%		corr_image = demodulated (corrected) image.
%		ex_field_map = extracted field map.
%
%	B. Hargreaves - Nov 2025
%
function [corr_image,ex_field_map] = ...
    ring_b0_corr(source_image,num_rings,sample_kradius,sample_times,field_map)

% -- Modes
extract_field_map = (nargin >=4 & nargout > 1);	% Extract field-map from data
use_field_map = (nargin >=5);			% Use provided field map,
						% (time-segmented B0 corr).
% -- Setup
ring_overlap = 1;	% How much rings overlap - with Hamming, 1=50%
kernelsize = 9;		% Low-pass kernel for image-domain phase estimates

% -- Allocate variables
corr_image = 0*source_image;			% Allocate corrected image
[xsize,ysize,zsize] = size(source_image); 	% Source sizes.
corr_phase = 0*source_image;			% Corrected phase
ex_field_map = 0*source_image;			% Extracted field map (if done)

% -- Fourier Transform image, define k-space radius
source_kspace = ift3(source_image);	
[ky,kx,kz] = meshgrid( -floor(ysize/2):floor((ysize-1)/2), ...
                        -floor(xsize/2):floor((xsize-1)/2), ...
                        -floor(zsize/2):floor((zsize-1)/2) );

% -- Normalized radius in all directions, for anisotropic resolution.
ring_aspect=[1 ysize/xsize zsize/xsize];
k_radius = sqrt(	(kx/ring_aspect(1)).^2 + ...
                        (ky/ring_aspect(2)).^2 + ...
                        (kz/ring_aspect(3)).^2 );
k_radius = 0.5*k_radius/(max(ky(:)/ring_aspect(2)));  % kmax<0.5 (cones/spiral)


% -- Define Ring Boundaries, including overlap
ring_increment = 0.5/(num_rings-1);             % center-to-center increment
ring_width = ring_increment*ring_overlap;       % edge-to-edge
ring_start = ring_increment*[0:num_rings-1]-(ring_width);	% Inner kr's
ring_end = ring_start + 2*ring_width;				% Outer kr's


% -- Define filter for spatially smoothing phase to remove
kernel_size = kernelsize*[1 1 1];       % Size of the filter kernel
kernel_sigma = kernel_size/2;           % Standard deviation of the Gaussian
smooth_kernel = fspecial3('gaussian', kernel_size, kernel_sigma);



% -- Filter each ring, then unwrap phase (main loop!)
for ring=1:num_rings
  message = sprintf('Correcting ring %d of %d',ring,num_rings);
  disp(message);

  % Step 0 -- Ring filter the image

  % -- Find non-zero points for mask/filter H(k)
  ring_mask =find(k_radius(:)>=ring_start(ring) & k_radius(:)<ring_end(ring));
  
  % -- Hamming window mask to reduce image extent
  ring_filter=0*source_kspace;		% zero except within mask.
  ring_filter(ring_mask) = 0.54-0.46*cos(pi* ...
      (k_radius(ring_mask)-(ring_start(ring)))/ring_width);
 
  % -- Filter data (multiply in k-space) and Fourier Transform
  masked_kspace = ring_filter .* source_kspace;	  
  ring_image = ft3(masked_kspace);

  % -- For field-map extraction or application, calculate "ring time"
  if (extract_field_map) | (use_field_map)
    krad_mask = find( sample_kradius(:)>=ring_start(ring) & ...  
			sample_kradius(:)<ring_end(ring));
    krad_filter = 0* sample_kradius;		% 
    krad_filter(krad_mask) = 0.54-0.46*cos(pi* ...
      (sample_kradius(krad_mask)-(ring_start(ring)))/ring_width);
    ring_sample_times = sample_times(krad_mask);
    ring_time(ring) = mean(ring_sample_times(:)); % --Time for this ring
						  %   (could hamming filter?)
    message=sprintf(' Ring time is %g sec',ring_time(ring)); disp(message);
  end;
			
  % Step 1 -- Remove DC phase
  if (ring==1)
    corr_phase = exp(-i*angle(ring_image));	% Accumulate phase
    corr_image = ring_image.*corr_phase;	% Corrected image
  else
    image_copy = ring_image.*corr_phase;	% Remove prior rings' phase

    if (use_field_map)
      % -- Phase since last ring.
      corr_phase = corr_phase.* ...
		exp(-i*field_map*(ring_time(ring)-ring_time(ring-1)));

    else		
      % Assume sign changes are due to image harmonic, NOT off-resonance
      sign_change = find(abs(angle(image_copy))>pi/2);	% Points w/ sign change
      image_copy(sign_change)=-image_copy(sign_change);	% Flip signs
      image_copy = imfilter(image_copy,smooth_kernel,'replicate');	% LPF
	% Note this filters the magnitude image, not just unit-vector phase
	
      if (extract_field_map) 	% -- Track phase (last ring) for field map
        ex_field_map = ex_field_map + angle(image_copy.*corr_phase) ...
				/(ring_time(ring)-ring_time(ring-1));
      end;

      % -- Update accumulated phase for next ring.
      corr_phase = corr_phase.* exp(-i*angle(image_copy));   
    end;

    % -- remove phase and add this ring image to corrected image
    corr_image = corr_image + ring_image.*corr_phase;	   % Phase corr

  end;
end;

% -- Field map extraction is still being tested!
if (extract_field_map)
  ex_field_map = ex_field_map / (num_rings-1) / (2*pi);	% Average (Hz)
end;


