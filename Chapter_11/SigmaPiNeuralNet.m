%% SIGMAPINEURALNET Sigma-pi neural net
%% Forms
% [y, d] = SigmaPiNeuralNet( action, x, d )
%
%% Description
% Implements a sigma-pi neural net with online training
% The data structure d holds the memory for the function.
% You call the function in the following order:
%
% Get default data structure
% d       = SigmaPiNeuralNet; 
%
% Initialize the filter. You can send an empty x.
% [~, d]  = SigmaPiNeuralNet( 'initialize', x, d );
%
% Get the initial weights by using batch learning. The number of columns
% of x should be at least twice the number of inputs
% [y, d]  = SigmaPiNeuralNet( 'batch learning', x, d );
%
% Perform recursive learning. x is a column.
% for k = 1:n
%  [y(k), d]  = SigmaPiNeuralNet( 'recursive learning', x(:,k), d );
% end
%
% After sufficient training you can use it without learning.
% [y(k), d]  = SigmaPiNeuralNet( 'output', x(:,k), d );
%
%% Inputs
% action  (1,:) Actions 'initialize', 'set constant', 'batch learning'
%               'recursive learning', 'output'
% x       (n,1)	Measurements
% d       (.)   Data structure
%               .w          (n,1)   Weights for each z
%               .zI         {n}     Indices
%               .c          (1,1)   Constant
%               .kSigmoid   (:,1)   Constant of each sigma function
%               .y          (:,1)   Training data
%               .z          (:,1)   Products of x
% 
%% Outputs
% y (:,1)   Neural net output
% d (.)     Updated data structure

%% References
% None.

function [y, d] = SigmaPiNeuralNet( action, x, d )

% Demo or default data structure
if( nargin < 1 )
  if( nargout == 1)
    y = DefaultDataStructure;
  else
    Demo;
  end
  return
end

switch lower(action)
	case 'initialize'
    d   = CreateZIndices( x, d );
    d.w = zeros(size(d.zI,1)+1,1);
    y   = [];

	case 'set constant'
    d.c = x;
    y   = [];
   
  case 'batch learning'
    [y, d] = BatchLearning( x, d );
    
  case 'recursive learning'
    [y, d] = RecursiveLearning( x, d );
  
	case 'output'
    [y, d] = NNOutput( x, d );

  otherwise
    error('%s is not an available action',action );
end

%% SigmaPiNeuralNet>>CreateZIndice
function d = CreateZIndices( x, d )
% Create the indices

n     = length(x);
m     = 0;
nF    = factorial(n);
for k = 1:n
  m = m + nF/(factorial(n-k)*factorial(k));
end

d.z  = zeros(m,1);
d.zI = cell(m,1);

i   = 1;
for k = 1:n
	c = Combinations(1:n,k);
	for j = 1:size(c,1)
    d.zI{i} = c(j,:);
    i       = i + 1;
  end
end
d.nZ = m+1;

%% SigmaPiNeuralNet>>CreateZArray
function d = CreateZArray( x, d )
% Create array of products of x

n = length(x);

d.z(1) = d.c;
for k = 1:d.nZ-1
  d.z(k+1) = 1;
  for j = 1:length(d.zI(k))
    d.z(k+1) = d.z(k)*x(d.zI{k}(j));
  end
end

%% SigmaPiNeuralNet>>RecursiveLearning
function [y, d] = RecursiveLearning( x, d )

d   = CreateZArray( x, d );
z   = d.z;
d.p	= d.p - d.p*(z*z')*d.p/(1+z'*d.p*z);
d.w	= d.w + d.p*z*(d.y - z'*d.w);
y   = z'*d.w;

%% SigmaPiNeuralNet>>NNOutput
function [y, d] = NNOutput( x, d )
%% Output without learning

x = SigmoidFun(x,d.kSigmoid);

d   = CreateZArray( x, d );
y   = d.z'*d.w;

%% SigmaPiNeuralNet>>BatchLearning
function [y, d] = BatchLearning( x, d )
% Batch Learning

z = zeros(d.nZ,size(x,2));

x = SigmoidFun(x,d.kSigmoid);

for k = 1:size(x,2)  
  d       = CreateZArray( x(:,k), d );
  z(:,k)  = d.z;
end
d.p = inv(z*z');
d.w = (z*z')\z*d.y;
y   = z'*d.w;

%% SigmaPiNeuralNet>>DefaultDataStructure
function d = DefaultDataStructure
% Default data structure

d           = struct();
d.w         = [];
d.c         = 1; % Constant term
d.zI        = {};
d.z         = [];
d.kSigmoid  = 0.0001;
d.y         = [];

%% SigmaPiNeuralNet>>SigmoidFun
function s = SigmoidFun( x, k )
% Sigmoid function

kX  = k.*x;
s   = (1-exp(-kX))./(1+exp(-kX));

%% SigmaPiNeuralNet>>Demo
function Demo
% Demonstrate a sigma-pi neural net for dynamic pressure
x       = zeros(2,1);

d       = SigmaPiNeuralNet;
[~, d]  = SigmaPiNeuralNet( 'initialize', x, d );

h       = linspace(10,10000);
v       = linspace(10,400);
v2      = v.^2;
q       = 0.5*AtmDensity(h).*v2;

n       = 5;
x       = [h(1:n);v2(1:n)];
d.y     = q(1:n)';
[y, d]  = SigmaPiNeuralNet( 'batch learning', x, d );

fprintf(1,'Batch Results\n#         Truth   Neural Net\n');
for k = 1:length(y)
  fprintf(1,'%d: %12.2f %12.2f\n',k,q(k),y(k));
end

n = length(h);
y = zeros(1,n);
x = [h;v2];
for k = 1:n
  d.y = q(k);
  [y(k), d]  = SigmaPiNeuralNet( 'recursive learning', x(:,k), d );
end

yL = {'q (N/m^2)' 'v (m/s)' 'h (m)'};
PlotSet(1:n,[y;q;v;h],'x label','Sample','y label',yL,...
        'plot title',{'Dynamic Pressure' 'Velocity' 'Altitude'},...
        'figure title','Sigma Pi NN','plot set',{[1 2] 3 4},...
        'legend',{{'Truth' 'NN'} {} {}});

