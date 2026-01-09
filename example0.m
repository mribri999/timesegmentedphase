%
%	Time Segmented Phase Extraction:  Example 0
%
%	Please see GitHub mribri999/timesegmentedphase.
%
%	This is the "fast" example that loads a sample complex image
%	and ONLY assumes a radially symmetric center-out trajectory
%	to just generate k-space windows that correspond to time segments.


load sampledata;				% Patch of a full image.
[corr_image] = ring_b0_corr(source_image,8);
disp3d(cat(1,source_image,corr_image);

