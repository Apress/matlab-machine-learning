%% MHT automobile demo.
%
% This models several cars driving near a car with radar. The cars
% are at different speeds and may perform passing maneuvers. The radar
% detects other cars when they pass into its field of view
% The demo uses the Unscented Kalman Filter (UKF). 
%
% The simulation is run first and then the MHT code assigns measurements
% to the tracks. The simuation starts with no tracks and no
% valid measurements are seen for a while. Eventually the demo tracks
% three cars. 
%
% The car maneuvers and initial states can be modified. Auto 1 carries the
% radar. Auto 4 performs a passing maneuver around Auto 1.
%
% To run this software you will need GLPK.
% You will need glpk.m and its associated mex file for your machine. For
% example, for a Mac you need the mex file glpkcc.mexmaci64. For more
% information https://www.gnu.org/software/glpk/
%

%% See also
% AutoRadar, AutomobilePassing, RHSAutomobile, RHSAutomobileXY,
% AutoRadarUKF

%% Initialize

% Set the seed for the random number generators. 
% If the seed is not set each run will be different.
seed = 45198;
rng(seed);

% Control screen output
% This demo takes about 4 minutes with the graphics OFF.
% It takes about 10 minutes with the graphics on.
printTrackUpdates   = 0; % includes a pause at every MHT step
graphicsOn          = 0;
treeAnimationOn     = 0;

% Car 1 has the radar

% 'mass' (1,1)
% 'steering angle'  (1,1) (rad)
% 'position tires' (2,4)


d.car(1) = AutomobileInitialize(	'mass', 1513,...
                                  'position tires', [  1.17 1.17 -1.68 -1.68; -0.77 0.77 -0.77 0.77], ...
                                  'frontal drag coefficient', 0.25, ...
                                  'side drag coefficient', 0.5, ...
                                  'tire friction coefficient', 0.01, ...
                                  'tire radius', 0.4572, ...
                                  'engine torque', 0.4572*200, ...
                                  'rotational inertia', 2443.26, ...
                                  'rolling resistance coefficients', [0.013 6.5e-6], ...
                                  'height automobile', 2/0.77, ...
                                  'side and frontal automobile dimensions', [1.17+1.68 2*0.77]);

% Make the other cars identical
d.car(2) = d.car(1);
d.car(3) = d.car(1);
d.car(4) = d.car(1);
nAuto    = length(d.car);

% Velocity set points for cars 1-3. Car 4 will be passing
vSet                = [12 13 14];

% Time step setup
dT    = 0.1;
tEnd  = 300;
n     = ceil(tEnd/dT);

% Car initial state
x  = [140; 0;12;0;0;0;...
      30; 3;14;0;0;0;...
      0;-3;15;0;0;0;...
      0; 0;11;0;0;0];

% Radar
m                   = length(x)-1;
dRadar.kR           = [7:6:m;8:6:m];
dRadar.kV           = [9:6:m;10:6:m];
dRadar.kT           = 11:6:m;
dRadar.noise        = [0.1;0.01;0.01]; % [range; range rate; azimuth]
dRadar.fOV          = pi/4;
dRadar.maxRange     = 800;
dRadar.noLimits     = 0;

figure('name','Radar FOV')
range = tan(dRadar.fOV)*5;
fill([x(1) x(1)+range*[1 1]],[x(2) x(2)+5*[1 -1]],'y')
iX = [1 7 13 19];
l = plot([[0;0;0;0] x(iX)]',(x(iX+1)*[1 1])','-');
hold on
for k = 1:length(l)
  plot(x(iX(k)),x(iX(k)+1)','*','color',get(l(k),'color'));
end
set(gca,'ylim',[-5 5]);
grid
range = tan(dRadar.fOV)*5;
fill([x(1) x(1)+range*[1 1]],[x(2) x(2)+5*[1 -1]],'y')
legend(l,'Auto 1','Auto 2', 'Auto 3', 'Auto 4');
title('Initial Conditions and Radar FOV')


% Plotting
yP = zeros(3*(nAuto-1),n);
vP = zeros(nAuto-1,n);
xP = zeros(length(x)+2*nAuto,n);
s  = 1:6*nAuto;

%% Simulate
t                   = (0:(n-1))*dT;

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
  for j = 1:3
      d.car(j).torque = -10*(d.car(j).x(3) - vSet(j));
  end

  % The passing car
  d.car(4)	= AutomobilePassing( d.car(4), d.car(1), 3, 1.3, 10 );

  % Integrate
  x           = RungeKutta(@RHSAutomobile, 0, x, dT, d );
    
end
fprintf(1,'Simulation done.\n');

% The state of the radar host car
xRadar = xP(1:6,:);

% Plot the simulation results
figure('name','Auto')
kX = 1:6:length(x);
kY = 2:6:length(x);
c  = 'bgrcmyk';
j  = floor(linspace(1,n,20));
[t, tL] = TimeLabel( t );
for k = 1:nAuto
    plot(xP(kX(k),j),xP(kY(k),j),[c(k) '.']);
    hold on
end
legend('Auto 1','Auto 2', 'Auto 3', 'Auto 4');

for k = 1:nAuto
    plot(xP(kX(k),:),xP(kY(k),:),c(k));
end
xlabel('x (m)');
ylabel('y (m)');
set(gca,'ylim',[-5 5]);
grid

kV = [19:24 31 32];
yL = {'x (m)' 'y (m)' 'v_x (m/s)' 'v_y (m/s)' '\theta (rad)' '\omega (rad/s)' '\delta (rad)' 'T (Nm)'};
PlotSet( t,xP(kV,:), 'x label',tL, 'y label', yL,'figure title','Passing car');

% Plot the radar results but ignore cars that are not observed
for k = 1:nAuto-1
	j   = 3*k-2:3*k;
	sL  = sprintf('Radar: Observed Auto %d',k);
	b   = mean(yP(j(1),:));
	if( b ~= 0 )
    PlotSet(t,[yP(j,:);vP(k,:)],'x label',tL,'y label', {'Range (m)' 'Range Rate (m/s)' 'Azimuth (rad)' 'Valid'},'figure title',sL);
	end
end

%% Implement MHT


% Adjust the radar data structure for the new state
dRadar.kR       = [1;2];
dRadar.kV       = [3;4];
dRadar.noLimits	= 1;


% Covariances
r0      = diag(dRadar.noise.^2);	  % Measurement 1-sigma
q0      = [1e-7;1e-7;.1;.1]; 	% The baseline plant covariance diagonal
p0      = [5;0.4;1;0.01].^2;	% Initial state covariance matrix diagonal

ukf = KFInitialize( 'ukf','f',@RHSAutomobileXY,'alpha',1,...
                    'kappa',0,'beta',2,'dT',dT,'fData',struct('f',0),...
                    'p',diag(p0),'q',diag(q0),'x',[0;0;0;0],'hData',struct('theta',0),...
                  	'hfun',@AutoRadarUKF,'m',[0;0;0;0],'r',r0);
ukf	= UKFWeight( ukf );

[mhtData, trk] = MHTInitialize(	'probability false alarm', 0.01,...
                                'probability of signal if target present', 1,...
                                'probability of signal if target absent', 0.01,...
                                'probability of detection', 1, ...
                                'measurement volume', 1.0, ...
                                'number of scans', 5, ...
                                'gate', 20,...
                                'm best', 2,...
                                'number of tracks', 1,...
                                'scan to track function',@ScanToTrackAuto,...
                                'scan to track data',dRadar,...
                                'distance function',@MHTDistanceUKF,...
                                'hypothesis scan last', 0,...
                                'remove duplicate tracks across all trees',1,...
                                'average score history weight',0.01,...
                                'prune tracks', 1,...
                                'create track', 1,...
                                'filter type','ukf',...
                                'filter data', ukf);

% Size arrays
%------------
m       = zeros(5,n);
p       = zeros(5,n);
scan    = cell(1,n);
b       = MHTTrkToB( trk );

t       = 0;

% Parameter data structure for the measurements
sensorParam  = struct( 'hFun', @AutoRadarUKF, 'hData', dRadar, 'r', r0 );

TOMHTTreeAnimation( 'initialize', trk );
MHTGUI;
MLog('init')
MLog('name','MHT Automobile Tracking Demo')

fprintf(1,'Running the MHT...\n');
for k = 1:n
       
  % Assemble the measurements
	zScan = [];
  for j = 1:size(vP,1)
    if( vP(j,k) == 1 )
      tJ    = 3*j;
      zScan	= AddScan( yP(tJ-2:tJ,k), sensorParam, zScan );
    end
  end

  % Add state data for the radar car
  mhtData.fScanToTrackData.xR     = xRadar(1:2,k);
  mhtData.fScanToTrackData.vR     = xRadar(3:4,k);
  mhtData.fScanToTrackData.theta	= xRadar(5,k);

  % Manage the tracks
  [b, trk, sol, hyp] = MHTTrackMgmt( b, trk, zScan, mhtData, k, t );

  % A guess for the initial velocity of any new track
  for j = 1:length(trk)
    mhtData.fScanToTrackData.x = xRadar(:,k);
  end
    
  % Update MHTGUI display
  if( ~isempty(zScan) && graphicsOn )
    if (treeAnimationOn)
      TOMHTTreeAnimation( 'update', trk );  
    end
    if( ~isempty(trk) )
      MHTGUI(trk,sol,'hide');
    end
    drawnow
  end
    
  % Update time
  t = t + dT;
end
fprintf(1,'MHT done.\n');

% Show the final GUI
if (~treeAnimationOn)
  TOMHTTreeAnimation( 'update', trk );
end
if (~graphicsOn)
  MHTGUI(trk,sol,'hide');
end
MHTGUI;
