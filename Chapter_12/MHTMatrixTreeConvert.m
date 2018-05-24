%% MHTMATRIXTREECONVERT Convert from matrix to tree
%% Form
%   n = MHTMatrixTreeConvert( b )
%
%% Description
% Convert from MHT track matrix to tree or tree to matrix.
%
% Type MHTMatrixTreeConvert for a demo. Draws a tree if no outputs are
% requested.
%
%% Inputs
%   n        {:}    Nodes
%                   .parent	    (1,1) Parent
%                   .name       (1,1) Number of observation 
%                   .scan       (1,1) Scan number
%   b        (:,:)  Matrix representation
%
%% Outputs
%   n or b

function n = MHTMatrixTreeConvert( b )

% Demo
if( nargin < 1 )
  Demo
  return
end

if( iscell( b ) )
  n = TreeToMatrix( b );
else
  n = MatrixToTree( b );
end

% Draw a tree diagram if no outputs are requested
%------------------------------------------------
if( nargout == 0 )
  if( iscell( n ) )
      TreeDiagram( n );
  else
      disp(n);
  end
end

%--------------------------------------------------------------------------
%	Convert matrix to tree
%--------------------------------------------------------------------------
function n = MatrixToTree( b )

if( isempty(b) )
  n=[];
  return;
end

b = MHTMatrixSortRows(b);

node    = 0;

% initialize "obsOld" to value that cannot be equal to b(1,1)
obsOld = -rand;
[nB,~] = size(b);
nodeList = [];

ids = unique(b(:,1));
nid = length(ids);
scans = zeros(size(b,1),1);
if( size(b,2)==1 )
  scans = 1;
else
  for j=1:nid
    rows = find(b(:,1)==ids(j));
    col  = find(sum(b(rows,2:end),1)>0,1);
    if( isempty(col) )
      col = 1;
    end
    scans(rows) = col;
  end
end

col = 1;
for j = 1:nB
    if( b(j,col) ~= obsOld )
        d.parent = [];
        d.name   = b(j,1);
        obsOld   = d.name;
        d.child  = j;
        d.scan   = scans(j);
        node     = node + 1;
        n{node}  = d;
        nodeList = [nodeList node];
    else
        n{node}.child = [n{node}.child j];
    end
end

for k = nodeList
    j           = n{k}.scan;
    bN          = b(n{k}.child,[[],(j+1):end]);
    [n, node]   = NodeToTree( n, bN, node, k );
end

% add childNodes field
for j=1:length(n), 
  n{j}.childNodes = []; 
end
for j=1:length(n), 
  if ~isempty(n{j}.parent)
    n{n{j}.parent}.childNodes(end+1) = j; 
  end
end


%--------------------------------------------------------------------------
%	Recursively traverse the nodes
%--------------------------------------------------------------------------
function [n, node] = NodeToTree( n, b, node, parent )

if( isempty( b ) )
    return;
end

nB = size(b);
nodeList = [];

scan   = n{parent}.scan+1;

obsOld = -1;
for j = 1:nB
    if( b(j,1) ~= obsOld )
        d.parent = parent;
        d.name   = b(j,1);
        obsOld   = d.name;
        d.child  = j;
        d.scan   = scan;
        node     = node + 1;
        nodeList = [nodeList node];
        n{node}  = d;
    else
        n{node}.child = [n{node}.child j];
    end
end

for k = nodeList
    bN          = b(n{k}.child,2:end);
    [n, node]   = NodeToTree( n, bN, node, k );
end

%% MHTMatrixTreeConvert>>TreeToMatrix
function b = TreeToMatrix( n )

% Find the matrix size
scanMax = 0;
for k = 1:length(n)
    scanMax = max([scanMax n{k}.scan]);
end

rows = 0;
for k = 1:length(n)
    if( n{k}.scan == scanMax )
       rows = rows + 1;
    end
end

% Initialize the matrix
b = zeros(rows,scanMax);

% Start from the last column
j = 0;
for k = 1:length(n)
    if( n{k}.scan == scanMax )
        j            = j + 1;
        b(j,scanMax) = n{k}.name;
        node         = k;
        scan         = scanMax;
        while scan > 0 
            scan      = scan - 1;
            parent    = n{node}.parent;
            if( isempty(parent) )
                break
            end
            b(j,scan) = n{parent}.name;
            node      = parent;
        end
    end
end

b = MHTMatrixSortRows(b);

%% MHTMatrixTreeConvert>>Demo
function Demo
% Generate trees from several different matrices

b = [	1     0     0     0;...
      1     1     0     0;...
      1     1     1     0;...
      1     1     1     1];
        
disp('MHT Matrix: rows are tracks columns are scans');
disp(b)
        
n = MHTMatrixTreeConvert( b );
TreeDiagram( n )
    
b = MHTMatrixTreeConvert( n );
disp('MHT Matrix from tree')
disp(b)

b = [	1     0;...
      1     1;...
      2     0;...
      2     1;...
      2     2;...
      2     3;...
      0     1;...
      0     2;...
      0     3];

disp('MHT Matrix: rows are tracks columns are scans');
disp(b)

n = MHTMatrixTreeConvert( b );
TreeDiagram( n )
    
b = MHTMatrixTreeConvert( n );
disp('MHT Matrix from tree')
disp(b)
    
b = [	1     0     0;...
      1     1     0;...
      1     1     1;...
      2     0     0;...
      2     1     0;...
      2     2     0;...
      2     2     2;...
      2     3     0;...
      0     1     0;...
      0     2     0;...
      0     3     0;...
      0     0     1;...
      0     0     2];
        
disp('MHT Matrix: rows are tracks columns are scans');
disp(b)
n = MHTMatrixTreeConvert( b );

TreeDiagram( n )
    
b = MHTMatrixTreeConvert( n );
disp('MHT Matrix from tree')
disp(b)