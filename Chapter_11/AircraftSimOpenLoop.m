%% Aircraft Open Loop Demo
% Demonstrate uncontrolled motion of an aircraft.
%% See also
% RungeKutta, RHSAircraft

%% Initialize
nSim    = 2000;    % Number of time steps
dT      = 0.1;      % Time step (sec)
dRHS    = RHSAircraft;	% Get the default data structure has F-16 data
h       = 10000;
gamma   = 0.0;
v       = 250;
nPulse  = 10;
[x,  dRHS.thrust, dRHS.delta, cost] = EquilibriumState( gamma, v, h, dRHS );
fprintf(1,'Finding Equilibrium: Starting Cost %12.4e Final Cost %12.4e\n',cost);

accel = [0.0;0.1;0.0];

%% Simulation
xPlot = zeros(length(x)+2,nSim);
for k = 1:nSim
	% Plot storage
  [~,L,D]     = RHSAircraft( 0, x, dRHS );
	xPlot(:,k)  = [x;L;D];
  % Propagate (numerically integrate) the state equations
  if( k > nPulse )
    dRHS.externalAccel = [0;0;0];
  else
    dRHS.externalAccel = accel;
  end
  x           = RungeKutta( @RHSAircraft, 0, x, dT, dRHS );
  if( x(5) <= 0 )
    break;
  end
end

xPlot = xPlot(:,1:k);

%% Plot the results
yL     = {'u (m/s)' 'w (m/s)' 'q (rad/s)' '\theta (rad)' 'h (m)' 'L (N)' 'D (N)'};
[t,tL] = TimeLabel(dT*(0:(k-1)));

PlotSet( t, xPlot(1:5,:), 'x label', tL, 'y label', yL(1:5),...
  'plot title', 'Aircraft', 'figure title', 'Aircraft State' );
PlotSet( t, xPlot(6:7,:), 'x label', tL, 'y label', yL(6:7),...
  'plot title', 'Aircraft', 'figure title', 'Aircraft L and D' );



