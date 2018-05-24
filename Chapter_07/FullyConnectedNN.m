%% FULLYCONNECTEDNN Create a fully connected neural net
%% Form
% y = FullyConnectedNN( x, d )
% FullyConnectedNN % Demo
%
%% Description 
% Implements a fully connected neural network
%
%% Inputs
%
%  x  (n,1) Inputs
%  d  (.)   Data structure
%           .w    (n,m) Weights
%           .b    (n,m) Biases
%           .aFun (1,:) Activation Function
%
%% Outputs
%
%  y  (m,1) Outputs

function y = FullyConnectedNN( x, d )

% Demo
if( nargin < 1 )
  if( nargout > 0 )
    y = DefaultDataStructure;
  else
    Demo;
  end
  return
end

y = zeros(d.m,size(x,2));

aFun = str2func(d.aFun);

n = size(x,1);
for k = 1:d.m
  for j = 1:n
    y(k,:) = y(k,:) + aFun(d.w(j,k)*x(j,:) + d.b(j,k));
  end
end

%% FullyConnectedNN>>DefaultDataStructure
function d = DefaultDataStructure
%% Default Data Structure

d = struct('w',[],'b',[],'aFun','tanh','m',1);

function Demo
%%  FullyConnectedNN>Demo
% Show a fully connected neural net. Inputs are a sine and cosine.

d       = DefaultDataStructure;
a       = linspace(0,8*pi);
x       = [sin(a);cos(a)];

d.w     = rand(2,2);
d.b     = rand(2,2);
d.aFun  = 'tanh';
d.m     = 2;
n       = length(x);
y       = FullyConnectedNN( x, d );

yL      = {'x_1' 'x_2' 'y_1' 'y_2'};
PlotSet( 1:n,[x;y],'x label','step','y label',yL,'figure title','FCNN');
