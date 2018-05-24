%% RHSOSCILLATORUKF Right hand side of a double integrator.
%% Form
%  xDot = RHSOscillatorUKF( t, x, a )
%
%% Description
% An oscillator models linear or rotational motion plus many other
% systems. It has two states, position and velocity. The equations of
% motion are:
%
%  rDot = v
%  vDot = a - omega^2*r
%
% This can be called by the MATLAB Recipes RungeKutta function or any MATLAB
% integrator. Time is not used. This function is compatible with the
% UKF parameter estimation. eta is the parameter to be estimated which is
% omega in this case.
%
% If no inputs are specified, it will return the default data structure.
%
%% Inputs
%  t       (1,1) Time (unused)
%  x       (2,1) State vector [r;v]
%  d       (.)   Data structure
%                .a     (1,1) Disturbance acceleration (m/s^2)
%                .zeta  (1,1) Damping ratio
%                .eta   (1,1) Natural frequency (rad/s)
%
%% Outputs
%  x       (2,1) State vector derivative d[r;v]/dt
%

function xDot = RHSOscillatorUKF( ~, x, d )

if( nargin < 1 )
  xDot = struct('a',0,'eta',0.1,'zeta',0);
  return
end

xDot = [x(2);d.a-2*d.zeta*d.eta*x(2)-d.eta^2*x(1)];
