
%% UKFPWEIGHT Unscented Kalman Filter parameter estimation weights
%%  Form:
%   d = UKFPWeight( d )
%
%% Description
%   Unscented Kalman Filter parameter estimation weights.
%
%   The weight matrix is used by the matrix form of the Unscented
%   Transform. 
%
%   The constant alpha determines the spread of the sigma points around x
%   and is usually set to between 10e-4 and 1. beta incorporates prior 
%   knowledge of the distribution of x and is 2 for a Gaussian 
%   distribution. kappa is set to 0 for state estimation and 3 - number of
%   states for parameter estimation.
%
%%   Inputs
%   d	(.)	Data structure with constants
%         .kappa	(1,1)	0 for state estimation, 3-#states
%         .alpha	(1,1)	Determines spread of sigma points
%         .beta   (1,1)	Prior knowledge - 2 for Gaussian
%
%% Outputs
%   d	(.)	Data structure with constants
%         .wM     (1,2*n+1)       Weight array
%         .wC     (1,2*n+1)       Weight array
%         .lambda	(1,1)           Scaling constant
%         .wA     (p,n)           Empty matrix
%         .L      (1,1)           Number of parameters to  estimate
%         .lY     (1,1)           Number of measurements
%         .D    	(m,n)           Empty matrix
%         .n      (1,1)           Number of sigma i

function d = UKFPWeight( d )

d.L          = length(d.eta);
d.lambda     = d.alpha^2*(d.L + d.kappa) - d.L;
d.gamma      = sqrt(d.L + d.lambda);
d.wC(1)      = d.lambda/(d.L + d.lambda) + (1 - d.alpha^2 + d.beta);
d.wM(1)      = d.lambda/(d.L + d.lambda);
d.n          = 2*d.L + 1;
for k = 2:d.n
  d.wC(k) = 1/(2*(d.L + d.lambda));
  d.wM(k) = d.wC(k);
end

d.wA         = zeros(d.L,d.n);
y            = feval( d.hFun, d.x, d.hData );
d.lY         = length(y);
d.D          = zeros(d.lY,d.n);
