%% UKFPSim
% Demonstrate parameter learning using Unscented Kalman Filter. 
% This ohnly has an update function. The states (position and velocity)
% are assumed known. It is estimating the undamped natural frequency.
%
%% See also
% RungeKutta, RHSOscillator, TimeLabel, KFInitialize, UKFPUpdate
% AngleMeasurement, PlotSet, UKFPUpdate.

%% Initialize
nSim            = 150;             % Simulation steps
dT              = 0.01;             % Time step (sec)
d               = RHSOscillator;    % Get the default data structure
d.a             = 0.0;              % Disturbance acceleration
d.zeta          = 0.0;              % Damping ratio
d.omega         = 2;                % Undamped natural frequency
x               = [1;0];            % Initial state [position;velocity]
y1Sigma         = 0.0001;           % 1 sigma measurement noise
q               = 0.001;            % Plant uncertainty
p               = 0.4;            	% Initial covariance for the parameter
dRHSUKF       	= struct('a',0.0,'zeta',0.0,'eta',0.1);
dKF             = KFInitialize( 'ukfp','x',x,'f',@RHSOscillatorUKF,...
                                'fData',dRHSUKF,'r',y1Sigma^2,'q',q,...
                                'p',p,'hFun',@LinearMeasurement,...
                                'dT',dT,'eta',d.omega/2,...
                                'alpha',1,'kappa',2,'beta',2);

dKF             = UKFPWeight( dKF );
y               = LinearMeasurement( x );

%% Simulation
xPlot = zeros(5,nSim);

for k = 1:nSim
  
  % Update the Kalman Filter parameter estimates
  dKF.x       = x;
  
  % Plot storage
  xPlot(:,k)  = [y;x;dKF.eta;dKF.p];
  
  % Propagate (numerically integrate) the state equations
  x           = RungeKutta( @RHSOscillator, 0, x, dT, d );
  
	% Measurements
  y           = LinearMeasurement( x ) + y1Sigma*randn;
 
  dKF.y       = y;
  dKF         = UKFPUpdate(dKF);
  
end

%% Plot the results
yL     = {'y (rad)' 'r (m)' 'v (m/s)'  '\omega (rad/s)' 'p' };
[t,tL] = TimeLabel(dT*(0:(nSim-1)));

PlotSet( t, xPlot, 'x label', tL, 'y label', yL,...
  'plot title', 'UKF Parameter Estimation', 'figure title', 'UKF Parameter Estimation' );
