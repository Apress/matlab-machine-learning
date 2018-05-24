
%% RHSAUTOMOBILE Right hand side for a 2D automobile.
%% Form
%   xDot = RHSAutomobile( t, x, d )
%
%% Inputs
%   t         Time, unused
%   x	(6*n,1) State, [x;y;vX;vY;theta;omega]
%   d	(1,1)   Data structure
%               .car	(n,1)  Car data structure
%                              .mass  (1,1) Mass (kg)
%                              .delta (1,1) Steering angle (rad)
%                              .r     (2,4) Position of wheels (m)
%                              .cDF   (1,1) Frontal drag coefficient
%                              .cDS   (1,1) Side drag coefficient
%                              .cF    (1,1) Friction coefficient
%                              .fT    (1,1) Traction force (N)
%                              .areaF (1,1) Frontal area for drag (m^2)
%                              .areaS (1,1) Side area for drag (m^2)
%                              .fRR   (1,2) [f0 K]
%
%% Outputs
%   x	(6*n,1)  d[x;y;vX;vY;theta;omega]/dt
%

function xDot = RHSAutomobile( ~, x, d )


% Constants
g       = 9.806; % Acceleration of gravity (m/s^2)
n       = length(x);
nS      = 6; % Number of states   
xDot    = zeros(n,1);   
nAuto	= n/nS;
    
j = 1;
% State [j j+1 j+2 j+3  j+4   j+5]
%        x  y  vX  vY  theta omega
for k = 1:nAuto
    vX          = x(j+2,1);
    vY          = x(j+3,1);
    theta       = x(j+4,1);
    omega       = x(j+5,1);
    
    % Car angle
    c           = cos(theta);
    s           = sin(theta);
    
    % Inertial frame
    v           = [c -s;s c]*[vX;vY];
    
    delta       = d.car(k).delta;
    c           = cos(delta);
    s           = sin(delta);
    mCToT       = [c s;-s c];
    
    % Find the rolling resistance of the tires
    vTire       = mCToT*[vX;vY];
    f0          = d.car(k).fRR(1);
    K1          = d.car(k).fRR(2);
    
    fRollingF   = f0 + K1*vTire(1)^2;
 	  fRollingR   = f0 + K1*vX^2;
       
    % This is the side force friction
    fFriction   = d.car(k).cF*d.car(k).mass*g;
    fT          = d.car(k).radiusTire*d.car(k).torque;
        
    fF          = [fT - fRollingF;-vTire(2)*fFriction];
    fR          = [   - fRollingR;-vY      *fFriction];
    
    % Tire forces
    f1          = mCToT'*fF;
    f2          = f1;
    f3          = fR;
    f4          = f3;
    
    % Aerodynamic drag
    vSq         = vX^2 + vY^2;
    vMag        = sqrt(vSq);
    q           = 0.5*1.225*vSq;
    fDrag       = q*[d.car(k).cDF*d.car(k).areaF*vX;...
                     d.car(k).cDS*d.car(k).areaS*vY]/vMag;
    
    % Force summations
    f           = f1 + f2 + f3 + f4 - fDrag;   
            
    % Torque
    T           = Cross2D( d.car(k).r(:,1), f1 ) + Cross2D( d.car(k).r(:,2), f2 ) + ...
                  Cross2D( d.car(k).r(:,3), f3 ) + Cross2D( d.car(k).r(:,4), f4 );
     
    % Right hand side
    xDot(j,  1)	= v(1);
    xDot(j+1,1)	= v(2);
    xDot(j+2,1)	= f(1)/d.car(k).mass + omega*vY;
    xDot(j+3,1)	= f(2)/d.car(k).mass - omega*vX;
    xDot(j+4,1) = omega;
    xDot(j+5,1)	= T/d.car(k).inr;
    
    j           = j + nS;
end

function c = Cross2D( a, b )
%% Cross2D
c = a(1)*b(2) - a(2)*b(1);


