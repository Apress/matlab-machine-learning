%% Plot the sigmoid function for aircraft learning control
%% See also
% PlotSet

%% Initialize
x = linspace(-7,7);

%% Sigmoid
s = (1-exp(-x))./(1+exp(-x));

PlotSet( x, s, 'x label', 'x', 'y label', 's',...
  'plot title', 'Sigmoid', 'figure title', 'Sigmoid' );