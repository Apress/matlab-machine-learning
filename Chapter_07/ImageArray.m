%% IMAGEARRAY Read in an array of images
%% Form:
%  s = ImageArray( folderPath, scale )
%  ImageArray % Demo
%
%% Description
% Creates a cell array of images. scale will scale by 2^scale
%
%% Inputs
%   folderPath   (1,:)	Path to the folder
%   scale        (1,1)  Integer.
%
%% Outputs
%   s      {:}	Image array
%   sName   {:} Names

function [s, sName] = ImageArray( folderPath, scale )

% Demo
if( nargin < 1 )
  Demo
  return;
end

c = cd;
cd(folderPath)

d = dir;

n = length(d);

j = 0;
s     = cell(n-2,1);
sName = cell(1,length(n));
for k = 1:n
  name = d(k).name;
  if( ~strcmp(name,'.') && ~strcmp(name,'..') )
    j         = j + 1;
    sName{j}  = name;
    t         = ScaleImage(flipud(imread(name)),scale);
    s{j}      = (t(:,:,1)+ t(:,:,2) + t(:,:,3))/3;
  end
end

del   = size(s{1},1);
lX    = 3*del;

% Draw the images
NewFigure(folderPath);
colormap(gray);
n = length(s);
x = 0;
y = 0;
for k = 1:n
  image('xdata',[x;x+del],'ydata',[y;y+del],'cdata', s{k} );
  hold on
  x = x + del;
  if ( x == lX )
    x = 0;
    y = y + del;
  end
end
axis off
axis image

for k = 1:length(s)
  s{k} = double(s{k})/256;
end

cd(c)

function Demo
%% ImageArray>Demo
% Generate an array of cat images

p = which('ImageArray');
j = strfind(p,'/');
p = p(1:j(end)-1);
cd(p)
ImageArray( 'Cats1024/', 4 );

