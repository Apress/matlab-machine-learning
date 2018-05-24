%% Tuning Demo
% Demonstrate tuning a damper.
%% See also
% RungeKutta, RHSOscillator


%% Initialize
nSim          = 2^16;           % Number of time steps
dT            = 0.1;            % Time step (sec)
dRHS          = RHSOscillator;	% Get the default data structure
dRHS.omega  	= 0.1;            % Oscillator frequency
dRHS.zeta     = 0.1;            % Damping ratio
x             = [1;0];          % Initial state [position;velocity]
y1Sigma       = 0.000;          % 1 sigma position measurement noise

%% Simulation
xPlot = zeros(3,nSim);

for k = 1:nSim
  
  % Measurements
  y           = x(1) + y1Sigma*randn;
  
  % Plot storage
  xPlot(:,k)  = [x;y];
  
  % Propagate (numerically integrate) the state equations
  x           = RungeKutta( @RHSOscillator, 0, x, dT, dRHS ); 
  
end

%% Plot the results
yL     = {'r (m)' 'v (m/s)' 'y_r (m)'};
[t,tL] = TimeLabel(dT*(0:(nSim-1)));

PlotSet( t, xPlot, 'x label', tL, 'y label', yL,...
  'plot title', 'Oscillator', 'figure title', 'Oscillator' );


FFTEnergy( xPlot(3,:), dT );
