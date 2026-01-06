% function [im_component,time_window] = 
%	time_segment(image,sample_times,segment,num_segments,overlap)
%
%	Function uses sample_times to create time windows that are used
%	to time-segment the acquisition by (1) transforming image to 
%	k-spae, (2) applying the time window, (3) transforming image back.
%
%	INPUT:
%		image = complex 3D image	
%		sample_times = array of times for k-space samples (s)
%		segment = desired time segment [1:num_segments]
%		num_segments = total number of time segments used
%		overlap = ratio of full-width to time segment spacing [2]
%
%	OUTPUT:
%		im_component = time-windowed image component.
%		time_window = filter function in k-space
%

function [im_component,time_window] = ...
	time_segment(image,sample_times,segment,num_segments,overlap)


if (nargin < 4) num_segments=8; end;
if (nargin < 5) overlap=2; end;


start_time = 0;					
end_time = max(sample_times(:));			% maximum sample time
seg_mid_time = (segment-1)/(num_segments-1)*end_time;	% mid-time of segment
seg_spacing = (end_time-start_time)/(num_segments-1);	% center-to-center
seg_half_width = seg_spacing*overlap/2;
seg_start = seg_mid_time-seg_half_width;
seg_end = seg_mid_time+seg_half_width;

showtext = sprintf('Segment %d of %d, times %g,%g, half-width %g', ...
		segment,num_segments,seg_start,seg_end,seg_half_width);
disp(showtext);


% -- Form Time-segment window (times within segment, Hamming windowed)
seg_kpts = find((sample_times > seg_start) & (sample_times < seg_end));
time_window = 0*sample_times;	% Allocate
time_window(seg_kpts) = ...
	0.54+0.46*cos(pi*(sample_times(seg_kpts)-seg_mid_time)/seg_half_width);

% -- Fourier transform, filter, and inverse-transform to image component
im_component = ift3(time_window.*ft3(image));

