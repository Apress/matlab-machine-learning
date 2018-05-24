%% MRAC Model reference adaptive control
%% Form
%  d = MRAC( omega, d )
%
%% Description
% Model reference adaptive control for a rotor with damping.
% If no inputs are specified it will return the default data structure.
%
%% Inputs
%  omega	(1,1) Measured angulr rate
%  d      (.)   Data structure
%                .gamma   (1,1) Adaptation gain
%                .aM      (1,1) Model state gain
%                .bM      (1,1) Model input gain
%                .x       (5,1) Control state [x1;x2;theta1;theta2;omegaM]
%                .uC      (1,1) Command input
%
%% Outputs
%  d      (.)   Data structure
%
%% References
% None.
function d = MRAC( omega, d )

if( nargin < 1 )
  d = DataStructure;
  return
end

d.x	= RungeKutta( @RHS, 0, d.x, d.dT, d, omega );
d.u = d.x(3)*d.uC - d.x(4)*omega;

%% MRAC>>DataStructure
function d = DataStructure
% Default data structure

d       = struct();
d.aM    = 2.0;
d.bM    = 2.0;
d.x     = [0;0;0;0;0];
d.uC    = 0;
d.u     = 0;
d.gamma = 1;
d.dT    = 0.1;

%% MRAC>>RHS
function xDot = RHS( ~, x, d, omega )
% RHS for MRAC

e    = omega - x(5);
xDot = [-d.aM*x(1) + d.aM*d.uC;...
        -d.aM*x(2) + d.aM*omega;...
        -d.gamma*x(1)*e;...
         d.gamma*x(2)*e;...
        -d.aM*x(5) + d.bM*d.uC];


