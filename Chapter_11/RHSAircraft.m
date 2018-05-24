%% RHSAIRCRAFT Right hand side of an aircraft dynamical model
%% Form
% d = RHSAircraft;
% [xDot, drag, lift, pD] = RHSAircraft( ~, x, a )
%
%% Description
% An aircraft longitudinal dynamics model.
% This can be called by the MATLAB Recipes RungeKutta function or any
% MATLAB integrator. Time is not used.
%
% If no inputs are specified it will return the default data structure.
%
%% Inputs
%  t       (1,1) Time (unused)
%  x       (5,1) State vector [u;w;q;theta;h]
%  d       (.)   Data structure
%                .cLAlpha   (1,1) Lift coefficient
%                .cD0       (1,1) Zero lift drag coefficient
%                .k         (1,1) Lift coupling with drag
%                .epsilon   (1,1) Thrust angle (rad)
%                .thrust    (1,1) Thrust (N)
%                .s         (1,1) Wetted area (m^2)
%                .mass      (1,1) Mass (kg)
%                .inertia   (1,1) Pitch inertia (kg-m^2)
%                .c         (1,1) CP/CM offset along x (m)
%                .sE        (1,1) Elevator area (m^2)
%                .delta   	(1,1) Elevator angle (rad)
%
%% Outputs
%  xDot     (5,1) State vector d[u;w;q;theta;h]/dt
%  lift     (1,1) Lift force (N)
%  drag     (1,1) Drag force (N)
%  pD       (1,1) Dynamic pressure (N/m^2)
%
%% References
% None.


function [xDot, lift, drag, pD] = RHSAircraft( ~, x, d )

if( nargin < 1 )
  xDot = DataStructure;
  return
end

g     = 9.806;

u     = x(1);
w     = x(2);
q     = x(3);
theta = x(4);
h     = x(5);

rho   = AtmDensity( h );

alpha = atan(w/u);
cA    = cos(alpha);
sA    = sin(alpha);

v     = sqrt(u^2 + w^2);
pD    = 0.5*rho*v^2; % Dynamic pressure

cL    = d.cLAlpha*alpha;
cD    = d.cD0 + d.k*cL^2;

drag  = pD*d.s*cD;
lift  = pD*d.s*cL;

x     =  lift*sA - drag*cA;
z     = -lift*cA - drag*sA;
m     =  d.c*z + pD*d.sE*d.rE*sin(d.delta);

sT    = sin(theta);
cT    = cos(theta);

tEng  = d.thrust*d.throttle;
cE    = cos(d.epsilon);
sE    = sin(d.epsilon);

uDot  = (x + tEng*cE)/d.mass - q*w - g*sT + d.externalAccel(1);
wDot  = (z - tEng*sE)/d.mass + q*u + g*cT + d.externalAccel(2);
qDot  = m/d.inertia                       + d.externalAccel(3);
hDot  = u*sT - w*cT;

xDot  = [uDot;wDot;qDot;q;hDot];

function d = DataStructure
%% Data structure

% F-16
d               = struct();
d.cLAlpha       = 2*pi;             % Lift coefficient
d.cD0           = 0.0175;           % Zero lift drag coefficient
d.k             = 1/(pi*0.8*3.09);	% Lift coupling coefficient A/R 3.09, Oswald Efficiency Factor 0.8
d.epsilon       = 0;                % rad
d.thrust        = 76.3e3;           % N
d.throttle      = 1;
d.s             = 27.87;            % wing area m^2
d.mass          = 12000;            % kg
d.inertia       = 1.7295e5;         % kg-m^2
d.c             = 2;                % m
d.sE            = 25;               % m^2
d.delta         = 0;                % rad
d.rE            = 4;                % m
d.externalAccel = [0;0;0];          % [m/s^2;m/s^2;rad/s^2[



