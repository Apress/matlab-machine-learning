%% Ship Control Demo
% Demonstrate adaptive control of a ship. We want to control the heading
% angle as the linear velocity changes. This simulation has
% disturbances.
%% See also
% RungeKutta, RHSShip, QCR

%% Initialize
nSim	= 300;                      % Number of time steps
dT    = 1;                          % Time step (sec)
dRHS	= RHSShip;                    % Get the default data structure
x     = [0;0.001;0.0];              % [lateral velocity;angular velocity;heading]
u     = linspace(10,20,nSim)*0.514; % m/s
qC    = eye(3);                     % State cost in the controller
rC    = 0.1;                        % Control cost in the controller
alpha = [0.01;0.001];               % 1 sigma disturbances

% Desired heading angle
psi   = [zeros(1,nSim/6) ones(1,5*nSim/6)];

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
	dRHS.alpha  = [alpha.*randn(2,1);0];
	dRHS.delta  = -gain(k,:)*[x(1);x(2);x(3) - psi(k)]; % Rudder angle
	delta(k)    = dRHS.delta;
  
	% Propagate (numerically integrate) the state equations
	x           = RungeKutta( @RHSShip, 0, x, dT, dRHS );
end

%% Plot the results
yL     = {'v (m/s)' 'r (rad/s)' '\psi (rad)' 'u (m/s)' 'Gain v' 'Gain r' 'Gain \psi' '\delta (rad)' };
[t,tL] = TimeLabel(dT*(0:(nSim-1)));

PlotSet( t, [xPlot(1:3,:);delta], 'x label', tL, 'y label', yL([1:3 8]),...
  'plot title', 'Ship', 'figure title', 'Ship' );
