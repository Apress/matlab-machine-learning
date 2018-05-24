%% SCALEIMAGE Scale an image by powers of 2.
%% Form
% s2 = ScaleImage( s1, n )
% ScaleImage % Demo
%
%% Description
% Scales an image by powers of 2. The scaling will be 2^n.
% Takes the mean of the neighboring pixels. Only works with RGB images.
%
%% Inputs
%
%  s1 (:,:,3)  Image
%  n  Scale    Integer
%
%% Outputs
%
%  s1 (:,:,3)  Scaled image
%

function s2 = ScaleImage( s1, q )

% Demo
if( nargin < 1 )
  Demo
  return
end

n = 2^q;

[mR,~,mD] = size(s1);

m = mR/n;

s2 = zeros(m,m,mD,'uint8');

for i = 1:mD
	for j = 1:m
    r = (j-1)*n+1:j*n;
    for k = 1:m
      c         = (k-1)*n+1:k*n;
      s2(j,k,i) = mean(mean(s1(r,c,i)));
    end
	end
end

function Demo
%% ScaleImage>Demo
% Scale an image of a cat

s1 = flipud(imread('Cat.png'));

n  = 2;

s2 = ScaleImage( s1, n );

n  = 2^n;

NewFigure('ScaleImage')

x = 0;
y = 0;

del = 1024;

sX = image('xdata',[x;x+del],'ydata',[y;y+del],'cdata', s1 );
x = x + del;
s = image('xdata',[x;x+del/n],'ydata',[y;y+del/n],'cdata', s2 );

axis image
axis off



