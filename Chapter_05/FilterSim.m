%% FILTERSIM Run a simulation of a filter.
%% Form
%  FilterSim( d )
%  FilterSim % Demo
%
%% Description
% Run a simulation for a second order filter
% Type FilterSim for a demo. The demo shows the pulse response.
%
%% Inputs
%  d         (.)  Data structure
%
%% Outputs
%  None

function FilterSim( d )

if( nargout < 1 )
  d  = DefaultDataStructure;
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

PlotSet(t,xP,'x label',tL,'y label', {'x' 'u'}, 'figure title','Filter');

%% FilterSim>>RHS
function [xDot,u] = RHS( t, x, d )

u = 0;

switch( lower(d.input) )
  case 'pulse'
    if( t > d.tPulseBegin && t < d.tPulseEnd )
      u = 1;
    end
    
  case 'step'
    u = 1;
  
  case 'sinuosoid'
    u = sin(d.omegaU*t);
    
end

f = u - 2*d.zeta*d.omega*x(2) - d.omega^2*x(1);

xDot = [x(2);f];

%% FilterSim>>DefaultDataStructure
function d = DefaultDataStructure

d               = struct();
d.omega         = 0.1;
d.zeta          = 0.4;
d.omegaU        = 0.3;
d.input         = 'pulse';
d.tPulseBegin   = 10;
d.tPulseEnd     = 20;
d.tEnd          = 100;

