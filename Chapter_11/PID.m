%% PID Proportional Integral Derivative controller.
%% Form
%  [a, b, c, d, k] = PID( zeta, omega, tauInt, omegaR, tSamp )
%
%% Description
% Produces a state space Proportional Integral Derivative (PID) controller.
%
% The PID controller will be of the form
%
% x(k+1) = a x(k) + b u(k)
% y(k)   = c x(k) + d u(k)
%
% By designing in the frequency domain and converting to discrete
% time using a zero-order hold. The inputs are the desired damping
% ratio and undamped natural frequency of the complex mode of the
% closed-loop system and the time constant of the integrator.
%
% You must add -y to the right-hand-side of your dynamical system.
%
% This system does not compensate for the phase lag of the zero order
% hold and is only applicable to systems where the bandwidth is
% much lower than the half-sampling frequency. The continuous time
% equivalent for each axis is
%
%             Kr s         u
% y = Kp u +  ---- u + Ki ---
%            s + wR        s
%
% The function converts the result to discrete time if tSamp is entered.
%
%% Inputs
%   zeta    (1,1)	Damping ratio
%   omega   (1,1)	Undamped natural frequency (rad/s)
%   tauInt	(1,1)	Integrator time constant (s)
%   omegaR	(1,1)	Derivative term roll-off frequency (rad/s)
%   tSamp   (1,1) Sampling period (s)
%
%% Outputs
%   a       (2,2)	Plant matrix
%   b       (2,1)	Input matrix
%   c       (1,2)	Output matrix
%   d       (1,1)	Feedthrough matrix
%
%% See also:
% PID>Demo

function [a, b, c, d] = PID(  zeta, omega, tauInt, omegaR, tSamp )

% Demo
if( nargin < 1 )
  Demo;
  return
end

% Input processing
if( nargin < 4 )
  omegaR = [];
end

% Default roll-off
if( isempty(omegaR) )
  omegaR = 5*omega;
end

% Compute the PID gains
omegaI  = 2*pi/tauInt;

c2  = omegaI*omegaR;
c1  = omegaI+omegaR;
b1  = 2*zeta*omega;
b2  = omega^2;
g   = c1 + b1;
kI  = c2*b2/g;
kP  = (c1*b2 + b1.*c2  - kI)/g;
kR  = (c1*b1 + c2 + b2 - kP)/g;

% Compute the state space model
a   =  [0 0;0 -g];  
b   =  [1;g];
c   =  [kI -kR*g];
d   =  kP + kR*g;

% Convert to discrete time
if( nargin > 4 )
  [a,b] = CToDZOH(a,b,tSamp);
end

function Demo
%% PID>Demo
% Create and discretize a double integrator plant with a 0.1 second timestep,
% design the PID controller, run a simulation for 2000 steps, and generate
% plots.
%
% See also CToDZOH, TimeLabel, PlotSet

% The double integrator plant
dT            = 0.1; % s
aP            = [0 1;0 0];
bP            = [0;1];
[aP, bP]      = CToDZOH( aP, bP, dT );

% Design the controller
[a, b, c, d]  = PID(  1, 0.1, 100, 0.5, dT );

% Run the simulation
n   = 2000;
p   = zeros(2,n);
x   = [0;0];
xC  = [0;0];

for k = 1:n
  % PID Controller
  y       = x(1);
  xC      = a*xC + b*y;
  uC      = c*xC + d*y;
  p(:,k)  = [y;uC];
  x       = aP*x + bP*(1-uC); % Unit step response
end

[t,tL] = TimeLabel((0:n-1)*dT);

PlotSet(t,p,'x label',tL,'y label',{'x', 'u'},'figure title','PID','plot title','PID');


