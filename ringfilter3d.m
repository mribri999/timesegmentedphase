% function [ring_images,ring_filters,ring_psfs] =
%		ringfilter3d(input_image,num_rings,ring_overlap,ring_aspect)
%
%	Function tries to do autofocusing by reconstrucing images
%	with band-pass "ring" filters in k-space.  In 3D these are
%	spherical shells, or ellipsoidal shells.
%
%	The basic idea is that the PSF of a ring in k-space is 
%	real-valued, so the filtered image should have a phase
%	that corresponds to that component of k-space, but at each
%	pixel.
%
%	INPUT:
%		input_image = 2D complex image
%		num_rings = number of ring filters, 0 to 0.5 inv-pixels
%		ring_overlap = 1 for minimum, >1 for more overlap.
%		ring_aspect = [x,y,z] scale down rings/shells, for example
%				pixel size for 3D cones
%	
%	OUTPUT:
%		ring_images = images, after filtering
%		ring_filters = k-space patterns for ring filters
%		ring_psfs = IFTs of ring filters.
%
%	B.Hargreaves, Nov 2025.

function [ring_images,ring_filters,ring_psfs] = ...
		 ringfocus3d(input_image,num_rings,ring_overlap,ring_aspect)

if nargin < 2 num_rings=15; end;
if nargin < 3 ring_overlap=1; end;
if nargin < 4 ring_aspect=[1 1 1]; end;

[xsize,ysize,zsize] = size(input_image); % -- Get sizes, generally assume same.

% -- Fourier Transform image, define k-space radius
im_kspace = ift3(input_image);
[kx,ky,kz] = meshgrid( -floor(xsize/2):floor((xsize-1)/2), ...
			-floor(ysize/2):floor((ysize-1)/2), ...
			-floor(zsize/2):floor((zsize-1)/2) );

k_radius = sqrt(( kx*ring_aspect(1)).^2 + ...
			(ky*ring_aspect(2)).^2 + ...
			(kz*ring_aspect(3)).^2 );

k_radius = k_radius / max(k_radius(:))*0.5*sqrt(3);  % Scale, assume cube.

% -- Allocate array for images, psfs
ring_images = 0*input_image;		
ring_images(1,1,1,num_rings)=0;		
ring_psfs = ring_images;
ring_filters = ring_images;


% -- Ring Boundaries, including overlap
ring_increment = 0.5/(num_rings-1);		% center-to-center increment
ring_width = ring_increment*ring_overlap;	% edge-to-edge
ring_start = ring_increment*[0:num_rings-1]-(ring_width);
ring_end = ring_start + 2*ring_width;

% -- Do Ring filtering
for ring=1:num_rings
  ring_mask =find(k_radius(:)>=ring_start(ring) & k_radius(:)<ring_end(ring));
  ring_filter=0*im_kspace; 	
  %tt = sprintf('Ring %d.  Ring-2=%d ',ring,ring-2); disp(tt);

  % -- Hamming windowed mask for filter
  ring_filter(ring_mask) = (0.54-0.46*cos(pi* ...
      (k_radius(ring_mask)-(ring_start(ring)))/ring_width));
%	-- Below is to simulate ramp, which moves rings of PSF radially.
%	 .* (((k_radius(ring_mask)-(ring_start(ring)))/ring_width)-1);  % ramp.



  % -- Debug.. show rings 
  %tt=sprintf('Ring %d of %d',ring,num_rings); disp(tt);
  %disp3d(ring_filter);


  masked_kspace = ring_filter .* im_kspace;
  %masked_kspace(ring_mask) = im_kspace(ring_mask);
  ring_images(:,:,:,ring) = ft3(masked_kspace);  

  ring_filters(:,:,:,ring) = ring_filter;
  ring_psfs(:,:,:,ring) = ft3(ring_filter);

end;



