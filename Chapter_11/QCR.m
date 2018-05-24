
%% QCR Creates a regulator from a state space system.
%% Form
% k = QCR( a, b, q, r )
%
%% Description
% Create a regulator of the form
% u = -kx minimizing the cost functional
% J = †{(1/2)[u'ru + x'qx].
%
% Given the constraint:
% .
% x = ax + bu
%
%
%% Inputs
%   a     (n,n) Plant matrix
%   b     (n,m) Input matrix
%   q     (n,n) State cost matrix
%   r     (m,m) Input cost matrix
%
%% Outputs
%   k     (m,n) Optimal gain
%
%% Reference
%	Franklin, G.F., J.D. Powell, M.L. Workman, Digital Control
%   of Dynamic Systems, 2nd Edition, Addison-Wesley, 1990,
%   pp. 435-438.

function k = QCR( a, b, q, r )

[sinf,rr] = Riccati( [a,-(b/r)*b';-q',-a'] );

if( rr == 1 ) 
  disp('Repeated roots. Adjust q, r or n');
end

k = r\(b'*sinf); 

function [sinf, rr] = Riccati( g )
%% Ricatti
%   Solves the matrix Riccati equation.
%
%   Solves the matrix Riccati equation in the form
%
%   g = [a   r ]
%       [q  -a']


rg = size(g);  

[w, e] = eig(g); 

es = sort(diag(e));

% Look for repeated roots
j = 1:length(es)-1;

if ( any(abs(es(j)-es(j+1))<eps*abs(es(j)+es(j+1))) ),
  rr = 1;
else
  rr = 0;
end

% Sort the columns of w
ws   = w(:,real(diag(e)) < 0);

sinf = real(ws(rg/2+1:rg,:)/ws(1:rg/2,:)); 
