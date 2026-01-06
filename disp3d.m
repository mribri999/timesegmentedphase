%	function [loc,low,high,waypoints,minroiloc,maxroilic]  
%			= disp3d(im,low,high,startloc,mode)
% 
%	Function displays magnitude (and possibly phase) 
%	of 3D image im (complex array),
%	letting the user page through images in the axial, sagittal
%	or coronal planes.
%
%	Also lets the user specify "waypoints" and a cubic region-of-interest
%	(ROI).
%	
%
%	INPUT:	
%		im 	=	3D data array, ordered x,y,z.
%		low	= 	Black level.  [] to autoscale.
%		high	= 	White level.  [] to autoscale.
%		startloc=	Starting pixel for cross hairs. []=center.
%		mode    = 	0 = magnitude.
%				1 = Just display and exit.
%				2 = magnitude and phase.
%				3 = Mag/Phase, display and exit.
%
%	OUTPUT:
%		loc 	= 	1x3 vector with cross-hair location.
%		low 	= 	Black level.
%		high 	= 	White level.
%		waypoints = 	Nx3 array, rows are waypoints of interest.
%
%	See also:  dispim, disp3dmp, imview
%
%	Brian Hargreaves,	Jan 2003.
%
%

% ===========================================================
%
%	$Log: disp3d.m,v $
%	Revision 1.15  2006/02/01 18:10:20  brian
%	minor edits
%	
%	Revision 1.14  2004/11/09 22:35:06  brian
%	minor edits
%	
%	Revision 1.13  2004/08/10 21:10:44  brian
%	Fixed a few more bugs.
%	
%	Revision 1.12  2004/08/10 19:44:40  brian
%	Fixed some bugs.
%	
%	Revision 1.11  2004/08/10 19:31:40  brian
%	Improved ROI functionality (middle button) and
%	Added Waypoint functionality (a/z)
%	
%	Revision 1.10  2004/04/14 17:50:37  brian
%	minor edits
%	
%	Revision 1.9  2004/04/13 01:36:20  brian
%	minor edits
%	
%	Revision 1.8  2003/09/16 02:56:17  brian
%	minor edits
%	
%	Revision 1.7  2003/08/14 21:13:10  brian
%	minor edits
%
%	Revision 1.6  2003/08/14 20:11:01  brian
%	minor edits
%	
%	Revision 1.5  2003/08/14 20:05:27  brian
%	Added mode=2 facility to display magnitude
%	and phase information simultaneously.
%	
%	Also streamlined the main loop a bit by moving
%	stuff out to functions.
%	
%	Revision 1.4  2003/07/29 02:48:36  brian
%	minor edits
%	
%	Revision 1.3  2003/05/29 23:05:32  brian
%	Added:
%		- returns location.
%		- no need to wait for mouse (display-and-quit)
%		- brightness contrast.
%	
%	Revision 1.2  2003/01/06 01:53:31  brian
%	Added help documentation
%	
%	Revision 1.1  2003/01/06 01:27:26  brian
%	New code to do 3D displaying
%	
%	
%
% ===========================================================


function [loc,low,high,waypoints,minroiloc,maxroiloc] = disp3d(im,low,high,startloc,mode)


% ==== Default Window levels ====

im = squeeze(im);

imwin = im(1:16:end,1:16:end,1:16:end);

if ( (nargin < 3) | (length(high)==0) )
	disp('Calculating Window Levels...');
	mni = mean(abs(imwin(:)));
	sdi = std(abs(imwin(:)));
	high = mni+2*sdi;
end;
if ( (nargin < 2) | (length(low)==0) )
	low = mni-2*sdi;
	if (low < 0)
		low=0;
	end;
end;
if (nargin < 3)
	tt=sprintf('Window Levels %f - %f ',low,high);
	disp(tt);
end;

immode = 0;		% Show planes.  1=MIP, 2=Projection
waypoints = [];		% No waypoints to start.
maxroiloc = [];
minroiloc = [];
global scolors scolornum;
scolors = [0 0 1; 0 1 0;1 0 0;1 1 0; 1 0 1; 0 0 0];
scolornum = 1;

s = size(im);		% Size of image.
if (length(s) < 3) s(3)=1; end;
if ((nargin < 4) | (length(startloc)<3))
	newloc = round(s/2+.1);			% Starting location.
else
	newloc = startloc;
end;
if (nargin < 5)
	mode = 0;
end;

if (rem(mode,2)==1)
	nomove=1;
else
	nomove=0;
end;
if (mode>=2)
	anim = angle(im)+pi;
end;

if (nomove==0)
	disp('-------------------------------------------');
	disp('disp3d:  Right Mouse Button Exits, h = help');
	disp('-------------------------------------------');
end;


padwidth = round(.05*(s(1)+s(2)));	% Width of border.

while (newloc >= 0)

	if (newloc > 0)
		loc = newloc;
	end;
	imdisp = getplanes(abs(im),loc,low,high,padwidth,immode);
	immode = 0;	% Set back to 3-plane.
	szdisp = size(imdisp);
	asp = szdisp(2)/szdisp(1);

	if ((asp > 1) && (mode>=2))
		mdisp = 2;
		ndisp = 1;
	elseif (mode >= 2)
		mdisp = 1;
		ndisp = 2;
	else
		mdisp = 1;
		ndisp = 1;
	end;
	subplot(mdisp,ndisp,1);

	dispim(imdisp,low,high);
	axis equal;
	axis off;
	addtitles(padwidth,s,loc,abs(im(loc(1),loc(2),loc(3))));
	showwaypoints(loc,waypoints,s,padwidth,scolors(scolornum,:));
	showroi(minroiloc,maxroiloc,loc,s,padwidth,scolors(scolornum,:));


	% Define/Display Special Functions (brightness, contrast)

	if (nomove==0)
	  Nspec = 4;
  	  brightN=1;
  	  contN=2;
	  addspeclabels(padwidth,s,Nspec,brightN,contN);
	end;

	if (mode>=2)	% Display phase. 

		if (immode==1)
			title('Image Magnitude (MIP)');
		else
			title('Image Magnitude');
		end;
		subplot(mdisp,ndisp,2);
		animdisp = getplanes(anim,loc,0,2*pi,padwidth);
		dispim(animdisp,0,2*pi);
		axis equal;
		axis off;
		addtitles(padwidth,s,loc,.001*round(1000*abs(anim(loc(1),loc(2),loc(3)))));
		title('Image Phase');
		showwaypoints(loc,waypoints,s,padwidth,scolors(scolornum,:));
		showroi(minroiloc,maxroiloc,loc,s,padwidth,scolors(scolornum,:));
	end;

	if (nomove==0)
	  [newloc,specloc,b,imclick,waypoints] = getloc(loc,s,padwidth,waypoints);
	  if (specloc > 0)
            [low,high] = procspecfunc(low,high,s,specloc,Nspec,brightN,contN);
 	  end;
	  if (b==2)	% Change ROI.
		  [minroiloc,maxroiloc] = updateroi(minroiloc,maxroiloc,newloc,imclick);
		  roi = im(minroiloc(1):maxroiloc(1),minroiloc(2):maxroiloc(2),minroiloc(3):maxroiloc(3));
		  roimean = mean(abs(roi(:)));
		  roistdev = std(abs(roi(:)));
		  tt = sprintf('ROI <%d,%d,%d> - <%d,%d,%d>  Mean=%f  Stdev=%f  N=%d',minroiloc,maxroiloc,roimean,roistdev,length(roi(:)));
		  disp(tt);

 	  elseif (b==115)	% Plots.
		subplot(3,2,1);
		plot(squeeze(abs(im(:,loc(2),loc(3)))));
		a = axis; hold on; plot(loc(1)*[1 1],a(3:4),'r:'); hold off;
		title('Magnitude X');
		subplot(3,2,2);
		plot(squeeze(angle(im(:,loc(2),loc(3)))/pi));
		a = axis; hold on; plot(loc(1)*[1 1],a(3:4),'r:'); hold off;
		title('Angle X (/\pi ) ');
		subplot(3,2,3);
		plot(squeeze(abs(im(loc(1),:,loc(3)))));
		a = axis; hold on; plot(loc(2)*[1 1],a(3:4),'r:'); hold off;
		title('Magnitude Y');
		subplot(3,2,4);
		plot(squeeze(angle(im(loc(1),:,loc(3)))/pi));
		a = axis; hold on; plot(loc(2)*[1 1],a(3:4),'r:'); hold off;
		title('Angle Y (/\pi )');
		subplot(3,2,5);
		plot(squeeze(abs(im(loc(1),loc(2),:))));
		a = axis; hold on; plot(loc(3)*[1 1],a(3:4),'r:'); hold off;
		title('Magnitude Z');
		subplot(3,2,6);
		plot(squeeze(angle(im(loc(1),loc(2),:))/pi));
		a = axis; hold on; plot(loc(3)*[1 1],a(3:4),'r:'); hold off;
		title('Angle Z (/\pi )');
		drawnow;
		disp('Click in plot to return to 3-axis views');
		ginput(1);

	  elseif (b==109)	% Show MIP
		immode = 1;
	  elseif (b==112)	% Show Projection
		immode = 2;
	  end;

	else
		newloc = [-1 -1 -1];
	end;

end;


function [minroiloc,maxroiloc] = updateroi(minroiloc,maxroiloc,loc,imclick)
%	Function updates the ROI with the given location.  For each
%	of 2 coordinates in the clicked plane:
%		If the coordinate is outside the ROI, the ROI is updated.
%		If the coordinate is inside the ROI, the closest SIDE
%		to the location is moved to the location.

modifycoords = [1 3;2 3;1 2];	% 2D Coordinates to modify, given display plane.

if (max(size(minroiloc)) ==0)	% No ROI yet!
	minroiloc = loc;
	maxroiloc = loc;
else
	max2d = maxroiloc(modifycoords(imclick,:));
	min2d = minroiloc(modifycoords(imclick,:));
	loc2d = loc(modifycoords(imclick,:));

	if ((loc2d <= max2d) & (loc2d >= min2d))	% loc inside ROI
		sides = [min2d max2d];
		locloc = [loc2d loc2d];
		sidedists = abs(locloc - sides);
		[md,mc] = min(sidedists);
		sides(mc)=locloc(mc);
		minroiloc(modifycoords(imclick,:)) = sides(1:2);
		maxroiloc(modifycoords(imclick,:)) = sides(3:4);
	else					% loc outside ROI -> add.
		maxroiloc(modifycoords(imclick,:)) = max([max2d; loc2d]);
		minroiloc(modifycoords(imclick,:)) = min([min2d; loc2d]);
	end;
end;


function plotroibox(corner1,corner2,linestyle,linecolor)
% 	Plots a box given the x/y coordinates of corners.

hold on;
h = plot([corner1(1) corner2(1)],corner1(2)*[1 1],linestyle);
set(h,'Color',linecolor);
h = plot([corner1(1) corner2(1)],corner2(2)*[1 1],linestyle);
set(h,'Color',linecolor);
h = plot(corner1(1)*[1 1],[corner1(2) corner2(2)],linestyle);
set(h,'Color',linecolor);
h = plot(corner2(1)*[1 1],[corner1(2) corner2(2)],linestyle);
set(h,'Color',linecolor);
hold off;


function showroi(roiminloc,roimaxloc,loc,imsize,padwidth,linecolor)
%	Function draws + signs at waypoints on image.


if (nargin < 6) linecolor = [0 0 1]; end;

if (max(size(roiminloc))>0)
	[xymin,xzmin,yzmin] = getplanepts(roiminloc,imsize,padwidth);
	[xymax,xzmax,yzmax] = getplanepts(roimaxloc,imsize,padwidth);
	linestyles = {':','-'};   % Not in region, in region.
	locinregion = ((loc >= roiminloc) & (loc <= roimaxloc)) + [1 1 1];
	plotroibox(xymin,xymax,linestyles{locinregion(3)},linecolor);
	plotroibox(xzmin,xzmax,linestyles{locinregion(2)},linecolor);
	plotroibox(yzmin,yzmax,linestyles{locinregion(1)},linecolor);
end;



function plotwaypoint(x,y,ptsymbol,textcolor,fontsize)
% Plot a + and change size/color/centering.

h = text(x,y,ptsymbol);
set(h,'HorizontalAlignment','center');
set(h,'VerticalAlignment','middle');
set(h,'Color',textcolor);
set(h,'Fontsize',fontsize);



function showwaypoints(loc,waypts,imsize,padwidth,textcolor)
%	Function draws + signs at waypoints on image.

if (nargin < 5) textcolor = [0 0 1]; end;

sw = size(waypts);
if (sw(1)>0)
    for k = 1:sw(1)
	[xyloc,xzloc,yzloc] = getplanepts(waypts(k,:),imsize,padwidth);
	inplanes = (waypts(k,:) == loc);
	% Plot 16 point if in plane, 8point otherwise.
	plotwaypoint(yzloc(1),yzloc(2),'+',textcolor,8*(inplanes(1)+1));
	plotwaypoint(xzloc(1),xzloc(2),'+',textcolor,8*(inplanes(2)+1));
	plotwaypoint(xyloc(1),xyloc(2),'+',textcolor,8*(inplanes(3)+1));
    end;
end;

function [xyloc,xzloc,yzloc] = getplanepts(loc,imsize,padwidth)
%	Function gets the position in the displayed image of "loc"

xyloc = loc([1 2]) + padwidth*[1 2] + imsize(3)*[0 1]; 
xzloc = loc([1 3]) + padwidth*[1 1];
yzloc = loc([2 3]) + padwidth*[2 1] + imsize(1)*[1 0]; 




function [adisp] = getplanes(im,loc,low,high,padwidth,mode)

% Gets the images for each plane.

s = size(im);
if (length(s)<3) s(3)=1; end;

if (nargin < 6) mode = 0; end;
if mode==2				% Projection
	axy = squeeze(sum(im,3)/s(3));
	ayz = squeeze(sum(im,1)/s(1));
	axz = squeeze(sum(im,2)/s(2));
elseif mode==1				% MIP
	mipscale = 4;			% Empirical!
	axy = squeeze(max(im,[],3))/4;
	ayz = squeeze(max(im,[],1))/4;
	axz = squeeze(max(im,[],2))/4;
else					% Plane.
	axy = squeeze(im(:,:,loc(3)));
	ayz = squeeze(im(loc(1),:,:));
	axz = squeeze(im(:,loc(2),:));
end;

axy = reshape(axy,s(1),s(2));
ayz = reshape(ayz,s(2),s(3));
axz = reshape(axz,s(1),s(3));

% Whiten crosshair:

axy(loc(1),:) = high;
axy(:,loc(2)) = high;
ayz(loc(2),:) = high;
ayz(:,loc(3)) = high;
axz(loc(1),:) = high;
axz(:,loc(3)) = high;


adisp = (high+low)/2*ones(s(3)+padwidth+s(2),s(1)+padwidth+s(2));
adisp(1:s(3),1:s(1)) = axz.';
adisp(s(3)+padwidth+1:s(3)+padwidth+s(2),1:s(1)) = axy';
adisp(1:s(3),s(1)+padwidth+1:s(1)+padwidth+s(2)) = ayz';
adisp(s(3)+padwidth+1:s(3)+padwidth+s(2),s(1)+padwidth+1:s(1)+padwidth+s(2)) = zeros(s(2),s(2));

adisp1 = (high+low)/2*ones(s(3)+3*padwidth+s(2),s(1)+3*padwidth+s(2));
sa = size(adisp1);
adisp1(padwidth+1:sa(1)-padwidth,padwidth+1:sa(2)-padwidth)=adisp;
adisp = adisp1;




function [newloc,specloc,b,imclick,waypts] = getloc(loc,s,padsize,waypts)

%	s = size of image.
global scolornum scolors;

[x,y,b] = ginput(1);
x = round(x);
y = round(y);
%tt = sprintf('Location selected is %d,%d  ',x,y);
%disp(tt);

imclick = 0;
specloc = [-1 -1];

% ======= Find xx,yy,zz of 3D location =====
xx = 0;
yy = 0;
zz = 0;
spx = 0;
spy = 0;
if (x > padsize) & (x <= padsize+s(1))	% Left images.
	if (y > padsize) & (y <= padsize+s(3))	% Top Left image;
		%disp('X-Z Image');
		xx = x-padsize;
		zz = y-padsize; 
		yy = loc(2);
		imclick=1;
	end;
	if (y > 2*padsize+s(3)) & (y <= 2*padsize+s(3)+s(2)) % Bot Left.
		%disp('X-Y Image');
		xx = x-padsize;
		yy = y-2*padsize-s(3); 
		zz = loc(3);
		imclick=3;
	end;
end;	
if (x > 2*padsize+s(1)) & (x <= 2*padsize+s(1)+s(2))	% Right images.
	if (y > padsize) & (y <= padsize+s(3))	% Top Right image;
		%disp('Y-Z Image');
		yy = x-2*padsize-s(1);
		zz = y-padsize; 
		xx = loc(1);
		imclick=2;
	end;
	if (y > 2*padsize+s(3)) & (y <= 2*padsize+s(3)+s(2)) % Bot Rght.
		%disp('Y-Z Image');
		spy = y-2*padsize-s(3); 
		spx = x-2*padsize-s(1);
	end;
end;


if ((b==3) | (b==113))
	newloc = [-1 -1 -1];
elseif (b==97)			% Add way-point
	waypts = [waypts; loc];
	tt = sprintf('Adding waypoint (%d,%d,%d) ',loc);
	disp(tt);
	newloc = loc;
elseif (b==122)
	sw = size(waypts);
	d = ones(sw(1),1)*[loc] - waypts;
	[m,p] = min(sum(d' .* d'));
	p
	tt = sprintf('Removing (%d,%d,%d) ',waypts(p,:));
	disp(tt);
	keep = [[1:p-1] [p+1:sw(1)]];
	keep
	waypts = waypts(keep,:);
	newloc = loc;
elseif (b==117)				% u = up 
   	newloc = loc + [0 0 -1];
	if (newloc(3)<1)  newloc(3)=1; end;
elseif (b==100)				% d = down
   	newloc = loc + [0 0 1];
	if (newloc(3)>s(3))  newloc(3)=s(3); end;
elseif (b==108)				% l = left
   	newloc = loc + [-1 0 0];
elseif (b==114)				% r = right
   	newloc = loc + [1 0 0];
elseif (b==105)				% i = in
   	newloc = loc + [0 -1 0];	
elseif (b==111)				% o = out
   	newloc = loc + [0 1 0];	
elseif (b==116)				% t = toggle ROI/waypoint colors.
	scolornum=scolornum+1;
	if (scolornum > max(size(scolors))) scolornum=1; end;
   	newloc = loc;
elseif (b==104)				% h = help
	newloc = loc;
	disp('disp3d Options');
	disp('--------------');
	disp('Right Mouse Button (or q) - Exit');
	disp('Left  Mouse Button - New Center Position');
	disp('Middle Mouse Button - Add to ROI');
	disp('a = Add way-point');
	disp('z = Remove closest way-point');
	disp('h = Show this help screen');
	disp('d = Move down (increase z by one).');
	disp('i = Move in (decrease y by one).');
	disp('l = Move left (decrease x by one).');
	disp('o = Move out (increase y by one).');
	disp('m = Show MIP in 3 planes.');
	disp('p = Show projection in 3 planes.');
	disp('r = Move right (increase x by one).');
	disp('s = Plot along X,Y,Z.');
	disp('t = Toggle ROI/waypoint colors.');
	disp('u = Move up (decrease z by one).');
	disp('------------------------------------');


else			% Left mouse button = new position.


	newloc = [xx,yy,zz];
	specloc = [spx,spy];
end;



function addtitles(padwidth,s,loc,val)
%
%	Adds titles and position label to plot.
%
%	padwidth = width of border.
%	s = size of 3D data set.
%	loc = location within data set.
%

    h=text(padwidth+s(1)/2,padwidth/2,'X-Z');
    set(h,'Color',[1,1,1]);
    h=text(2*padwidth+s(1)+s(2)/2,padwidth/2,'Y-Z');
    set(h,'Color',[1,1,1]);
    h=text(padwidth+s(1)/2,3*padwidth/2+s(3),'X-Y');
    set(h,'Color',[1,1,1]);
    tt = sprintf('Position %d,%d,%d',loc(1),loc(2),loc(3));
    h=text(2*padwidth+s(1),3*padwidth/2+s(3),tt);
    set(h,'Color',[1,1,1]);
    if (val > 100) 
    	tt = sprintf('Value:  %d ',round(val));
    else
    	tt = sprintf('Value:  %5.2f ',val);
    end;

    h=text(2*padwidth+s(1),5*padwidth/2+s(2)+s(3),tt);
    set(h,'Color',[1,1,1]);
    h=xlabel('Press h to display options.');
    set(h,'Color',[0,0,0]);


function addspeclabels(padwidth,s,Nspec,brightN,contN)
%
%	Adds labels for brightness, contrast etc.
%
%	Nspec = number of special labels.
%	padwidth = width of border.
%	s = size of 3D data set.

	 
  h=text(2*padwidth+s(1)+s(2)/2,2*padwidth+s(3)+((brightN-.5)/Nspec*s(2)),'-  Brightness  +');
  set(h,'Color',[1,1,1]);
  set(h,'FontSize',14);
  set(h,'HorizontalAlignment','center');
  
  h=text(2*padwidth+s(1)+s(2)/2,2*padwidth+s(3)+((contN-.5)/Nspec*s(2)),'-   Contrast   +');
  set(h,'Color',[1,1,1]);
  set(h,'FontSize',14);
  set(h,'HorizontalAlignment','center');




function [low,high] = procspecfunc(low,high,s,specloc,Nspec,brightN,contN);
%
%	Process special functions.
%
%	low, high = current levels.
%	s = size of 3D image.
%	specloc = special location, from getloc()
%	Nspec = # special functions.
%	brightN = brightness number
%	contN = contrast number.
%
%

  specseg = floor(specloc(2)/s(2)*Nspec)+1;
  specx = specloc(1)/s(2);
  if (specseg == brightN)		% Change Brightness
	hl = high-low;
	dhl = .2*high;
	if (specx < .5)
		high=high+dhl;
		low = high-hl;
	else
		low = low-dhl;
		if (low < 0)  low=0; end;
		high = high-dhl;
	end;
  end;

  if (specseg == contN)
	hl = high-low;
	dhl = .1*high;
	if (specx < .5)
		low = low-dhl/2;
		if (low<0)  low=0; end;
		high = high+dhl/2;
	else
		low = low+dhl/2;
		high = high-dhl/2;
		if (high < low)  high=low+100; end;
	end;
  end;
  tt = sprintf('New low,high levels %f,%f',low,high);
  disp(tt);
