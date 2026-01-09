%
%	Time Segmented Phase Extraction:  Example 4
%
%	Please see GitHub mribri999/timesegmentedphase.
%
%	This example FOLLOWS example1.m and plots the 
%	(almost) radially symmetric PSF for different 
%	time-segment windows.

xlocs = 121:136;
yloc = 129;
zloc = 129;
labels = {};


psf = 0*kspace_windows;
for segment = 1:num_segments-3
  psf(:,:,:,segment) = ift3(kspace_windows(:,:,:,segment));
  labels = {labels{:}, sprintf('%d',segment)};
end;

% -- Extract just a line, and smooth
psflines = squeeze(psf(xlocs,yloc,zloc,:));
kPSFlines = fftshift(fft(fftshift(psflines,1),[],1),1);
kPSFlines = [zeros(128,num_segments); kPSFlines; zeros(128,num_segments)];
smoothlines = ifftshift(ifft(ifftshift(kPSFlines,1),[],1),1);
pixnum = [-136:135]*8/128;	% !! Hard coded, sorry!

% -- Plot the PSFs
psfmax = max(smoothlines);
plot(pixnum,real(smoothlines*diag(1./psfmax)));
grid on;
xlabel('Pixel');
ylabel('PSF');
title('Normalized PSF (Radially Symmetric)');
legend(labels{:});


