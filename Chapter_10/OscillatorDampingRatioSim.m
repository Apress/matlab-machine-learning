%% Damping ratio Demo
% Demonstrate an oscillator with different damping ratios. 
%% See also
% RungeKutta, RHSOscillator, TimeLabel

%% Initialize
nSim          = 1000;           % Number of simulation steps
dT            = 0.1;            % Time step (sec)
d             = RHSOscillator;	% Get the default data structure
d.a           = 0.0;            % Disturbance acceleration
d.omega       = 0.2;            % Oscillator frequency
zeta          = [0 0.2 0.7071 1];

%% Simulation
xPlot = zeros(length(zeta),nSim);
s     = cell(1,4);

for j = 1:length(zeta)
  d.zeta	= zeta(j);
  x     	= [0;1];          % Initial state [position;velocity]
  s{j}    = sprintf('zeta = %6.4f',zeta(j));
  for k = 1:nSim
    % Plot storage
    xPlot(j,k)  = x(1);
  
    % Propagate (numerically integrate) the state equations
    x           = RungeKutta( @RHSOscillator, 0, x, dT, d ); 
  end
end

%% Plot the results
[t,tL] = TimeLabel(dT*(0:(nSim-1)));
h = figure;
set(h,'Name','Damping Ratios');
plot(t,xPlot)
grid
xlabel(tL);
ylabel('r');
grid on
legend(s)
