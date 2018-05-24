%% Aircraft Closed Loop Demo
% Demonstrate learning control of an aircraft. It uses a PID 
% controller with a sigma-pi neural net. The aircraft is a simple F-16
% model.
%
%% See also
% RungeKutta, RHSAircraft

% Options for control
addLearning   = true;
addControl    = true;

%% Initialize the simulation
nSim          = 1000;    % Number of time steps
dT            = 0.1;      % Time step (sec)
dRHS          = RHSAircraft;	% Get the default data structure has F-16 data
h             = 10000;
gamma         = 0.0;
v             = 250;
nPulse        = 10;
pitchDesired  = 0.2;
dL            = load('PitchNNWeights');
[x,  dRHS.thrust, deltaEq, cost] = EquilibriumState( gamma, v, h, dRHS );
fprintf(1,'Finding Equilibrium: Starting Cost %12.4e Final Cost %12.4e\n',cost);

if( addLearning )
  temp	= load('DRHSL');
  dRHSL	= temp.dRHSL;
  temp	= load('DNN');
  dNN   = temp.d;
else
  temp	= load('DRHSL');
  dRHSL	= temp.dRHSL;
end

accel = [0.0;0.0;0.0];

% Design the PID Controller
[aC, bC, cC, dC]  = PID(  1, 0.1, 100, 0.5, dT );
dRHS.delta        = deltaEq;
xDotEq            = RHSAircraft( 0, x, dRHS );
aEq               = xDotEq(3);
xC                = [0;0];

%% Simulation
xPlot = zeros(length(x)+8,nSim);
for k = 1:nSim
  
  % Control
	[~,L,D,pD]	= RHSAircraft( 0, x, dRHS );
 
  % Measurement
  pitch       = x(4);
  
  % PID control
  if( addControl )
    pitchError  = pitch - pitchDesired;
    xC          = aC*xC + bC*pitchError;
    aDI         = PitchDynamicInversion( x, dRHSL );
    aPID        = -(cC*xC + dC*pitchError);
  else
    pitchError  = 0;
    aPID        = 0;
  end
  
  % Learning
  if( addLearning )
    xNN       = [x(4);x(1)^2 + x(2)^2];
    aLearning = SigmaPiNeuralNet( 'output', xNN, dNN );
  else
    aLearning = 0;
  end
  
  if( addControl )
    aTotal      = aPID - (aDI + aLearning);

    % Convert acceleration to elevator angle
    gain        = dRHS.inertia/(dRHS.rE*dRHS.sE*pD);
    dRHS.delta 	= asin(gain*aTotal);
  else
    dRHS.delta  = deltaEq;
  end
 
	% Plot storage
	xPlot(:,k)  = [x;L;D;aPID;pitchError;dRHS.delta;aPID;aDI;aLearning];
  
  % Propagate (numerically integrate) the state equations
  if( k > nPulse )
    dRHS.externalAccel = [0;0;0];
  else
    dRHS.externalAccel = accel;
  end
  x	= RungeKutta( @RHSAircraft, 0, x, dT, dRHS );
  
  % A crash
  if( x(5) <= 0 )
    break;
  end
end


%% Plot the results
xPlot   = xPlot(:,1:k);
yL      = {'u (m/s)' 'w (m/s)' 'q (rad/s)' '\theta (rad)' 'h (m)' 'L (N)' 'D (N)' 'a_{PID} (rad/s^2)' '\delta\theta (rad)' '\delta (rad)' ...
  'a_{PID}' 'a_{DI}' 'a_{L}'};
[t,tL]  = TimeLabel(dT*(0:(k-1)));

PlotSet( t, xPlot(1:5,:), 'x label', tL, 'y label', yL(1:5),...
  'plot title', 'Aircraft', 'figure title', 'Aircraft State' );
PlotSet( t, xPlot(6:7,:), 'x label', tL, 'y label', yL(6:7),...
  'plot title', 'Aircraft', 'figure title', 'Aircraft L and D' );
PlotSet( t, xPlot(8:10,:), 'x label', tL, 'y label', yL(8:10),...
  'plot title', 'Aircraft', 'figure title', 'Aircraft Control' );
PlotSet( t, xPlot(11:13,:), 'x label', tL, 'y label', yL(11:13),...
  'plot title', 'Aircraft', 'figure title', 'Control Acceleratins' );


