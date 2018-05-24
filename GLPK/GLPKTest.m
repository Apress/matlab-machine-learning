%%   Test GLPK
%
%       Compare glpk.m results with the references.
%
%       Test 1 is from the header. No results are given. Test 2 is a
%       linear programming test with minimum and maximum constraints
%       on the states.

%       Test 1: From the header of glpk.m
%       Test 2: Listing 4.15 op. 54-55 from the reference
%       
%--------------------------------------------------------------------------
%   Reference: Oki, E., "Linear programming and Algorithms for
%              Communications Networks," CRC Press, 2013.
%--------------------------------------------------------------------------
%%
%--------------------------------------------------------------------------
%   Copyright (c) 2014 Princeton Satellite Systems, Inc.
%   All Rights Reserved
%--------------------------------------------------------------------------

%% Example 1 from the header for glpk
%------------------------------------
disp('Example 1 from the header for glpk.m');
c       = [10, 6, 4]'; % Cost
a       = [ 1, 1, 1; 10, 4, 5; 2, 2, 6]; % Constraints
b       = [100, 600, 300]'; % Values
lb      = [0, 0, 0]'; % Lower bounds
ub      = []; % Upper bounds

% ctype = An array of characters containing the sense of each constraint in the
%         constraint matrix. 
%           'U' Variable with upper bound ( A(i,:)*x <= b(i)).
%------------------------------------------------------------------------------
ctype   = 'UUU';

% vartype = A column array containing the types of the variables
%               'C' Continuous variable.
%---------------------------------------------------------------
vartype	= 'CCC';

% sense = If sense is  1 the problem is minimization
%---------------------------------------------------
s       = -1;

% Only error messages and 100 iteration limit
%--------------------------------------------
param   = struct('msglev',1,'itlim',100);

[xMin, cost] = glpk (c, a, b, lb, ub, ctype, vartype, s, param);

DispWithTitle( xMin, 'Minimum states' )
DispWithTitle( cost, 'Solution Cost' )

%%  Listing 3.2
%---------------
c       = [1 1]'; % Cost

% States [x y]
% The constraint equations
%
% x >= 0
% y >= 0
%
% 5x + 3y <= 15
% x - y <= 2
% y <= 3
%---------------------------------
a       = [ 5 3;...
           1   -1;...
           0   1]; % Constraints
b       = [15 2 3]'; % Values
       
lb      = [0   0 ]'; % Lower bounds
ub      = []'; % Upper bounds

ctype   = 'UUU'; % All equality constraints
vartype	= 'CC'; % Continous variables
s       =  -1; % 1 means minimize, -1 means maximize

% Only error messages and 200 iteration limit
%--------------------------------------------
param   = struct('msglev',1,'itlim',100);

[xMin,  cost, status, extra] = glpk (c, a, b, lb, ub, ctype, vartype, s, param);

disp('Listing 3.2 from the reference');

DispWithTitle( cost, 'Solution Cost' )
DispWithTitle( xMin, 'Solution ' )



%%  Listing 4.15
%---------------
c       = [3 8 2 12 6]'; % Cost

% States [x12 x13 x23 x24 x34]
% The constraint equations
%
% x12 + x13                   = 12
% x12       - x23 - x24       = 0
%       x13 + x23       - x34 = 0
%---------------------------------
a       = [1   1   0   0   0;...
           1   0  -1  -1   0;...
           0   1   1   0  -1]; % Constraints
b       = [12 0 0]'; % Values
       
lb      = [0   0   0   0   0]'; % Lower bounds
ub      = [5  13   4   9  10]'; % Upper bounds

ctype   = 'SSS'; % All equality constraints
vartype	= 'CCCCC'; % Continous variables
s       =  1; % 1 means minimize, -1 means maximize

% Only error messages and 200 iteration limit
%--------------------------------------------
param   = struct('msglev',1,'itlim',100);

[xMin,  cost, status, extra] = glpk (c, a, b, lb, ub, ctype, vartype, s, param);

err     = b - a*xMin;

disp('Listing 4.15 from the reference');

DispWithTitle(  err, 'Solution Error' )
DispWithTitle( cost, 'Solution Cost' )


%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2017-01-11 22:38:52 -0500 (Wed, 11 Jan 2017) $
% $Revision: 43803 $