
%% RHSAUTOMOBILEXY Double integrator model for a car.
%% Form
%   xDot = RHSAutomobileXY( t, x, d )
%
%% Inputs
%   t         Time, unused
%   x	(4,1)   State [x;y;vX;vY]
%   d         Data, unused
%
%% Outputs
%   x	(4,1)   State derivative d[x;y;vX;vY]/dt

function xDot = RHSAutomobileXY( ~, x, ~ )

xDot = [x(3:4);0;0];

