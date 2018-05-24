%% SQUAREWAVE Generate a square wave
%% Form
%  [v, d] = SquareWave( t, d )
%  d = SquareWave               % default data structure
%  SquareWave                   % run a demo
%
%% Description
% Generates a square wave with a magnitude either 0 or 1. The switch state and
% time is stored in the data structure d.
%
%% Inputs
%  t      (1,1) Time (sec)
%  d      (.)   Data structure
%                .tLow    (1,1) Low time
%                .tHigh   (1,1) Time high
%                .tSwitch (1,1) Last switch time
%                .state   (1,1) 0 = low, 1 = high
%
%% Outputs
%  v     (1,1)  Value
%  d      (.)   Data structure
%
%% See also
% SquareWave>Demo

function [v,d] = SquareWave( t, d )

if( nargin < 1 )
  if( nargout == 0 )
    Demo;
  else
    v = DataStructure;
  end
	return
end

if( d.state == 0 )
  if( t - d.tSwitch >= d.tLow )
    v         = 1;
    d.tSwitch = t;
    d.state   = 1;
  else
    v         = 0;
  end
else
  if( t - d.tSwitch >= d.tHigh )
    v         = 0;
    d.tSwitch = t;
    d.state   = 0;
  else
    v         = 1;
  end
end

function d = DataStructure
%% SquareWave>>DataStructure

d           = struct();
d.tLow      = 10.0;
d.tHigh     = 10.0;
d.tSwitch   = 0;
d.state     = 0;

function Demo
%% SquareWave>Demo
% Create a square wave using the default data structure and 1000 data points.
% Generate a plot.

d = SquareWave;
t = linspace(0,100,1000);
v = zeros(1,length(t));
for k = 1:length(t)
  [v(k),d] = SquareWave(t(k),d);
end

PlotSet(t,v,'x label', 't (sec)', 'y label', 'v', 'plot title','Square Wave',...
        'figure title', 'Square Wave');
  


