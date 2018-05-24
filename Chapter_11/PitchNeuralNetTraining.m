%% Pitch Neutral Net Training
% Train the pitch neural net. It uses two sets of aircraft data, dRHS
% and dRHSL. The former is the data taken during flight, the latter is
% from our model. We train it with the difference. We change the inertia
% mass and zero lift drag coefficient. We vary the speed and pitch angle
% during the training.
%
%% See also
% RungeKutta, RHSAircraft

% This is from flight testing
dRHS          = RHSAircraft;	% Get the default data structure has F-16 data
h             = 10000;
gamma         = 0.0;
v             = 250;

% Get the equilibrium state
[x,  dRHS.thrust, deltaEq, cost] = EquilibriumState( gamma, v, h, dRHS );

% Angle of attack
alpha         = atan(x(2)/x(1));
cA            = cos(alpha);
sA            = sin(alpha);

% Create the assumed properties
dRHSL         = dRHS;
dRHSL.cD0     = 2.2*dRHS.cD0;
dRHSL.k       = 1.0*dRHSL.k;

% 2 inputs
xNN     = zeros(2,1); 
d       = SigmaPiNeuralNet;
[~, d]  = SigmaPiNeuralNet( 'initialize', xNN, d );


theta	  = linspace(0,pi/8);
v       = linspace(300,200);
n       = length(theta);
aT      = zeros(1,n);
aM      = zeros(1,n);

for k = 1:n
  x(4)  = theta(k);
  x(1)  = cA*v(k);
  x(2)  = sA*v(k); 
  aT(k) = PitchDynamicInversion( x, dRHSL );
  aM(k) = PitchDynamicInversion( x, dRHS  );
end

% The delta pitch acceleration
dA        = aM - aT;

% Inputs to the neural net
v2        = v.^2;
xNN       = [theta;v2];

% Outputs for training
d.y       = dA';
[aNN, d]  = SigmaPiNeuralNet( 'batch learning', xNN, d );

% Save the data for the aircraft simulation
save( 'DRHSL','dRHSL' );
save( 'DNN', 'd'  );

for j = 1:size(xNN,2)
  aNN(j,:) = SigmaPiNeuralNet( 'output', xNN(:,j), d );
end

% Plot the results
yL        = {'\Delta a', '\Delta a_{NN}', '\theta', 'v^2'};
PlotSet(1:n,[dA;aNN';theta;v2],'x label','Input','y label',yL,'figure title','Neural Net Delta Pitch Acceleration');

