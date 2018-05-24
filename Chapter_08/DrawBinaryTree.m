%% DRAWBINARYTREE Draw a binary tree in a new figure
%% Forms:
%  DrawBinaryTree( d, name )
%  d = DrawBinaryTree        % default data structure
%
%% Description
% Draws a binary tree. All branches are drawn. Inputs in d.box go from left
% to right by row starting with the row with only one box.
%
%% Inputs
%  d    (.)	   Data structure
%               .w          (1,1) Box width
%               .h          (1,1) Box height
%               .rows       (1,1) Number of rows in the tree
%               .fontSize   (1,1) Font size
%               .font       (1,:) Font name
%               .box        {:}   Text for each box
%  name (1,:)  Figure name
%
%% Outputs
%  d   (.)	Data structure

function d = DrawBinaryTree( d, name )

% Demo
if( nargin < 1 )
  if( nargout == 0 )
    Demo
  else
    d = DefaultDataStructure;
  end
  return
end

if( nargin < 2 )
  name = 'Binary Tree';
end

NewFigure(name);

m       = length(d.box); 
nRows   = ceil(log2(m+1));
w       = d.w;
h       = d.h;
i       = 1;
x       = -w/2;
y       =  1.5*nRows*h;
nBoxes  = 1;
bottom  = zeros(m,2);
top     = zeros(m,2);
rowID   = cell(nRows,1);
for k = 1:nRows
  for j = 1:nBoxes
    bottom(i,:)   = [x+w/2 y ];
    top(i,:)      = [x+w/2 y+h];
    DrawBox(d.box{i},x,y,w,h,d);
    rowID{k}      = [rowID{k} i];
    i             = i + 1;
    x             = x + 1.5*w;
    if( i > length(d.box) )
      break;
    end
  end
  nBoxes  = 2*nBoxes;
  x       = -(0.25+0.5*(nBoxes/2-1))*w - nBoxes*w/2;
  y       = y - 1.5*h;
end


% Draw the lines
for k = 1:length(rowID)-1
  iD = rowID{k};
  i0 = 0;
  % Work from left to right of the current row
  for j = 1:length(iD)
    x(1) = bottom(iD(j),1);
    y(1) = bottom(iD(j),2);
    iDT  = rowID{k+1};
    if( i0+1 > length(iDT) )
      break;
    end
    for i = 1:2
      x(2) = top(iDT(i0+i),1);
      y(2) = top(iDT(i0+i),2);
      line(x,y);
    end
    i0 = i0 + 2;
  end
end
axis off

%% DrawBinaryTree>>DrawBox
function DrawBox( t, x, y, w, h, d )
% Draw boxes and text

v = [x y 0;x y+h 0; x+w y+h 0;x+w y 0];

patch('vertices',v,'faces',[1 2 3 4],'facecolor',[1;1;1]);

text(x+w/2,y + h/2,t,'fontname',d.font,'fontsize',d.fontSize,'HorizontalAlignment','center');

%% DrawBinaryTree>>DefaultDataStructure
function d = DefaultDataStructure
% Default data structure

d           = struct();
d.fontSize  = 12;
d.font      = 'courier';
d.w         = 1;
d.h         = 0.5;
d.box       = {};

%% DrawBinaryTree>>Demo
function Demo
% Draw a simple binary data treea

d           = DefaultDataStructure;
d.box{1}    = 'a > 0.1';
d.box{2}    = 'b > 0.2';
d.box{3}    = 'b > 0.3';
d.box{4}    = 'a > 0.8';
d.box{5}    = 'b > 0.4';
d.box{6}    = 'a > 0.2';
d.box{7}    = 'b > 0.3';

DrawBinaryTree( d );


