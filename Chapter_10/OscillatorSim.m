%% Oscillator Demo
% Demonstrate an oscillator. This is a linear spring and damper. The
% measurement is the angle between the mass and the horizon.
%% See also
% RungeKutta, RHSOscillator, TimeLabel, PlotSet

%% Initialize
nSim          = 1000;           % Simulation end time (sec)
dT            = 0.1;            % Time step (sec)
dRHS          = RHSOscillator;	% Get the default data structure
dRHS.a      	= 0.1;            % Disturbance acceleration
dRHS.omega   	= 0.2;            % Oscillator frequency
dRHS.zeta    	= 0.1;            % Damping ratio
x             = [0;0];          % Initial state [position;velocity]
baseline      = 10;             % Distance of sensor from start point
yR1Sigma      = 1;              % 1 sigma position measurement noise
yTheta1Sigma	= asin(yR1Sigma/baseline);   % 1 sigma angle measurement noise

%% Simulation
xPlot = zeros(4,nSim);

for k = 1:nSim
  
  % Measurements
  yTheta      = asin(x(1)/baseline) + yTheta1Sigma*randn(1,1);
  yR          = x(1) + yR1Sigma*randn(1,1);
  
  % Plot storage
  xPlot(:,k)  = [x;yTheta;yR];
  
  % Propagate (numerically integrate) the state equations
  x           = RungeKutta( @RHSOscillator, 0, x, dT, dRHS ); 
  
end

%% Plot the results
yL     = {'r (m)' 'v (m/s)' 'y_\theta (rad)' 'y_r (m)'};
[t,tL] = TimeLabel(dT*(0:(nSim-1)));

PlotSet( t, xPlot, 'x label', tL, 'y label', yL,...
  'plot title', 'Oscillator', 'figure title', 'Oscillator' );
