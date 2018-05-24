%% NEURALNETMLFF - Computes the output of a multilayer feed-forward neural net.
%
%% Form
%   [y, dY, layer] = NeuralNetMLFF( x, network )
%
%% Description
% Computes the output of a multilayer feed-forward neural net.
%
% The input layer is a data structure that contains the network data.
% This data structure must contain the weights and activation functions
% for each layer.
%
% The output layer is the input data structure augmented to include
% the inputs, outputs, and derivatives of each layer for each run.
%
%% Inputs
%   x         (n,r)     n Inputs, r Runs
%
%   network              Data structure containing network data
%                       .layer(k,{1,r})  There are k layers to the network which
%                           includes 1 output and k-1 hidden layers
%
%                       .w(m(j),m(j-1))   w(p,q) is the weight between the q-th
%                                         output of layer j-1 and the p-th node
%                                         of layer j (ie. the q-th input to the
%                                         p-th output of layer j)
%                       .w0(m(j))         Biases/Thresholds
%                       .type(1)          'tanh', 'log', 'mag', 'sign', 'step'
%                                         Only one type is allowed per layer
%
%                       Different weights can be entered for different runs.
%% Outputs
%   y         (m(k),r)  Outputs
%   dY        (m(k),r)  Derivative
%   layer     (k,r)     Information about a desired layer j
%                       .x(m(j-1),1)   Inputs to layer j
%                       .y(m(j),1)     Outputs of layer j
%                       .dYT(m(j),1)   Derivative of layer j
%
%   (:)      Means that the dimension is undefined.
%   (n)    = number of inputs to neural net
%   (r)    = number of runs (ie. sets of inputs)
%   (k)    = number of layers
%   (m(j)) = number of nodes in j-th layer
%
%% References
% Nilsson, Nils J. (1998.) Artificial Intelligence:
% A New Synthesis. Morgan Kaufmann Publishers. Ch. 3.

%% Copyright
% Copyright 1998,1999 Princeton Satellite Systems, Inc.
% All rights reserved.

function [y, dY, layer] = NeuralNetMLFF( x, network )

layer = network.layer;

% Input processing
if( nargin < 2 )
  disp('Will run an example network');
end
if( ~isfield(layer,'w') )
  error('Must input size of neural net.');
end
if( ~isfield(layer,'w0') )
  layer(1).w0 = [];
end
if( ~isfield(layer,'type') )
  layer(1).type = [];
end

% Generate some useful sizes
nLayers  = size(layer,1);
nInputs  = size(x,1);
nRuns    = size(x,2);

for j = 1:nLayers
  if( isempty(layer(j,1).w) )
    error('Must input weights for all layers')
  end
  if( isempty(layer(j,1).w0) )
    layer(j,1).w0 = zeros( size(layer(j,1).w,1), 1 );
  end
end

nOutputs = size(layer(nLayers,1).w, 1 );

% If there are multiple layers and only one type
% replicate it (the first layer type is the default)
if( isempty(layer(1,1).type) )
  layer(1,1).type = 'tanh';
end

for j = 2:nLayers
  if( isempty(layer(j,1).type) )
    layer(j,1).type = layer(1,1).type;
  end
end

% Set up additional storage
%--------------------------
y0   = zeros(nOutputs,nRuns);
dY   = zeros(nOutputs,nRuns);
for k = 1:nLayers
  [outputs,inputs] = size( layer(k,1).w );
  for j = 1:nRuns
    layer(k,j).x   = zeros(inputs,1);
    layer(k,j).y   = zeros(outputs,1);
    layer(k,j).dY  = zeros(outputs,1);
  end
end

% Process the network
for j = 1:nRuns
  y = x(:,j);
  for k = 1:nLayers
    % Load the appropriate weights and types for the given run
    if( isempty( layer(k,j).w ) )
      w = layer(k,1).w;
    else
      w = layer(k,j).w;
    end
    
    if( isempty( layer(k,j).w0 ) )
      w0 = layer(k,1).w0;
    else
      w0 = layer(k,j).w0;
    end
    
    if( isempty( layer(k,j).type ) )
      type = layer(k,1).type;
    else
      type = layer(k,j).type;
    end
    
    layer(k,j).x  = y;
    [y, dYT]      = Neuron( w*y - w0, type );
    layer(k,j).y  = y;
    layer(k,j).dY = dYT;
    
  end
  y0(:,j) = y;
  dY(:,j) = dYT;
end

if( nargout == 0 )
  PlotSet(1:size(x,2),y0,'x label','Step','y label','Outputs','figure title','Neural Net');
else
  y = y0;
end
