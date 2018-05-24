%% NEURALNETTRAINING Training using back propagation.
% Computes the weights for a neural net using back propagation. If no
% inputs are given it will do a demo for the network
% where node 1 and node 2 use exp functions.
%
%   sin(    x) -- node 1
%              \ /      \
%               \        ---> Output
%              / \      /
%   sin(0.2*x) -- node 2
%
%% Form
%  [w, e, layer] = NeuralNetTraining( x, y, layer )
%% Inputs
%   x         (n,r)     n Inputs, r Runs
%
%   y         (m(k),r)  Desired Outputs
%
%   layer     (k,{1,r}) Data structure containing network data
%                       There are k layers to the network which
%                       includes 1 output and k-1 hidden layers
%
%                       .w(m(j),m(j-1))   w(p,q) is the weight between the q-th
%                                         output of layer j-1 and the p-th node
%                                         of layer j (ie. the q-th input to the
%                                         p-th output of layer j)
%                       .w0(m(j))         Biases/Thresholds
%                       .type(1)          'tanh', 'log', 'mag', 'sign', 'step'
%                       .alpha(1)         Learning rate
%
%                       Only one type and learning rate are allowed per layer
%
%% Outputs
%   w         (k)       Weights of layer j
%                       .w(m(j),m(j-1))   w(p,q) is the weight between the q-th
%                                         output of layer j-1 and the p-th node
%                                         of layer j (ie. the q-th input to the
%                                         p-th output of layer j)
%                       .w0(m(j))         Biases/Thresholds
%
%   e         (m(k),r)  Errors
%
%   layer     (k,r)     Information about a desired layer j
%                       .x(m(j-1),1)   Inputs to layer j
%                       .y(m(j),1)     Outputs of layer j
%                       .dYT(m(j),1)   Derivative of layer j
%                       .w(m(j),m(j-1) Weights of layer j
%                       .w0(m(j))      Thresholds of layer j
%
%---------------------------------------------------------------------------
%   (:)      Means that the dimension is undefined.
%   (n)    = number of inputs to neural net
%   (r)    = number of runs (ie. sets of inputs)
%   (k)    = number of layers
%   (m(j)) = number of nodes in j-th layer
%---------------------------------------------------------------------------
%% Reference
% Nilsson, Nils J. (1998.) Artificial Intelligence: A New Synthesis. Morgan
% Kaufmann Publishers. Ch. 3.

%% Copyright 1998,1999, 2016 Princeton Satellite Systems, Inc.
% All rights reserved.

function [w, e, layer] = NeuralNetTraining( x, y, layer )

% Input Processing
if( ~isfield(layer,'w') )
  error('Must input size of neural net.');
end;

if( ~isfield(layer,'w0') )
  layer(1).w0 = [];
end;

if( ~isfield(layer,'type') )
  layer(1).type = [];
end;

if( ~isfield(layer,'alpha') )
  layer(1).type = [];
end;

% Generate some useful sizes
nLayers  = size(layer,1);
nRuns    = size(x,2);

if( size(y,2) ~= nRuns )
  error('The number of input and output columns must be equal.')
end;

for j = 1:nLayers
  if( isempty(layer(j,1).w) )
    error('Must input weights for all layers')
  end;
  if( isempty(layer(j,1).w0) )
    layer(j,1).w0 = zeros( size(layer(j,1).w,1), 1 );
  end;
end;

nOutputs = size(layer(nLayers,1).w, 1 );

% If there are multiple layers and only one type
% replicate it (the first layer type is the default)
if( isempty(layer(1,1).type) )
  layer(1,1).type = 'tanh';
end
if( isempty(layer(1,1).alpha) )
  layer(1,1).alpha = 0.5;
end
for j = 2:nLayers
  if( isempty(layer(j,1).type) )
    layer(j,1).type = layer(1,1).type;
  end
  if( isempty( layer(j,1).alpha) )
    layer(j,1).alpha = layer(1,1).alpha;
  end
end

% Set up additional storage
h    = waitbar(0,'Allocating Memory');
e   = zeros(nOutputs,nRuns);
for k = 1:nLayers
  [outputs,inputs]   = size( layer(k,1).w );
  temp.layer(k,1).w           = layer(k,1).w;
  temp.layer(k,1).w0          = layer(k,1).w0;
  temp.layer(k,1).type        = layer(k,1).type;
  
  for j = 1:nRuns
    layer(k,j).w     = zeros(outputs,inputs);
    layer(k,j).w0    = zeros(outputs,1);
    layer(k,j).x     = zeros(inputs,1);
    layer(k,j).y     = zeros(outputs,1);
    layer(k,j).dY    = zeros(outputs,1);
    layer(k,j).delta = zeros(outputs,1);
    
    waitbar( ((k-1)*nRuns+j) / (nLayers*nRuns) );
  end;
end;
close(h);

% Perform back propagation
h = waitbar(0, 'Neural Net Training in Progress' );
for j = 1:nRuns
  % Work backward from the output layer
  [yN, dYN,layerT] = NeuralNetMLFF( x(:,j), temp );
  e(:,j)           = y(:,j) - yN(:,1); % error
  
  for k = 1:nLayers
    layer(k,j).w  = temp.layer(k,1).w;
    layer(k,j).w0 = temp.layer(k,1).w0;
    layer(k,j).x  = layerT(k,1).x;
    layer(k,j).y  = layerT(k,1).y;
    layer(k,j).dY = layerT(k,1).dY;
  end
  
  % Last layer delta is calculated first
  layer(nLayers,j).delta = e(:,j).*dYN(:,1);
  % Intermediate layers use the subsequent layer's delta
  for k  = (nLayers-1):-1:1
    layer(k,j).delta = layer(k,j).dY.*(temp.layer(k+1,1).w'*layer(k+1,j).delta);
  end
  % Now that we have all the deltas, update the weights (w) and biases (w0)
  for k = 1:nLayers
    temp.layer(k,1).w  = temp.layer(k,1).w  + layer(k,1).alpha*layer(k,j).delta*layer(k,j).x';
    temp.layer(k,1).w0 = temp.layer(k,1).w0 - layer(k,1).alpha*layer(k,j).delta;
  end
  
  waitbar(j/nRuns);
end
w = temp.layer;
close(h);

% Output processing
if( nargout == 0 )
  PlotSet( 1:size(e,2), e, 'Step', 'Error', 'Neural Net Training' );
end
