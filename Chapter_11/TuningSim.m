%% Tuning Demo
% Demonstrate tuning a damper. The simulation is driven by random
% noise
%% See also
% RungeKutta, RHSOscillatorControl

%% Initialize
n             = 4;                    % Number of measurement sequences
nSim          = 2^16;                 % Number of time steps
dT            = 0.1;                  % Time step (sec)
dRHS          = RHSOscillatorControl;	% Get the default data structure
dRHS.omega  	= 0.1;                  % Oscillator frequency
zeta          = 0.5;                  % Damping ratio
x             = [0;0];                % Initial state [position;velocity]
y1Sigma       = 0.001;                % 1 sigma position measurement noise
a             = 1;                    % Perturbation
kPulseStop    = 10;
aPeak         = 0.7;
a1Sigma       = 0.01;

%% Simulation
xPlot = zeros(3,n*nSim);
yFFT  = zeros(1,nSim);
i     = 0;
tuned = false;
wOsc  = 0;

for j = 1:n
  aJ = a;
  for k = 1:nSim
    i = i + 1;
    % Measurements
    y           = x(1) + y1Sigma*randn;
  
    % Plot storage
    xPlot(:,i)  = [x;y];
    yFFT(k)     = y;
    dRHS.a      = aJ + a1Sigma*randn;
    if( k == kPulseStop )
    	aJ = 0;
    end
  
    % Propagate (numerically integrate) the state equations
    x           = RungeKutta( @RHSOscillatorControl, 0, x, dT, dRHS );
  end
  FFTEnergy( yFFT, dT );
  [~, ~, wP] = FFTEnergy( yFFT, dT, aPeak );
  if( length(wP) == 1 )
    wOsc    = wP;
    fprintf(1,'Estimated oscillator frequency %12.4f rad/s\n',wP);
    dRHS.c	= 2*zeta*wOsc;   
  else
    fprintf(1,'Tuned\n');
  end
end

%% Plot the results
yL     = {'r (m)' 'v (m/s)' 'y_r (m)'};
[t,tL] = TimeLabel(dT*(0:(n*nSim-1)));

PlotSet( t, xPlot, 'x label', tL, 'y label', yL,...
  'plot title', 'Oscillator', 'figure title', 'Oscillator' );



