%% EQUILIBRIUMSTATE Computes the equilibrium state for RHSAircraft
%% Form
% [x, thrust, delta, cost] = EquilibriumState( gamma, v, h, d )
%
%% Description
% Computes the equilibrium state for RHSAircraft. Uses fminsearch
% to drive the first two time derivatives to zero. It then computes
% the elevator angle needed to get zero pitch rate.
%
% If no inputs are specified it runs a demo.
%
%% Inputs
%  gamma  (1,1) Flight path angle (rad)
%  v      (1,1) Speed (m/s)
%  h      (1,1) Altitude (m)
%  d      (.)   Data structure
%                .cLAlpha   (1,1) Lift coefficient
%                .cD0       (1,1) Zero lift drag coefficient
%                .k         (1,1) Lift coupling with drag
%                .epsilon   (1,1) Thrust angle (rad)
%                .thrust    (1,1) Thrust (N)
%                .s         (1,1) Wetted area (m^2)
%                .mass      (1,1) Mass (kg)
%                .inertia   (1,1) Inertia (kg-m^2)
%                .c         (1,1) CP/CM offset (m)
%                .sE        (1,1) Elevator area (m^2)
%                .rE        (1,1) Elevator moment arm (m)
%                .elevator	(1,1) Elevator angle (rad)
%
%% Outputs
%  x        (5,1) State vector derivative
%  thrust   (1,1) Thrust (N)
%  delta    (1,1) Elevator angle (rad)
%  cost     (1,2) Initial and final cost
%
%% See also
% Subfunctions EquilibriumState>RHS, EquilibriumState>Demo

function [x, thrust, delta, cost] = EquilibriumState( gamma, v, h, d )

%% Code
if( nargin < 1 )
  Demo;
  return
end

x             = [v;0;0;0;h];
[~,~,drag]    = RHSAircraft( 0, x, d );
y0            = [0;drag];
cost(1)       = RHS( y0, d, gamma, v, h );
y             = fminsearch( @RHS, y0, [], d, gamma, v, h );
w             = y(1);
thrust        = y(2);
u             = sqrt(v^2-w^2);
alpha         = atan(w/u);
theta         = gamma + alpha;
cost(2)       = RHS( y, d, gamma, v, h );
x             = [u;w;0;theta;h];
d.thrust      = thrust;
d.delta       = 0;
[xDot,~,~,p]	= RHSAircraft( 0, x, d );
delta         = -asin(d.inertia*xDot(3)/(d.rE*d.sE*p));
d.delta       = delta;
radToDeg      = 180/pi;

fprintf(1,'\nVelocity          %8.2f m/s\n',v);
fprintf(1,'Altitude          %8.2f m\n',h);
fprintf(1,'Flight path angle %8.2f deg\n',gamma*radToDeg);
fprintf(1,'Z speed           %8.2f m/s\n',w);
fprintf(1,'Thrust            %8.2f N\n',y(2));
fprintf(1,'Angle of attack   %8.2f deg\n',alpha*radToDeg);
fprintf(1,'Elevator          %8.2f deg\n',delta*radToDeg);
fprintf(1,'Initial cost      %8.2e\n',cost(1));
fprintf(1,'Final cost        %8.2e\n',cost(2));

function cost = RHS( y, d, gamma, v, h )
%% EquilibriumState>RHS
% Cost function for fminsearch. The cost is the square of the velocity
% derivatives (the first two terms of xDot from RHSAircraft).
%
% See also RHSAircraft.

w         = y(1);
d.thrust	= y(2);
d.delta   = 0;
u         = sqrt(v^2-w^2);
alpha     = atan(w/u);
theta     = gamma + alpha;
x         = [u;w;0;theta;h];
xDot      = RHSAircraft( 0, x, d );
cost      = xDot(1:2)'*xDot(1:2);

%% EquilibriumState>Demo
function Demo
% Find the equilibrium state for an aircraft

echo on EquilibriumState
gamma = 0.0;
v     = 250;
h     = 10000;
d     = RHSAircraft;
echo off EquilibriumState

EquilibriumState( gamma, v, h, d );

