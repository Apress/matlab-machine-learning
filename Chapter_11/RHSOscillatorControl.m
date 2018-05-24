%% RHSOSCILLATORCONTROL Right hand side of an oscillator.
%% Form
%  xDot = RHSOscillatorControl( ~, x, a )
%
%% Description
% An oscillator models linear or rotational motion plus many other
% systems. It has two states, position and velocity. The equations of
% motion are:
%
%  rDot = v
%  vDot = a - 2*zeta*omega*v - omega^2*r
%
% This can be called by the MATLAB Recipes RungeKutta function or any MATLAB
% integrator. Time is not used.
%
% If no inputs are specified it will return the default data structure.
%
%% Inputs
%  t       (1,1) Time (unused)
%  x       (2,1) State vector [r;v]
%  d       (.)   Data structure
%                .a     (1,1) Disturbance acceleration (m/s^2)
%                .c     (1,1) Velocity gain
%                .omega (1,1) Natural frequency (rad/s)
%
%% Outputs
%  xDot    (2,1) State vector derivative d[r;v]/dt
%
%% References
% None.

function xDot = RHSOscillatorControl( ~, x, d )

if( nargin < 1 )
  xDot = struct('a',0,'omega',0.1,'c',0);
  return
end

xDot = [x(2);d.a-d.c*x(2)-d.omega^2*x(1)];
