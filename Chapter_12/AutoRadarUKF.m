%% AUTORADARUKF Radar model for the auto UKF
%% Form
%  y = AutoRadarUKF( x, d )
%
%% Description
% Automotive (2D) radar model for use with UKF.
%
% Returns azimuth, range and range rate. 
%
%% Inputs
%   x	(4,1)   State
%   d  (.)    Filter data structure
%               .theta  (1,:) Angle of car +x with respect to +x inertial
%
%% Outputs
%   y	(3,1)	Measurements [range;range rate; azimuth] (m, m/s, rad)
%

function y = AutoRadarUKF( x, d )

s       = sin(d.theta);
c       = cos(d.theta);
cIToC   = [c s;-s c];
dR      = cIToC*x(1:2);
dV      = cIToC*x(3:4);

rng     = sqrt(dR'*dR);
y   	  = [rng; dR'*dV/rng; atan(dR(2)/dR(1))];
