%% AUTOMOBILEINITIALIZE Initialize the automobile data structure.
%
%% Form
%  d = AutomobileInitialize( varargin )
%
%% Description
% Initializes the data structure using parameter pairs.
%
%% Inputs
% varargin:  ('parameter',value,...)
%
% 'mass'                                   (1,1) (kg)
% 'steering angle'                         (1,1) (rad)
% 'position tires'                         (2,4) (m)
% 'frontal drag coefficient'               (1,1)
% 'side drag coefficient'                  (1,1)
% 'tire friction coefficient'              (1,1)
% 'tire radius'                            (1,1) (m)
% 'engine torque'                          (1,1) (Nm)
% 'rotational inertia'                     (1,1) (kg-m^2)
% 'state'                                  (6,1) [m;m;m/s;m/s;rad;rad/s]
% 'rolling resistance coefficients'        (1,2)
% 'height automobile'                      (1,1) (m)
% 'side and frontal automobile dimensions' (1,2) [m m]
%
%% Outputs
%   d	(.)  Data structure


function d = AutomobileInitialize( varargin )

% Defaults
d.mass        = 1513;
d.delta       = 0;
d.r           = [  1.17 1.17 -1.68 -1.68;...
                  -0.77 0.77 -0.77  0.77];
d.cDF         = 0.25;
d.cDS         = 0.5;
d.cF         	= 0.01; % Ordinary car tires on concrete
d.radiusTire	= 0.4572; % m
d.torque      = d.radiusTire*200.0; % N
d.inr         = 2443.26;
d.x           = [0;0;0;0;0;0];
d.fRR         = [0.013 6.5e-6];
d.dim         = [1.17+1.68 2*0.77];
d.h           = 2/0.77;
d.errOld      = 0;
d.passState   = 0;

n = length(varargin);

for k = 1:2:length(varargin)
  switch lower(varargin{k})
    case 'mass'
      d.mass        = varargin{k+1};
    case 'steering angle'
      d.delta       = varargin{k+1}; 
    case 'position tires'
      d.r           = varargin{k+1};
    case 'frontal drag coefficient'
      d.cDF         = varargin{k+1};
    case 'side drag coefficient'
      d.cDS         = varargin{k+1};
    case 'tire friction coefficient'
      d.cF          = varargin{k+1};
    case 'tire radius'
      d.radiusTire	= varargin{k+1};
    case 'engine torque'
      d.torque      = varargin{k+1};
    case 'rotational inertia'
      d.inertia     = varargin{k+1};
    case 'state'
      d.x           = varargin{k+1};
    case 'rolling resistance coefficients'
      d.fRR         = varargin{k+1};
    case 'height automobile'
      d.h           = varargin{k+1};
    case 'side and frontal automobile dimensions'
      d.dim         = varargin{k+1};
  end
end

% Processing
d.areaF      = d.dim(2)*d.h;
d.areaS      = d.dim(1)*d.h;

