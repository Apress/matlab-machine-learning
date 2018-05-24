%% TREEDIAGRAM Tree diagram plotting function.
%% Form
%  TreeDiagram( n, w, update )
%
%% Description
% Generates a tree diagram from hierarchical data.
%
% Type TreeDiagram for a demo.
%
% w is optional the defaults are:
%
%  .name      = 'Tree';
%  .width     = 400;
%  .fontName  = 'Times';
%  .fontSize  = 10;
%  .linewidth = 1;
%  .linecolor = 'r';
%
%% Inputs
%   n        {:}    Nodes
%                   .parent	   (1,1) Parent
%                   .name      (1,1) Number of observation
%                   .scan       (1,1) Row number
%   w        (.)    Diagram data structure
%                   .name      (1,:) Tree name
%                   .width     (1,1) Circle width
%                   .fontName  (1,:) Font name
%                   .fontSize  (1,1) Font size
%   update   (1,1)  If entered and true update an existing plot

function TreeDiagram( n, w, update )

persistent figHandle

% Demo
if( nargin < 1 )
  Demo
  return;
end

% Defaults
if( nargin < 2 )
  w = [];
end
if( nargin < 3 )
  update = false;
end

if( isempty(w) )
  w.name      = 'Tree';
  w.width     = 1200;
  w.fontName  = 'Times';
  w.fontSize  = 10;
  w.linewidth = 1;
  w.linecolor = 'r';
end


% Find scan range
%----------------
m = length(n);

scanMin = 1e9;
scanMax = 0;

for k = 1:m
  scanMin = min([scanMin n{k}.scan]);
  scanMax = max([scanMax n{k}.scan]);
end

nScans = scanMax - scanMin + 1;

scan = scanMin:scanMax;

scanID = cell(nScans,1);

% Determine which nodes go with which scans
%------------------------------------------
for k = 1:nScans
  for j = 1:m
    if( n{j}.scan == scan(k) )
      scanID{k} = [scanID{k} j];
    end
  end
end


% Determine the maximum number of circles at the last scan
width = 3*length(scanID{nScans})*w.width;


% Draw the tree
if( ~update )
  figHandle = NewFigure(w.name);
else
  clf(figHandle)
end

figure(figHandle);
set(figHandle,'color',[1 1 1]);
dY = width/(nScans+2);
y  = (nScans+2)*dY;
set(gca,'ylim',[0 (nScans+1)*dY]);
set(gca,'xlim',[0 width]);
for k = 1:nScans
  
  % determine the correct label
	label = sprintf('Scan %d',k);
  
  text(0,y,label,'fontname',w.fontName,'fontsize',w.fontSize);
  x = 4*w.width;
  for j = 1:length(scanID{k})
    node            = scanID{k}(j);
    [xC,yCT,yCB]    = DrawNode( x, y, n{node}.name, w );
    n{node}.xC      = xC;
    n{node}.yCT     = yCT;
    n{node}.yCB     = yCB;
    x               = x + 3*w.width;
  end
  y = y - dY;
end

% Connect the nodes
for k = 1:m
  if( ~isempty(n{k}.parent) )
    ConnectNode( n{k}, n{n{k}.parent},w );
  end
end

axis off
axis image


%% TreeDiagram>>DrawNode
function [xC,yCT,yCB] = DrawNode( x0, y0, k, w )

n = 20;
a = linspace(0,2*pi*(1-1/n),n);

x = w.width*cos(a)/2 + x0;
y = w.width*sin(a)/2 + y0;
patch(x,y,'w');
text(x0,y0,sprintf('%d',k),'fontname',w.fontName,'fontsize',w.fontSize,'horizontalalignment','center');

xC  = x0;
yCT = y0 + w.width/2;
yCB = y0 - w.width/2;

%% TreeDiagram>>ConnectNode
function ConnectNode( n, nP, w )

x = [n.xC nP.xC];
y = [n.yCT nP.yCB];

line(x,y,'linewidth',w.linewidth,'color',w.linecolor);

function Demo
%% TreeDiagram>Demo
% Draws a multi-level tree

k = 1;
%---------------
scan        = 1;
d.parent	= [];
d.name     = 1;
d.scan      = scan;
n{k}        = d; k = k + 1;

%---------------
scan        = 2;

d.parent    = 1;
d.name     = 1;
d.scan      = scan;
n{k}        = d; k = k + 1;

d.parent    = 1;
d.name     = 2;
d.scan      = scan;
n{k}        = d; k = k + 1;

d.parent    = [];
d.name     = 3;
d.scan      = scan;
n{k}        = d; k = k + 1;

%---------------
scan        = 3;

d.parent    = 2;
d.name     = 1;
d.scan      = scan;
n{k}        = d; k = k + 1;

d.parent    = 2;
d.name     = 4;
d.scan      = scan;
n{k}        = d; k = k + 1;

d.parent    = 3;
d.name     = 2;
d.scan      = scan;
n{k}        = d; k = k + 1;

d.parent    = 3;
d.name     = 5;
d.scan      = scan;
n{k}        = d; k = k + 1;

d.parent    = 4;
d.name     = 6;
d.scan      = scan;
n{k}        = d; k = k + 1;

d.parent    = 4;
d.name     = 7;
d.scan      = scan;
n{k}        = d; k = k + 1;


%---------------
scan        = 4;

d.parent    = 5;
d.name     = 1;
d.scan      = scan;
n{k}        = d; k = k + 1;

d.parent    = 6;
d.name     = 8;
d.scan      = scan;
n{k}        = d; k = k + 1;

d.parent    = 6;
d.name     = 4;
d.scan      = scan;
n{k}        = d; k = k + 1;

d.parent    = 7;
d.name     = 2;
d.scan      = scan;
n{k}        = d; k = k + 1;

d.parent    = 7;
d.name     = 9;
d.scan      = scan;
n{k}        = d; k = k + 1;

d.parent    = 9;
d.name     = 10;
d.scan      = scan;
n{k}        = d; k = k + 1;

d.parent    = 10;
d.name     = 11;
d.scan      = scan;
n{k}        = d; k = k + 1;

d.parent    = 10;
d.name     = 12;
d.scan      = scan;
n{k}        = d;

% Call the function with the demo data
TreeDiagram( n )
