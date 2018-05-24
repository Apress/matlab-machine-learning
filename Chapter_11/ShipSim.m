%% Ship Control Demo
% Demonstrate adaptive control of a ship. We want to control the heading
% angle as the linear velocity changes. 
%% See also
% RungeKutta, RHSShip, QCR

%% Initialize
nSim	= 10000;                      % Number of time steps
dT    = 1;                          % Time step (sec)
dRHS	= RHSShip;                    % Get the default data structure
x     = [0;0.001;0.0];              % [lateral velocity;angular velocity;heading]
u     = linspace(10,20,nSim)*0.514; % m/s
qC    = eye(3);                     % State cost in the controller
rC    = 0.1;                        % Control cost in the controller

% Desired heading angle
psi   = [zeros(1,nSim/4) ones(1,nSim/4) 2*ones(1,nSim/4) zeros(1,nSim/4)];

%% Simulation
xPlot = zeros(3,nSim);
gain  = zeros(nSim,3);
delta = zeros(1,nSim);
for k = 1:nSim
	% Plot storage
	xPlot(:,k)  = x;
	dRHS.u      = u(k);
  
	% Control
	% Get the state space matrices
	[~,a,b]     = RHSShip( 0, x, dRHS );
	gain(k,:)   = QCR( a, b, qC, rC );
	dRHS.delta  = -gain(k,:)*[x(1);x(2);x(3) - psi(k)]; % Rudder angle
	delta(k)    = dRHS.delta;
  
	% Propagate (numerically integrate) the state equations
	x           = RungeKutta( @RHSShip, 0, x, dT, dRHS );
end

%% Plot the results
yL     = {'v (m/s)' 'r (rad/s)' '\psi (rad)' 'u (m/s)' 'Gain v' 'Gain r' 'Gain \psi' '\delta (rad)' };
[t,tL] = TimeLabel(dT*(0:(nSim-1)));

PlotSet( t, [xPlot;u], 'x label', tL, 'y label', yL(1:4),...
  'plot title', 'Ship', 'figure title', 'Ship' );

PlotSet( t, [gain';delta], 'x label', tL, 'y label', yL(5:8),...
  'plot title', 'Ship', 'figure title', 'Ship' );