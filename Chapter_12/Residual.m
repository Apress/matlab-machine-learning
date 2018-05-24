%% RESIDUAL Generates residuals
%% Form
%   [z, h, r] = Residual( y, f )
%
%% Description
%   Generates residual, measurement matrix and measurement noise matrix.
%
%   Handles linear and nonlinear systems. The latter use the Jacobian
%   of the measurement function. The former uses the h matrix. For
%   nonlinear systems .h is the pointer to the measurement function.
%
%   This handles empty y matrices.
%
%% Inputs
%   y	(m) Measurement data structure
%           .data  (:,1) Measurements
%           .param (1,1) Parameter data structure
%                       .hFun   (1,:) Pointer to measurement function
%                       .hData  (1,1) Data structure for measurement function data
%                       .r      (:,:) Measurement covariance matrix
%   f   (1,1) Filter data structure
%             .m     (n,1) State vector
%
%% Outputs
%   z	(m,1) Residual
%   h	(m,n) Linearized measurement matrix y = h*x or
%   r	(m,m) Noise covariance matrix
%

function [z, h, r] = Residual( y, f )

% First path is for a nonlinear filter
if( ~isempty(y) )
  if(	isstruct(y) && isfield(y(1).param,'hData') ) 
    p = length(y);

    if( p > 0 )

      hK = cell(p);
      n = zeros(1,p);
      for k = 1:p
          hK{k}  = Jacobian( y(k).param.hFun, f.m, [], y(k).param.hData );
          n(k)   = size(hK{k},1);
      end

      % Preallocate memory for h
      nS  = sum(n);
      h   = zeros(nS,length(f.m));
      r   = zeros(nS,nS);
      z   = zeros(nS,1);

      i   = 1;
      for k = 1:p
          iN          = i + n(k);
          iK          = i:iN-1;
          h(iK,:)     = hK{k};
          r(iK,iK)    = y(k).param.r;
          z(i:iN-1,1)	= y(k).data - feval(y(k).param.hFun,f.m,y(k).param.hData );
          i           = iN;
      end
    else
      z   = [];
      h   = [];
      r   = [];
    end
  else
    r = f.r;
    if( isstruct(y) )
      nM = length(y);
      yd = [];
      for i=1:nM
        yd = [yd; y(i).data];
      end
      h = repmat(f.h,nM,1);
      z = yd - h*f.m;
    else
      z   = y - f.h*f.m;
    end
    h   = f.h;
  end
else
	z   = [];
	h   = [];
	r   = [];
end

