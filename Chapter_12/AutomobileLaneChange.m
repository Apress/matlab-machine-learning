%% AUTOMOBILELANECHANGE Automobile lane change control
%% Form
%   passer = AutomobileLaneChange( passer, dY, v, gain )
%
%% Description
% Implements lane change control by pointing the wheels at the target.
% Generates a steering angle demand and torque demand.
%
%% Inputs
%   passer	(1,1)  Car data structure
%                   .mass      (1,1) Mass (kg)
%                   .delta     (1,1) Steering angle (rad)
%                   .r         (2,4) Position of wheels (m)
%                   .cD        (1,1) Drag coefficient
%                   .cF        (1,1) Friction coefficient
%                   .torque	   (1,1) Motor torque (Nm)
%                   .area      (1,1) Frontal area for drag (m^2)
%                   .x         (6,1) [x;y;vX;vZ;theta;omega]
%                   .errOld    (1,1) Old position error
%                   .passState (1,1) State of passing maneuver
%   dX      (1,1)  Lead in x
%   dY      (1,1)  Relative position in y
%   dV      (1,1)  Relative velocity in x
%   gain    (1,3)  Gains [position velocity position derivative]
%
%% Outputs
%   passer	(1,1)  Car data structure with updated fields:
%                   .delta 
%                   .errOld
%                   .torque


function passer = AutomobileLaneChange( passer, dX, y, v, gain )

% Default gains
if( nargin < 5 )
	gain = [0.05 80 120];
end

% Lead the target unless the passing car is in front
xTarget         = passer.x(1) + dX;

% Control calculation
target          = [xTarget;y];
theta           = passer.x(5);
dR              = target - passer.x(1:2);
angle           = atan2(dR(2),dR(1));
err             = angle - theta;
passer.delta    = gain(1)*(err + gain(3)*(err - passer.errOld));
passer.errOld   = err;
passer.torque   = gain(2)*(v - passer.x(3));


