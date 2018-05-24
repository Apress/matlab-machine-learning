%% AUTOMOBILEPASSING Automobile passing control
%% Form
%  passer = AutomobilePassing( passer, passee, dY, dV, dX, gain )
%
%% Description
% Implements passing control by pointing the wheels at the target.
% Generates a steering angle demand and torque demand.
%
% Prior to passing the passState is 0. During the passing it is 1.
% When it returns to its original lane the state is set to 0.
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
%   passee  (1,1)  Car data structure
%   dY      (1,1)  Relative position in y
%   dV      (1,1)  Relative velocity in x
%   dX      (1,1)  Relative position in x
%   gain    (1,3)  Gains [position velocity position derivative]
%
%% Outputs
%   passer	(1,1)  Car data structure with updated fields:
%                   .passState 
%                   .delta     
%                   .errOld   
%                   .torque	   

function passer = AutomobilePassing( passer, passee, dY, dV, dX, gain )

% Default gains
if( nargin < 6 )
	gain = [0.05 80 120];
end

% Lead the target unless the passing car is in front
if( passee.x(1) + dX > passer.x(1) )
	xTarget = passee.x(1) + dX;
else
	xTarget = passer.x(1) + dX;
end

% This causes the passing car to cut in front of the car being passed
if( passer(1).passState == 0 )
	if( passer.x(1) > passee.x(1) + 2*dX )
    dY = 0;
    passer(1).passState = 1;
	end
else
	dY = 0;
end

% Control calculation
target          = [xTarget;passee.x(2) + dY];
theta           = passer.x(5);
dR              = target - passer.x(1:2);
angle           = atan2(dR(2),dR(1));
err             = angle - theta;
passer.delta    = gain(1)*(err + gain(3)*(err - passer.errOld));
passer.errOld   = err;
passer.torque   = gain(2)*(passee.x(3) + dV - passer.x(3));
