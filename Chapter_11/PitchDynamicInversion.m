%% PITCHDYNAMICINVERSION Pitch acceleration
%% Form
% d = PitchDynamicInversion;
% qDot = PitchDynamicInversion( x, d )
%
%% Description
% Pitch acceleration.
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
%                .s         (1,1) Wetted area (m^2)
%                .inertia   (1,1) Pitch inertia (kg-m^2)
%                .c         (1,1) CP/CM offset along x (m)
%                .sE        (1,1) Elevator area (m^2)
%                .delta   	(1,1) Elevator angle (rad)
%
%% Outputs
%  qDot	(1,1) Pitch acceleration (rad/s)
%
%% References
% None.

function qDot = PitchDynamicInversion( x, d )

if( nargin < 1 )
  qDot = DataStructure;
  return
end

u     = x(1);
w     = x(2);
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

z     = -lift*cA - drag*sA;
m     = d.c*z;
qDot  = m/d.inertia;

%% PitchDynamicInversion>>DataStructure
function d = DataStructure
% Data structure

% F-16
d               = struct();
d.cLAlpha       = 2*pi;             % Lift coefficient
d.cD0           = 0.0175;           % Zero lift drag coefficient
d.k             = 1/(pi*0.8*3.09);	% Lift coupling coefficient A/R 3.09, Oswald Efficiency Factor 0.8
d.s             = 27.87;            % wing area m^2
d.inertia       = 1.7295e5;         % kg-m^2
d.c             = 2;                % m
d.sE            = 25;               % m^2
d.delta         = 0;                % rad
d.rE            = 4;                % m
d.externalAccel = [0;0;0];          % [m/s^2;m/s^2;rad/s^2[



