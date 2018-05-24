%% ConvolutionalNN
%% Form
%   [d, r] = ConvolutionalNN( action, d, t )
%
%% Description
% Implements a convolutional neural net. The net has three types of layers.
% Convolutional, full and pool. The last does not have weights and does
% not need to be trained.
%
% The default neural network has a 3 by 3 mask that is all ones. The
% pooling layer has 4 outputs. The fully connected layer has 4 inputs and
% 4 outputs.
%
%% Inputs
%   action  (1,:) Action 'train', 'test'
%   d       (.)	Data structure
%   t       {:} Images for training or testing
%
%% Outputs
%   d       (.)	Data structure
%   r       (:) Results probability

function [d, r] = ConvolutionalNN( action, d, t )

if( nargin < 1 )
  d = DefaultDataStructure;
  return
end

switch lower(action)
	case 'random'
    [d, r] = Random( d, t );
  case 'train'
    d = Training( d, t );
  case 'test'
    r = Testing( d, t );
  otherwise
    error('%s is not an available action',action);
end

function [d, r] = Random( d, t )
%% ConvolutionalNN>>Random

r = NeuralNet( d, t, 1 );

function d = Training( d, t )
%% ConvolutionalNN>>Training

d   = Indices( d );
x0  = DToX( d );
x   = fminsearch( @RHS, x0, d.opt, d, t );
d   = XToD( x, d );

function d	= Indices( d )
%% ConvolutionalNN>>Indices
% Find indices for x to d conversion

[rF,cF] = size(d.fCNN.w);
[rC,cC] = size(d.cL.w);

lF      = rF*cF;
lC      = rC*cC;
kF      = 1:lF;
kC      = 1:lC;

d.rF    = rF;
d.rC    = rC;

d.fW    = kF;
d.fB    = kF + lF;
d.cW    = kC + 2*lF;
d.cB    = kC + 2*lF+lC;

function x = DToX( d )
%% Convert data structure to x

x  = [reshape(d.fCNN.w, [],1);...
      reshape(d.fCNN.b, [],1);...
      reshape(d.cL.w,   [],1);...
      reshape(d.cL.b,   [],1)];

function d = XToD( x, d )
%% Convert x to data structure

d.fCNN.w = reshape(x(d.fW),d.rF,d.rF);
d.fCNN.b = reshape(x(d.fB),d.rF,d.rF);
d.cL.w   = reshape(x(d.cW),d.rC,d.rC);
d.cL.b   = reshape(x(d.cB),d.rC,d.rC);

function y = RHS( x, d, t )
%% Right side for fminsearch

d = XToD( x, d );

% Loop through all of the examples
r = zeros(1,length(t));
for k = 1:length(t)
  r(k) = NeuralNet( d, t{k} );
end

y = 1 - mean(r);

function r = Testing( d, t )
%% Testing function
r = NeuralNet( d, t );

function r = NeuralNet( d, t, ~ )
%% Neural net function

% Convolve the image
yCL   = ConvolutionLayer( t, d.cL );

% Pool outputs
yPool = Pool( yCL, d.pool.n, d.pool.type );

% Apply a fully connected layer
yFC   = FullyConnectedNN( yPool, d.fCNN );
[~,r] = Softmax( yFC );

% Plot if requested
if( nargin > 2 )
  NewFigure('ConvolutionNN');
  subplot(3,1,1);
  mesh(yCL);
  title('Convolution Layer')
  subplot(3,1,2);
	mesh(yPool);
  title('Pool Layer')
  subplot(3,1,3);
	mesh(yFC);
  title('Fully Connected Layer')
end


function d = DefaultDataStructure
%% Default data structure

d             = struct();
d.cL          = ConvolutionLayer;
d.fCNN        = FullyConnectedNN;
d.fCNN.w      = rand(4,4);
d.fCNN.b      = rand(4,4);
d.fCNN.aFun   = 'tanh';
d.fCNN.m      = 4;
d.pool.n      = 4;
d.pool.type   = 'median';
d.opt         = optimset('TolX',1e-5,'TolFun',1e-9,'MaxFunEvals',10000);

