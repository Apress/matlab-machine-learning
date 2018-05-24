%% DECISIONTREE Implements a decision tree
%% Form
%  [d, r] = DecisionTree( action, d, t )
%
%% Description
% Implements a binary classification tree.
% Type DecisionTree for a demo using the SimpleClassifierExample
%
%% Inputs
%   action  (1,:) Action 'train', 'test'
%   d       (.)	Data structure
%   t       {:} Inputs for training or testing
%
%% Outputs
%   d       (.)	Data structure
%   r       (:) Results 
%
%% References
%   None

function [d, r] = DecisionTree( action, d, t )

if( nargin < 1 )
  if( nargout > 0 )
    d = DefaultDataStructure;
  else
    Demo;
  end
  return
end

switch lower(action)
  case 'train'
    d = Training( d, t );
  case 'test'
    for k = 1:length(d.box)
      d.box(k).id = [];
    end
    [r, d] = Testing( d, t );
  otherwise
    error('%s is not an available action',action);
end

%% DecisionTree>>Training
function d = Training( d, t )
[n,m]   = size(t.x);
nClass  = max(t.m);
box(1)	= AddBox( 1, 1:n*m, [] );
box(1).child = [2 3];
[~, dH] = HomogeneityMeasure( 'initialize', d, t.m );

class   = 0;
nRow    = 1;
kR0     = 0;
kNR0    = 1; % Next row;
kInRow  = 1;
kInNRow = 1;
while( class < nClass )
  k   = kR0 + kInRow;
  idK	= box(k).id;
  if( isempty(box(k).class) )
    [action, param, val, cMin]  = FindOptimalAction( t, idK, d.xLim, d.yLim, dH );
    box(k).value                = val;
    box(k).param                = param;
    box(k).action               = action;
    x                           = t.x(idK);
    y                           = t.y(idK);
    if( box(k).param == 1 ) % x
      id  = find(x >	d.box(k).value );
      idX = find(x <=	d.box(k).value );
    else % y
      id  = find(y >  d.box(k).value );
      idX = find(y <=	d.box(k).value );
    end
    % Child boxes
    if( cMin < d.cMin)
      class   = class + 1;
      kN      = kNR0 + kInNRow;
      box(k).child = [kN kN+1];
      box(kN)	= AddBox( kN, idK(id), class  );
      class   = class + 1;
      kInNRow	= kInNRow + 1;
      kN      = kNR0 + kInNRow;
      box(kN)	= AddBox( kN, idK(idX), class );
      kInNRow	= kInNRow + 1;
    else
      kN            = kNR0 + kInNRow;
      box(k).child  = [kN kN+1];
      box(kN)       = AddBox( kN, idK(id)  );
      kInNRow       = kInNRow + 1;
      kN            = kNR0 + kInNRow;
      box(kN)       = AddBox( kN, idK(idX) );
      kInNRow       = kInNRow + 1;
    end
    
    % Update current row
    kInRow   = kInRow + 1;
    if( kInRow > nRow )
      kR0       = kR0 + nRow;
      nRow      = 2*nRow;
      kNR0      = kNR0 + nRow;
      kInRow    = 1;
      kInNRow   = 1;
    end
  end
end

for k = 1:length(box)
  if( ~isempty(box(k).class) )
    box(k).child = [];
  end
  box(k).id = [];
  fprintf(1,'Box %d action %s Value %4.1f %d\n',k,box(k).action,box(k).value,ischar(box(k).action));
end

d.box = box;

%% DecisionTree>>FindOptimalAction
function [action, param, val, cMin] = FindOptimalAction( t, iD, xLim, yLim, dH )

c = zeros(1,2);
v = zeros(1,2);

x = t.x(iD);
y = t.y(iD);
m = t.m(iD);
[v(1),c(1)] = fminbnd( @RHSGT, xLim(1), xLim(2), optimset('TolX',1e-16), x, m, dH );
[v(2),c(2)] = fminbnd( @RHSGT, yLim(1), yLim(2), optimset('TolX',1e-16), y, m, dH );

% Find the minimum
[cMin, j] = min(c);

action = '>';
param  = j;

val = v(j);

%% DecisionTree>>RHSGT
function q = RHSGT( v, u, m, dH )
% RHS greater than function for fminbnd

j   = find( u > v );
q1  = HomogeneityMeasure( 'update', dH, m(j) );
j   = find( u <= v );
q2  = HomogeneityMeasure( 'update', dH, m(j) );
q   = q1 + q2;

%% DecisionTree>> Testing
function [r, d] = Testing( d, t )
% Testing function
k     = 1;


[n,m] = size(t.x);
d.box(1).id = 1:n*m;

class = 0;
while( k <= length(d.box) )
	idK = d.box(k).id;
  v   = d.box(k).value;
  
	switch( d.box(k).action )
    case '>'
      if( d.box(k).param == 1 )
        id  = find(t.x(idK) >   v );
        idX = find(t.x(idK) <=  v );
      else
        id  = find(t.y(idK) >   v );
       	idX = find(t.y(idK) <= 	v );
      end
      d.box(d.box(k).child(1)).id = idK(id);
      d.box(d.box(k).child(2)).id = idK(idX);
   case '<='
      if( d.box(k).param == 1 )
        id  = find(t.x(idK) <=  v );
        idX	= find(t.x(idK) >   v );
      else
        id  = find(t.y(idK) <=  v );
       	idX	= find(t.y(idK) >  	v );
      end
      d.box(d.box(k).child(1)).id = idK(id);
      d.box(d.box(k).child(2)).id = idK(idX);
    otherwise
      class           = class + 1;
      d.box(k).class  = class;
  end
  k = k + 1;
end

r = cell(class,1);

for k = 1:length(d.box)
  if( ~isempty(d.box(k).class) )
    r{d.box(k).class,1} = d.box(k).id;
  end
end

%% DecisionTree>>DefaultDataStructure
function d = DefaultDataStructure

d.tree            = DrawBinaryTree;
d.threshold       = 0.01;
d.xLim            = [0 4];
d.yLim            = [0 4];
d.data            = [];
d.cMin            = 0.01;
d.box(1).action   = '>';
d.box(1).value    = 2;
d.box(1).param    = 1;
d.box(1).child    = [2 3];
d.box(1).id       = [];
d.box(1).class    = [];
d.box(1).impurity = 1;

d.box(2).action   = '>';
d.box(2).value    = 2;
d.box(2).param    = 2;
d.box(2).child    = [4 5];
d.box(2).id       = [];
d.box(2).class    = [];
d.box(2).impurity = 1;

d.box(3).action   = '>';
d.box(3).value    = 2;
d.box(3).param    = 2;
d.box(3).child    = [6 7];
d.box(3).id       = [];
d.box(3).class    = [];
d.box(3).impurity = 0;

d.box(4).action   = '';
d.box(4).value    = 0;
d.box(4).param    = 0;
d.box(4).child    = [];
d.box(4).id       = [];
d.box(4).class    = [];
d.box(4).impurity = 0;

d.box(5).action   = '';
d.box(5).value    = 0;
d.box(5).param    = 0;
d.box(5).child    = [4 5];
d.box(5).id       = [];
d.box(5).class    = [];
d.box(5).impurity = 0;

d.box(6).action   = '';
d.box(6).value    = 0;
d.box(6).param    = 0;
d.box(6).child    = [];
d.box(6).id       = [];
d.box(6).class    = [];
d.box(6).impurity = 0;

d.box(7).action   = '';
d.box(7).value    = 2;
d.box(7).param    = 2;
d.box(7).child    = [];
d.box(7).id       = [];
d.box(7).class    = [];
d.box(7).impurity = 0;

%% DecisionTree>>AddBox
function box = AddBox( k, id, class )

if( nargin < 3 )
  class = [];
end

box.action    = '';
box.value     = 0;
box.param     =  1;
box.child     = [k+1 k+2];
box.id        = id;
box.class     = class;
box.impurity  = 0;

%% DecisionTree>>Demo
function Demo
%n Train and test a decision tree

% Vertices for the sets
v = [ 0 0; 0 4; 4 4; 4 0; 2 4; 2 2; 2 0; 0 2; 4 2];
   
% Faces for the sets
f = { [6 5 2 8] [6 7 4 9] [6 9 3 5] [1 7 6 8] };

% Generate the training set
pTrain = ClassifierSets( 5, [0 4], [0 4], {'width', 'length'}, v, f, 'Training Set' );

% Generate the testing set
pTest  = ClassifierSets( 5, [0 4], [0 4], {'width', 'length'}, v, f, 'Testing Set' );

% Create the decision tree
d      = DecisionTree;
d.data = pTrain;
d      = DecisionTree( 'train', d, pTrain );

% Test the tree
d.data = pTest;
[d, r] = DecisionTree( 'test',  d, pTest  );

q = DrawBinaryTree;
c = 'xy';
for k = 1:length(d.box)
  if( ~isempty(d.box(k).action) )
    q.box{k} = sprintf('%c %s %4.1f',c(d.box(k).param),d.box(k).action,d.box(k).value);
  else
    q.box{k} = sprintf('Class %d',d.box(k).class);
  end
end
DrawBinaryTree(q);

m = reshape(pTest.m,[],1);

fprintf(1,'\nClass Membership\n\n');

for k = 1:length(r)
  fprintf(1,'Class %d\n',k);
  for j = 1:length(r{k})
    fprintf(1,'%d: %d\n',r{k}(j),m(r{k}(j)));
  end
end
fprintf(1,'\nImpurity Levels\n\n');
for k = 1:length(d.box)
  fprintf(1,'Box %d Impurity %12.4f\n',k,d.box(k).impurity);
end


