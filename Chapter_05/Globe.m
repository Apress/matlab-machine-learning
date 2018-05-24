
%% GLOBE Draws a three dimensional map of a planet. 
%
%% Form
%   p = Globe( planet, rad )ius
%
%% Description
% Turns on mouse driven 3D rotation. String inputs are
% 
% You generate the planet data structure like this example for a gray 
% scale image of pluto;
%
% The replication of the image map is needed because the png is gray scale.
%
% p = imread('PlutoGray.png');
% p3(:,:,1) = p;
% p3(:,:,2) = p;
% p3(:,:,3) = p;
%
%% Inputs
%   planet	(1,:)	Image file  name or nxnx3 matrix
%   radius	(1,1)	Radius
%
%% Outputs
%   None
%

function Globe( planet, radius )


% Defaults
if( nargin < 1 )
  planet = 'Pluto.png';
  radius = 1151;
end

if( ischar(planet) )
  planetMap = imread(planet);
else
  planetMap = planet;
end

NewFigure('Globe')

[x,y,z] = sphere(50);
x       = x*radius;
y       = y*radius;
z       = z*radius;
hSurf   = surface(x,y,z);
grid on;
for i= 1:3
  planetMap(:,:,i)=flipud(planetMap(:,:,i));
end
set(hSurf,'Cdata',planetMap,'Facecolor','texturemap');
set(hSurf,'edgecolor', 'none',...
          'EdgeLighting', 'phong','FaceLighting', 'phong',...
          'specularStrength',0.1,'diffuseStrength',0.9,...
          'SpecularExponent',0.5,'ambientStrength',0.2,...
          'BackFaceLighting','unlit');

view(3);
xlabel('x (km)')
ylabel('y (km)')
zlabel('z (km)')
rotate3d on
axis image
