%% COMBINATIONS Enumerates the number of combinations
%% Form
%  c = Combinations( r, k )
% Enumerates the number of combinations of a series r taken k at a time.
% Calls itself recursively

%% Inputs
% r (1,:)   Series 1:n
% k (1,1)   Size of sets
% 
%% Outputs
% c (:,k)   Enumerations

function c = Combinations( r, k )


%% Demo
if( nargin < 1 )
  Combinations(1:4,3)
  return
end

%% Special cases
if( k == 1 )
  c = r';
  return
elseif( k == length(r) )
  c = r;
  return
end

%% Recursion
rJ	= r(2:end);
c   = [];
if( length(rJ) > 1 )
  for j = 2:length(r)-k+1
    rJ            = r(j:end);
    nC            = NumberOfCombinations(length(rJ),k-1);
    cJ            = zeros(nC,k);
    cJ(:,2:end)   = Combinations(rJ,k-1);
    cJ(:,1)       = r(j-1);
    if( ~isempty(c) )
      c = [c;cJ];
    else
      c = cJ;
    end
  end
else
  c = rJ;
end
c = [c;r(end-k+1:end)];

%% Combinations>> NumberOfCombinations
function j = NumberOfCombinations(n,k)
% Compute the number of combinations
j = factorial(n)/(factorial(n-k)*factorial(k));