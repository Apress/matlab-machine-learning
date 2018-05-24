%% NEURON A neuron function for neural nets.
%% Form
%  [y, dYDX] = Neuron( x, type, t )
%
%% Description
% x may have any dimension. However, if plots are desired x must be 2
% dimensional. The default type is tanh.
%
% The log function is 1./(1 + exp(-x))
%
% The mag function is x./(1 + abs(x))
%
%% Inputs
%   x         (:,...) Input
%   type      (1,:)   'tanh', 'log', 'mag', 'sign', 'step', 'sum'
%   t         (1,1)   Threshold for type = 'step'
%
%% Outputs
%   y         (:,...) Output
%   dYDX      (:,...) Derivative
%
%% Reference
% Omidivar, O., and D.L. Elliot (Eds) (1997.) "Neural Systems for Control."
% Academic Press.
%
% Russell, S., and P. Norvig. (1995.) Artificial Intelligence - A Modern
% Approach. Prentice-Hall. p. 583.

function [y, dYDX] = Neuron( x, type, t )

% Input processing
%-----------------
if( nargin < 1 )
  x = [];
end
if( nargin < 2 )
  type = [];
end
if( nargin < 3 )
  t = 0;
end
if( isempty(type) )
  type = 'log';
end
if( isempty(x) )
  x = sort( [linspace(-5,5) 0 ]);
end

switch lower( deblank(type) )
  case 'tanh'
    yX   = tanh(x);
    dYDX = sech(x).^2;
    
  case 'log'
    % sigmoid logistic function
    yX   = 1./(1 + exp(-x));
    dYDX = yX.*(1 - yX);
    
  case 'mag'
    d    = 1 + abs(x);
    yX   = x./d;
    dYDX = 1./d.^2;
    
  case 'sign'
    yX           = ones(size(x));
    yX(x < 0)    = -1;
    dYDX         = zeros(size(yX));
    dYDX(x == 0) = inf;
    
  case 'step'
    yX           = ones(size(x));
    yX(x < t)    = 0;
    dYDX         = zeros(size(yX));
    dYDX(x == t) = inf;
    
  case 'sum'
    yX   = x;
    dYDX = ones(size(yX));
    
  otherwise
    error([type ' is not recognized'])
end

% Output processing
%------------------
if( nargout == 0 )
  PlotSet( x, yX, 'x label', 'Input', 'y label', 'Output',...
    'plot title', [type ' Neuron'] );
  PlotSet( x, dYDX, 'x label','Input', 'y label','dOutput/dX',...
    'plot title',['Derivative of ' type ' Function'] );
else
  y = yX;
end
