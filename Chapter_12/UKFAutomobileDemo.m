%% UKF automobile demo.
%
% This models a car driving near a car with radar. The cars
% are at different speeds and the track car performs a passing and lane
% change maneuver.
%
% The demo uses the Unscented Kalman Filter (UKF). 
%
% The simulation is run first and then the UKF estimates the trajectory
% of the tracked car. The demo also computes the MHT distance for the
% tracked car. The estimator starts with an estimated state of zero,
% meaning the tracked car and car with radar coincide. This leads to 
% a large MHT distance at the start.
%
% The car maneuvers and initial states can be modified. 
%
% Things to try;
%  1. Add more cars.
%  2. Make the simulation parameters different from the filter
%   
%  See also AutoRadar, AutomobilePassing, AutomobileLaneChange,
%  RHSAutomobile, RHSAutomobileXY, AutoRadarUKF

%% Initialize

% Set the seed for the random number generators. 
% If the seed is not set each run will be different.
seed = 45198;
rng(seed);

% Car control
laneChange = 1;

% Clear the data structure
d = struct;

% Car 1 has the radar
d.car(1) = AutomobileInitialize( ...
             'mass', 1513,...
             'position tires', [1.17 1.17 -1.68 -1.68; -0.77 0.77 -0.77 0.77], ...
             'frontal drag coefficient', 0.25, ...
             'side drag coefficient', 0.5, ...
             'tire friction coefficient', 0.01, ...
             'tire radius', 0.4572, ...
             'engine torque', 0.4572*200, ...
             'rotational inertia', 2443.26, ...
             'rolling resistance coefficients', [0.013 6.5e-6], ...
             'height automobile', 2/0.77, ...
             'side and frontal automobile dimensions', [1.17+1.68 2*0.77]);
% Make the other car identical
d.car(2) = d.car(1);
nAuto    = length(d.car);

% Velocity set points for the cars
vSet  = [12 13];

% Time step setup
dT          = 0.1;
tEnd        = 20*60;
tLaneChange = 10*60;
tEndPassing =  6*60;
n           = ceil(tEnd/dT);

% Car initial states
x = [140; 0;12;0;0;0;...
       0; 0;11;0;0;0];

% Radar - the radar model has a field of view and maximum range
% Range drop off or S/N is not modeled
m                   = length(x)-1;
dRadar.kR           = [ 7:6:m; 8:6:m]; % State position indices
dRadar.kV           = [ 9:6:m;10:6:m]; % State velocity indices
dRadar.kT           = 11:6:m; % State yaw angle indices
dRadar.noise        = 0.1*[0.02;0.001;0.001]; % [range; range rate; azimuth]
dRadar.fOV          = pi/4; % Field of view
dRadar.maxRange     = inf;
dRadar.noLimits     = 0; % Limits are checked (fov and range)

% Plotting
yP = zeros(3*(nAuto-1),n);
vP = zeros(nAuto-1,n);

xP = zeros(length(x)+2*nAuto,n);
s  = 1:6*nAuto;

%% Simulate
t = (0:(n-1))*dT;
fprintf(1,'\nRunning the simulation...\n');
for k = 1:n
    
    % Plotting
    xP(s,k)     = x;
    j           = s(end)+1;
    
    for i = 1:nAuto
        p           = 6*i-5;
        d.car(i).x  = x(p:p+5);
        xP(j:j+1,k) = [d.car(i).delta;d.car(i).torque];
        j           = j + 2;
    end
    
    % Get radar measurements
    dRadar.theta        = d.car(1).x(5);
    dRadar.t            = t(k);
    dRadar.xR           = x(1:2);
    dRadar.vR           = x(3:4);
    [yP(:,k), vP(:,k)]	= AutoRadar( x, dRadar );
    
    % Implement Control
    
    % For all but the passing car control the velocity
	  d.car(1).torque = -10*(d.car(1).x(3) - vSet(1));
    
    % The active car
    if( t(k) < tEndPassing )
        d.car(2)	= AutomobilePassing( d.car(2), d.car(1), 3, 1.3, 10 );
    elseif ( t(k) > tLaneChange && laneChange )
        d.car(2)	= AutomobileLaneChange( d.car(2), 10, 3, 12 );
    else
        d.car(2).torque = -10*(d.car(2).x(3) - vSet(2));
    end
    
    % Integrate
    x           = RungeKutta(@RHSAutomobile, 0, x, dT, d );
end
fprintf(1,'DONE.\n');

% The state of the radar host car
xRadar = xP(1:6,:);

% Plot the simulation results
NewFigure( 'Auto' );
kX = 1:6:length(x);
kY = 2:6:length(x);
c  = 'bgrcmyk';
j  = floor(linspace(1,n,20));
for k = 1:nAuto
    plot(xP(kX(k),j),xP(kY(k),j),[c(k) '.']);
    hold on
end
legend('Auto 1','Auto 2');
for k = 1:nAuto
    plot(xP(kX(k),:),xP(kY(k),:),c(k));
end
xlabel('x (m)');
ylabel('y (m)');
set(gca,'ylim',[-5 5]);
grid

%% Implement UKF

% Covariances
r0      = diag(dRadar.noise.^2);    % Measurement 1-sigma
q0      = [1e-7;1e-7;.1;.1];        % The baseline plant covariance diagonal
p0      = [5;0.4;1;0.01].^2;        % Initial state covariance matrix diagonal

% Each step is one scan
ukf = KFInitialize( 'ukf','f',@RHSAutomobileXY,'alpha',1,...
                    'kappa',0,'beta',2,'dT',dT,'fData',struct('f',0),...
                    'p',diag(p0),'q',diag(q0),'x',[0;0;0;0],'hData',struct('theta',0),...
                  	'hfun',@AutoRadarUKF,'m',[0;0;0;0],'r',r0);
ukf = UKFWeight( ukf );

% Size arrays
k1 = find( vP > 0 );
k1 = k1(1);

% Limit to when the radar is tracking
n     = n - k1 + 1;
yP    = yP(:,k1:end);
xP    = xP(:,k1:end);
pUKF  = zeros(4,n);
xUKF  = zeros(4,n);
dMHTU = zeros(1,n);
t     = (0:(n-1))*dT;

for k = 1:n
	% Prediction step
	ukf.t      	= t(k);   
	ukf         = UKFPredict( ukf );   
    
	% Update step
	ukf.y       = yP(:,k);
	ukf         = UKFUpdate( ukf );
        
	% Compute the MHT distance
	dMHTU(1,k)	= MHTDistanceUKF( ukf );
    
	% Store for plotting
	pUKF(:,k)		= diag(ukf.p);
	xUKF(:,k)   = ukf.m;
end

% Transform the velocities into the inertial frame
for k = 1:n
	c           = cos(xP(5,k));
	s           = sin(xP(5,k));
	cCarToI     = [c -s;s c];
	xP(3:4,k)   = cCarToI*xP(3:4,k);
    
	c           = cos(xP(11,k));
	s           = sin(xP(11,k));
  cCarToI     = [c -s;s c];
	xP(9:10,k)	= cCarToI*xP(9:10,k);
end  
    
% Relative position
dX = xP(7:10,:) - xP(1:4,:);

%% Plotting
[t,tL] = TimeLabel(t);

% Plot just select states
k   = [1:4 7:10];
yL	= {'p_x' 'p_y' 'p_{v_x}' 'p_{v_y}'};
pS  = {[1 5] [2 6] [3 7] [4 8]};

PlotSet(t, pUKF,      'x label',  tL,'y label', yL,'figure title', 'Covariance', 'plot title', 'Covariance');
PlotSet(t, [xUKF;dX], 'x label',	tL,'y label',{'x' 'y' 'v_x' 'v_y'},...
                      'plot title','UKF State: Blue is UKF, Green is Truth','figure title','UKF State','plot set', pS );
PlotSet(t, dMHTU,     'x label',  tL,'y label','d (m)', 'plot title','MHT Distance UKF', 'figure title','MHT Distance UKF','plot type','ylog');
 