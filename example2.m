%
%	Time Segmented Phase Extraction:  Example 2
%
%	Please see GitHub mribri999/timesegmentedphase.
%
%	This example FOLLOWS example1.m, and generates two field maps
%	based on the time segmentation. 
%	1) Using only the first interval (segment 2 - segment 1)
%	2) Using all intervals, with magnitude weighting

field_map1 = phase_est(:,:,:,2);		% Estimate for segment 2

% -- Calculate "weighted" map using magnitudes to weight phase differences
allphasors = abs(segment_images(:,:,:,2:end)).*exp(i*phase_est(:,:,:,2:end));
field_map2 = angle(sum(allphasors,4));

% -- Correct images for Field Map 1 (just use existing time segments)
image_corr_map1 = 0*segment_images;		% Start with "DC"
image_corr_map2 = 0*segment_images;		% Start with "DC"

for segment=1:num_segments
  image_corr_map1(:,:,:,segment) = segment_images(:,:,:,segment) ...
			.*exp(-i*field_map1*(segment-1));
  image_corr_map2(:,:,:,segment) = segment_images(:,:,:,segment) ...
			.*exp(-i*field_map2*(segment-1));
end;


