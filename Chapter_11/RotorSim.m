%% Rotor Control Demo
% Demonstrate model reference adaptive control
%% See also
% RungeKutta, RHSRotor

%% Initialize
nSim	= 4000;     % Number of time steps
dT    = 0.1;      % Time step (sec)
dRHS	= RHSRotor;	% Get the default data structure
dC    = MRAC;
dS    = SquareWave;
x    	= 0.1;      % Initial state vector

%% Simulation
xPlot = zeros(4,nSim);
theta = zeros(2,nSim);
t     = 0;
for k = 1:nSim
  
	% Plot storage
	xPlot(:,k)  = [x;dC.x(5);dC.u;dC.uC];
  theta(:,k)  = dC.x(3:4);
  [uC, dS]    = SquareWave( t, dS );
  dC.uC       = 2*(uC - 0.5);
  dC          = MRAC( x, dC );
  dRHS.u      = dC.u;
  
  % Propagate (numerically integrate) the state equations
  x           = RungeKutta( @RHSRotor, t, x, dT, dRHS );
  t           = t + dT;
end

%% Plot the results
yL          = {'\omega (rad/s)' 'u'};
[t,tL]      = TimeLabel(dT*(0:(nSim-1)));

h = PlotSet( t, xPlot, 'x label', tL, 'y label', yL,'plot title', {'Angular Rate' 'Control'},...
        'figure title', 'Rotor', 'plot set',{[1 2] [3 4]},'legend',{{'true' 'estimated'} {'Control' 'Command'}} );
      
PlotSet( theta(1,:), theta(2,:), 'x label', '\theta_1',...
        'y label','\theta_2', 'plot title', 'Controller Parameters',...
        'figure title', 'Controller Parameters' );