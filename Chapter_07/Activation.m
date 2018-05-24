%% ACTIVATION Implement activation functions
%% Form
% s = Activation( type, x, k )
% Activation % Demo
%
%% Description
% Generates an activation function
%
%% Inputs
%
%  type (1,:) Type 'sigmoid', 'tanh', 'rlo'
%  x  	(1,:) Input
%  k    (1,1) Scale factor
%
%% Outputs
%
%  s  (1,:) Output
%

function s = Activation( type, x, k )

% Demo
if( nargin < 1 )
  Demo
  return
end

if( nargin < 3 )
  k = 1;
end

switch lower(type)
  case 'elo'
    j = x > 0;
    s = zeros(1,length(x));
    s(j) = 1;
  case 'tanh'
    s = tanh(k*x);
  case 'sigmoid'
    s = (1-exp(-k*x))./(1+exp(-k*x));
end

function Demo
%% Activation>Demo
% Show different activation functions
x	= linspace(-2,2);
s	= [ Activation('elo',x);...
      Activation('tanh',x);...
      Activation('sigmoid',x)];

PlotSet(x,s,'x label','x','y label','\sigma(x)',...
        'figure title','Activation Functions',...
        'legend',{{'ELO' 'tanh' 'Sigmoid'}},'plot set',{1:3});

