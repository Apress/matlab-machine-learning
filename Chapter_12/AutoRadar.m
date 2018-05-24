%% AUTORADAR Models automotive radar for simulation
%% Form
%   [y, v] = AutoRadar( x, d )
%
%% Description
%   Automotive (2D) radar.
%
%   Returns azimuth, range and range rate. The state vector may be
%   any order. You pass the indices for the position and velocity states.
%   The angle of the car is passed in d even though it may be in the state
%   vector. The target must be within the field of view. If it is not the
%   data is zero and the valid flag is 0. The radar also has a maximum
%   range.
%
%   The position and velocity of the radar is entered through the 
%   data structure.
%
%   This does not model the signal to noise ratio of a radar.
%   The power received of a radar goes as 1/r^4. In this model the signal
%   goes to zero at the maximum range.
%
%   The valid flag is set to zero if the target is not in the field of
%   view or out of range.
%
%   x can be organized in any way you would like. For example:
%
%   x    = [x1;y1;vX1;vY1;x3;y3;vX3;vY3];
%
%   d.kR = [1 5;2 6];
%   d.kV = [3 7;4 8];
%
%   Type AutoRadar for a demo. The tracked car is oscillating about 
%   the y position.
%
%% Inputs
%   x	(:,n)   States may be any order.
%   d (1,1)   Filter data structure
%               .kR         (2,:) Position index
%               .kV         (2,:) Velocity index
%               .kT         (1,:) Torque index
%               .xR         (2,:) Position of radar
%               .vR         (2,:) Velocity of radar
%               .theta      (1,:) Angle of car +x car respect to +x
%                                 inertial
%               .noise      (3,1) 1 sigma noise (m; m/s; rad)
%               .fOV        (1,1) Angle from +x for detection (rad)
%               .maxRange   (1,1) Maximum range (m)
%               .t          (1,n) Time vector
%               .noLimits   (1,1) Set to 1 if range and fov limits are to
%                                 be ignored.
%
%% Outputs
%   y	(3*m,1)	Measurements [range;range rate; azimuth] (m, m/s, rad)
%   v   (m,1)   1 if the measurement is valid, 0 if it not valid
%

function [y, v] = AutoRadar( x, d )

% Demo
if( nargin < 1 )
  if(  nargout == 0 )
    Demo;
  else
    y = DataStructure;
  end
	return
end

m    = size(d.kR,2);
n    = size(x,2);
y    = zeros(3*m,n);
v    = ones(m,n);
cFOV = cos(d.fOV);

% Build an array of random numbers for speed
ran = randn(3*m,n);

% Loop through the time steps
for j = 1:n
  i     = 1;
  s     = sin(d.theta(j));
  c     = cos(d.theta(j));
  cIToC = [c s;-s c];

  % Loop through the targets
  for k = 1:m
    xT      = x(d.kR(:,k),j);
    vT      = x(d.kV(:,k),j);
    th      = x(d.kT(1,k),j);
    s       = sin(th);
    c       = cos(th);
    cTToIT  = [c -s;s c];
    dR      = cIToC*(xT - d.xR(:,j));
    dV      = cIToC*(cTToIT*vT - cIToC'*d.vR(:,j));
    rng     = sqrt(dR'*dR);
    uD      = dR/rng;

    % Apply limits
    if( d.noLimits || (uD(1) > cFOV && rng < d.maxRange) )
      y(i  ,j)	= rng               + d.noise(1)*ran(i  ,j);
      y(i+1,j)	= dR'*dV/y(i,j)     + d.noise(2)*ran(i+1,j);
      y(i+2,j)	= atan(dR(2)/dR(1)) + d.noise(3)*ran(i+2,j);
    else
      v(k,j)      = 0;
    end
    i   = i + 3;
  end
end

% Plot if no outputs are requested
if( nargout < 1 )
  [t, tL]	= TimeLabel( d.t );

  % Every 3rd y is azimuth
  i       = 3:3:3*m;
  y(i,:)	= y(i,:)*180/pi;

  yL      = {'Range (m)' 'Range Rate (m/s)', 'Azimuth (deg)' 'Valid Data'};
  PlotSet(t,[y;v],'x label',tL','y label',yL,'figure title','Auto Radar',...
           'plot title','Auto Radar');
  
  clear y
end

%% AutoRadar>>DataStructure
function d = DataStructure
%% Default data structure
d.kR        = [1;2];
d.kV        = [3;4];
d.kT        = 5;
d.theta     = [];
d.xR        = [];
d.vR        = [];
d.noise     = [0.02;0.0002;0.01];
d.fOV       = 0.95*pi/16;
d.maxRange	= 60;
d.noLimits  = 1;
d.t         = [];

%% AutoRadar>>Demo
function Demo
% Shows radar performance as range changes

omega       = 0.02;
d           = DataStructure;
n           = 1000;
d.xR        = [linspace( 0,1000,n);zeros(1,n)];
d.vR        = [ones(1,n);zeros(1,n)];
t           = linspace(0,1000,n);
a           = omega*t;
x           = [linspace(10,10+1.05*1000,n);2*sin(a);...
               	1.05*ones(1,n); 2*omega*cos(a);zeros(1,n)];
d.theta     = zeros(1,n);
d.t         = t;

AutoRadar( x, d );

