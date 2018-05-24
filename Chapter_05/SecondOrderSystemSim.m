%% SECONDORDERSYSTEMSIM Run the system simulation.
%% Form
%  [xP, t, tL] = SecondOrderSystemSim( d )
%  SecondOrderSim % Demo
%
%% Description
% Run a simulation for a second order system. Plots the results.
%
% Type SecondOrderSystemSim for a demo.
%
%% Inputs
%  d         (.)  Data structure
%                .omega         (1,1) Undamped natural frequency (rad/s)
%                .zeta          (1,1) Damping ratio
%                .omegaU        (1,1) Sine input frequency (rad/s)
%                .input         (1,:) 'pulse', 'sinuosoid', 'step'
%                .tPulseBegin   (1,1) Time of pulse start (s)
%                .tPulseEnd     (1,1) Time of pulse end (s)
%                .tEnd          (1,1) Sim end time (s)
%
%% Outputs
%  xP
%  t
%  tL

function [xP, t, tL] = SecondOrderSystemSim( d )

if( nargin < 1 )
  if( nargout > 0 )
    xP  = DefaultDataStructure;
  else
    d   = SecondOrderSystemSim;
    SecondOrderSystemSim( d );
  end
  return
end

omega   = max([d.omega d.omegaU]);
dT      = 0.1*2*pi/omega;
n       = floor(d.tEnd/dT);
xP      = zeros(2,n);
x       = [0;0];
t       = 0;

for k = 1:n
  [~,u]   = RHS(t,x,d);
  xP(:,k) = [x(1);u];
  x       = RungeKutta( @RHS, t, x, dT, d );
  t       = t + dT;
end

[t,tL] = TimeLabel((0:n-1)*dT);

if( nargout == 0 )
  PlotSet(t,xP,'x label',tL,'y label', {'x' 'u'}, 'figure title','Filter');
end

%% SecondOrderSystemSim>>RHS
function [xDot,u] = RHS( t, x, d )

u = 0;

switch( lower(d.input) )
  case 'pulse'
    if( t > d.tPulseBegin && t < d.tPulseEnd )
      u = 1;
    end
    
  case 'step'
    u = 1;
  
  case 'sinusoid'
    u = sin(d.omegaU*t);
end

f = u - 2*d.zeta*d.omega*x(2) - d.omega^2*x(1);

xDot = [x(2);f];

%% SecondOrderSystemSim>>DefaultDataStructure
function d = DefaultDataStructure
% Simulates a damped oscillator with as step input.
d               = struct();
d.omega         = 0.1;
d.zeta          = 0.4;
d.omegaU        = 0.3;
d.input         = 'step';
d.tPulseBegin   = 10;
d.tPulseEnd     = 20;
d.tEnd          = 100;
