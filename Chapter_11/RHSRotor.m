%% RHSROTOR Right hand side of a rotor
%% Form
%  xDot = RHSRotor( ~, x, a )
%
%% Description
% A rotor dynamics model
% This can be called by the MATLAB Recipes RungeKutta function or any MATLAB
% integrator. Time is not used.
%
% If no inputs are specified it will return the default data structure.
%
%% Inputs
%  t       (1,1) Time (unused)
%  x       (1,1) State vector [omega]
%  d       (.)   Data structure
%                .a	(1,1) State feedback gain
%                .b	(1,1) Input gain
%                .u (1,1) Input
%
%% Outputs
%  x       (1,1) State vector derivative domega/dt
%
%% References
% None.

function xDot = RHSRotor( ~, x, d )

if( nargin < 1 )
  xDot = struct('a',1,'b',0.5,'u',0);
  return
end

xDot  = -d.a*x + d.b*d.u;     

