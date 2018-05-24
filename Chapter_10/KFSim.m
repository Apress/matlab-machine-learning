%% KFSim
% Demonstrate a Kalman Filter for an oscillator. The oscillator is a
% single degree of freedom (2 state) system with a spring and a damper.
% The measurement is of the position. Simulation is using 4th order
% Runge-Kutta integration. The oscillator has a step input.
%
%% See also
% RungeKutta, RHSOscillator, TimeLabel, KFInitialize, KFUpdate, KFPredict
% PlotSet

%% Initialize
tEnd          = 100.0;            % Simulation end time (sec)
dT            = 0.1;              % Time step (sec)
d             = RHSOscillator;    % Get the default data structure
d.a           = 0.1;              % Disturbance acceleration
d.omega       = 0.2;              % Oscillator frequency
d.zeta        = 0.1;              % Damping ratio
x             = [0;0];            % Initial state [position;velocity]
y1Sigma        = 1;               % 1 sigma position measurement noise

% xdot = a*x + b*u
a             = [0 1;-2*d.zeta*d.omega -d.omega^2]; % Continuous time model
b             = [0;1];            % Continuous time input matrix

% x[k+1] = f*x[k] + g*u[k]
[f,g]         = CToDZOH(a,b,dT);  % Discrete time model
xE            = [0.3; 0.1];       % Estimated initial state
q             = [1e-6 1e-6];      % Model noise covariance ;
                                  % [1e-4 1e-4] is for low model noise test
dKF           = KFInitialize('kf','m',xE,'a',f,'b',g,'h',[1 0],...
                             'r',y1Sigma^2,'q',diag(q),'p',diag(xE.^2));

%% Simulation
nSim  = floor(tEnd/dT) + 1;
xPlot = zeros(5,nSim);

for k = 1:nSim
  
  % Measurements
  y           = x(1) + y1Sigma*randn(1,1);
  
  % Update the Kalman Filter
  dKF.y       = y;
  dKF         = KFUpdate(dKF);
  
  % Plot storage
  xPlot(:,k)  = [x;y;dKF.m-x];
  
  % Propagate (numerically integrate) the state equations
  x           = RungeKutta( @RHSOscillator, 0, x, dT, d ); 
  
  % Propagate the Kalman Filter
  dKF.u       = d.a;
	dKF         = KFPredict(dKF);
 
end

%% Plot the results
yL     = {'r (m)' 'v (m/s)'  'y (m)' '\Delta r_E (m)' '\Delta v_E (m/s)' };
[t,tL] = TimeLabel(dT*(0:(nSim-1)));

PlotSet( t, xPlot, 'x label', tL, 'y label', yL,...
  'plot title', 'Oscillator', 'figure title', 'KF Demo' );
