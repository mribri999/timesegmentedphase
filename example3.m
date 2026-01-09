%
%	Time Segmented Phase Extraction:  Example 3
%
%	Please see GitHub mribri999/timesegmentedphase.
%
%	This example FOLLOWS example1.m and example2.m, 
%	and reproduces a figure	that shows the process of 
%	the phase extraction and correction.

roi_x = 65:256;	% X range to show
roi_y = 33:224;	% Y range to show
slice = 148;	% Slice to show
midslice = 129;



segment_show = 1:num_segments-1;	% Show segments...

num_columns = 10;	% For figure
imax = max(abs(source_image(:)))/2;

subaxes = tight_subplot(length(segment_show),num_columns, ...
                                [.02 .01],[.01 .04],[.01 .01]);

for row = 1:length(segment_show)
  axes(subaxes(num_columns*(row-1)+1));
  dispim(squeeze(kspace_windows(:,:,midslice,segment_show(row))));
  ptitle = sprintf('W_%d(k)',segment_show(row));
  title(ptitle); axis off;

  % Segment Magnitude
  axes(subaxes(num_columns*(row-1)+2));
  dispim(squeeze(segment_images(roi_x,roi_y,slice,segment_show(row))),0,imax);
  ptitle = sprintf('Magnitude m_%d(r)',segment_show(row));
  title(ptitle); axis off;

  % Incremental Segment Phase
  axes(subaxes(num_columns*(row-1)+3));
  if (segment_show(row)==1)
    dispangle(exp(i*squeeze(phase_est(roi_x,roi_y,slice,1))));
  else
    dispangle(squeeze(segment_images(roi_x,roi_y,slice,segment_show(row)) ...
	.* conj( segment_images(roi_x,roi_y,slice,segment_show(row)-1) )));
  end
  ptitle = sprintf('Incremental Phase');
  title(ptitle); axis off;

  % Sign-Corrected, Low-Pas Filtered Incremental Phase
  axes(subaxes(num_columns*(row-1)+4));
  dispangle(squeeze(sign_corr_segments(roi_x,roi_y,slice,segment_show(row))));
  ptitle = sprintf('Sign-Corrected Phase');
  title(ptitle); axis off;

  % Incremental Phase
  axes(subaxes(num_columns*(row-1)+5));
  dispangle(squeeze(exp(i*phase_est(roi_x,roi_y,slice,segment_show(row)))));
  ptitle = sprintf('Est. Inc Phase',segment_show(row));
  title(ptitle); axis off;

  % Corrected Phase
  axes(subaxes(num_columns*(row-1)+6));
  dispangle(squeeze(corr_segments(roi_x,roi_y,slice,segment_show(row))));
  ptitle = sprintf('Corrected Phase');
  title(ptitle); axis off;

  % Cumulative Image (corrected)
  axes(subaxes(num_columns*(row-1)+7));
  dispim(squeeze(sum(segment_images(roi_x,roi_y,slice,1:segment_show(row)),4)));
  ptitle = sprintf('Reference Cumulative');
  title(ptitle); axis off;

  % Cumulative Image (reference)
  axes(subaxes(num_columns*(row-1)+8));
  dispim(squeeze(sum(corr_segments(roi_x,roi_y,slice,1:segment_show(row)),4)));
  ptitle = sprintf('Corrected Cumulative');
  title(ptitle); axis off;

  % Cumulative Image (map 1)
  axes(subaxes(num_columns*(row-1)+9));
  dispim(squeeze(sum(image_corr_map1(roi_x,roi_y,slice,1:segment_show(row)),4)));
  ptitle = sprintf('Corrected Map 1');
  title(ptitle); axis off;

  % Cumulative Image (map 2)
  axes(subaxes(num_columns*(row-1)+10));
  dispim(squeeze(sum(image_corr_map2(roi_x,roi_y,slice,1:segment_show(row)),4)));
  ptitle = sprintf('Corrected Map 2');
  title(ptitle); axis off;



end;


