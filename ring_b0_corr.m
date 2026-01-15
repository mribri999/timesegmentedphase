% function corr_image = ring_b0_corr(source_image,num_rings)
%
%
%	Function does a mostly memory efficient approach to hierarchical
%	deblurring using ring filters (actually spherical shells in 3D), 
%	and removing residual phase to autofocus the image.  The ring
%   filters are usually a good approximation for time-segmentation of 
%   acquired data.
%
%	INPUT:
%		source_image = 3D image (complex x,y,z) to correct.
%		num_rings = number of rings to use.
%	OUTPUT:
%		corr_image = demodulated (corrected) image.
%
%	B. Hargreaves - Nov 2025
%
function [corr_image] = ring_b0_corr(source_image,num_rings)

% -- Setup
ring_overlap = 1;	% How much rings overlap - with Hamming, 1=50%
kernelsize = 7;		% Low-pass kernel for image-domain phase estimates

% -- Allocate variables
corr_image = 0*source_image;			% Allocate corrected image
[xsize,ysize,zsize] = size(source_image); 	% Source sizes.
corr_phase = 0*source_image;			% Corrected phase

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
ring_start = (ring_increment*[0:num_rings-1])-(ring_width);	% Inner kr's
ring_end = ring_start + 2*ring_width;				% Outer kr's


% -- Define filter for spatially smoothing phase to remove
kernel_size = kernelsize*[1 1 1];       % Size of the filter kernel
kernel_sigma = kernel_size/2;           % Standard deviation of the Gaussian
smooth_kernel = fspecial3('gaussian', kernel_size, kernel_sigma);


% -- Filter each ring (time-segment) and extract phase 
for ring=1:num_rings
  fprintf('Correcting ring %d of %d\n',ring,num_rings);
  
  % Step 0 -- Ring filter the image (Time Segmentation)

  % -- Find non-zero points for mask/filter H(k)
  ring_mask =find(k_radius(:)>=ring_start(ring) & k_radius(:)<ring_end(ring));
  
  % -- Hamming window mask to reduce image extent
  ring_filter=0*source_kspace;		% zero except within mask.
  ring_filter(ring_mask) = 0.54-0.46*cos(pi* ...
      (k_radius(ring_mask)-(ring_start(ring)))/ring_width);
 
  % -- Filter data (multiply in k-space) and Fourier Transform
  masked_kspace = ring_filter .* source_kspace;	  
  ring_image = ft3(masked_kspace);

  % -- Phase Extraction and Unwrapping
  if (ring==1)
    % Step 1 -- Remove DC phase
    corr_phase = exp(-i*angle(ring_image));	% Accumulate phase
    corr_image = ring_image.*corr_phase;	% Corrected image
  else
    image_copy = ring_image.*corr_phase;	% Remove prior rings' phase

    % Step 2a - Sign Correction
    % Assume sign changes are due to image harmonic, NOT off-resonance
    sign_change = find(abs(angle(image_copy))>pi/2);	% Points w/ sign change
    image_copy(sign_change)=-image_copy(sign_change);	% Flip signs

    % -- Step 2b - Low-pass Filter
    image_copy = imfilter(image_copy,smooth_kernel,'replicate');	% LPF
    % Note this filters the magnitude image, not just unit-vector phase

    % -- Steps 2c and 3 - Store phase, Remove from component and accumulate	
    % -- Update accumulated phase for next ring.
    corr_phase = corr_phase.* exp(-i*angle(image_copy));   
    corr_image = corr_image + ring_image.*corr_phase;	   % Phase corr

  end;
end;


