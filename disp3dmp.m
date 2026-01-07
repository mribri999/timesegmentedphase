%       function [loc,low,high,waypoints,minroiloc,maxroiloc] 
%			= disp3dmp(im,low,high,startloc,mode)
% 
%	Function just calls disp3d, with magnitude and phase (ie mode=2).
%	See disp3dmp for information.  Other parameters to disp3d are
%	left blank. 
%
%	INPUT:	im = 3D image.
%
%	Brian Hargreaves,	Jan 2003.
%
%

% ===========================================================
%
% 	$Log: disp3dmp.m,v $
% 	Revision 1.5  2004/08/10 19:44:40  brian
% 	Fixed some bugs.
% 	
% 	Revision 1.4  2004/08/10 19:31:40  brian
% 	Improved ROI functionality (middle button) and
% 	Added Waypoint functionality (a/z)
% 	
% 	Revision 1.3  2004/04/13 01:36:20  brian
% 	minor edits
% 	
% 	Revision 1.2  2003/09/16 02:56:17  brian
% 	minor edits
% 	
% 	Revision 1.1  2003/08/14 20:11:01  brian
% 	minor edits
% 	
%
% ===========================================================


function [loc,low,high,waypoints,minroiloc,maxroiloc] = disp3dmp(im,low,high,startloc,mode)

if (nargin < 2)
	low = [];
end;
if (nargin < 3)
	high = [];
end;
if (nargin < 4)
	startloc = [];
end;
if (nargin < 5)
	mode = 2;
end;

[loc,low,high,waypoints,minroiloc,maxroiloc] = disp3d(im,low,high,startloc,mode);


