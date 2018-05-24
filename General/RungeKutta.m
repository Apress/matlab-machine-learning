%% RUNGEKUTTA Fourth order Runge-Kutta numerical integrator.
%% Form
%  x = RungeKutta( Fun, t, x, h, varargin )
%
%% Description
% Integrate the right-hand side function one fixed timestep h. Called
% function is of the form
%
%  Fun(t,x,varargin)
%
% Accepts optional arguments that are passed through to Fun.
%
%% Inputs
%  Fun       (1,1)  Function handle    Fun(x,{t,...})
%  t         (1,1)  Current independent variable
%  x         (:,1)  State (column vector)
%  h         (1,1)  Independent variable step
%  varargin   {}    Optional arguments
%
%% Outputs
%  x         (:,1)	Updated state

function x = RungeKutta( Fun, t, x, h, varargin )

hO2   = 0.5*h;
tPHO2 = t + hO2;


k1    = feval( Fun,	t,      x,          varargin{:} );
k2    = feval( Fun,	tPHO2,  x + hO2*k1, varargin{:} );
k3    = feval( Fun,	tPHO2,  x + hO2*k2, varargin{:} );
k4    = feval( Fun,	t+h,    x + h*k3,   varargin{:} );

x     = x + h*(k1 + 2*(k2+k3) + k4)/6;


