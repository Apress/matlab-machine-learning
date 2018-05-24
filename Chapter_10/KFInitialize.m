%% KFINITIALIZE Kalman Filter initialization
%% Form
%   d = KFInitialize( type, varargin )
%
%% Description
%   Initializes Kalman Filter data structures for the KF, UKF,  EKF and
%   UKFP, parameter update..
%
%   Enter parameter pairs after the type.
%
%   If you return with only one input it will return the default data
%   structure for the filter specified by type. Defaults are returned
%   for any parameter you do not enter.
%
%
%%  Inputs
%   type           (1,1) Type of filter 'ukf', 'kf', 'ekf'
%   varargin       {:}   Parameter pairs
%
%% Outputs
%   d              (1,1) Data structure
%
%% References
% None.

function d = KFInitialize( type, varargin )

% Default data structures
switch lower(type)
	case 'ukf'
    d = struct( 'm',[],'alpha',1, 'kappa',0,'beta',2, 'dT',0,...
                'p',[],'q',[],'f','','fData',[], 'hData',[],'hFun','','t',0);  

	case 'kf'
    d = struct( 'm',[],'a',[],'b',[],'u',[],'h',[],'p',[],...
                'q',[],'r',[], 'y',[]); 
               
	case 'ekf'
    d = struct( 'm',[],'x',[],'a',[],'b',[],'u',[],'h',[],'hX',[],'hData',[],'fX',[],'p',[],...
                'q',[],'r',[],'t',0, 'y',[],'v',[],'s',[],'k',[]);  
              
	case 'ukfp'
    d = struct( 'm',[],'alpha',1, 'kappa',0,'beta',2, 'dT',0,...
                'p',[],'q',[],'f','','fData',[], 'hData',[],'hFun','','t',0,'eta',[]);  
              
  otherwise
    error([type ' is not available']);
end
  
% Return the defaults
if( nargin == 1 )
    return
end


% Cycle through all the parameter pairs
for k = 1:2:length(varargin)
    switch lower(varargin{k})
        case 'a'
            d.a     = varargin{k+1};
            
        case {'m' 'x'}
            d.m     = varargin{k+1};
            d.x     = varargin{k+1};
            
        case 'b'
            d.b     = varargin{k+1};
            
        case 'u'
            d.u     = varargin{k+1};
            
        case 'hx'
            d.hX    = varargin{k+1};
            
        case 'fx'
            d.fX    = varargin{k+1};
            
        case 'h'
            d.h     = varargin{k+1};
            
        case 'hdata'
            d.hData	= varargin{k+1};
            
        case 'hfun'
            d.hFun	= varargin{k+1};

        case 'p'
            d.p     = varargin{k+1};
            
        case 'q'
            d.q     = varargin{k+1};
            
        case 'r'
            d.r     = varargin{k+1};
            
        case 'f'
            d.f     = varargin{k+1};
            
        case 'eta'
            d.eta   = varargin{k+1};

        case 'alpha'
            d.alpha = varargin{k+1};
           
        case 'kappa'
            d.kappa = varargin{k+1};
            
        case 'beta'
            d.beta	= varargin{k+1};
            
        case 'dt'
            d.dT	= varargin{k+1};
            
        case 't'
            d.t   = varargin{k+1};
           
        case 'fdata'
            d.fData = varargin{k+1};
            
        case 'nits'
            d.nIts  = varargin{k+1};
            
        case 'kmeas'
            d.kMeas = varargin{k+1};

    end
end


 
