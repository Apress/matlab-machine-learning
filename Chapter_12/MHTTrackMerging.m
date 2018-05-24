%% MHTTRACKMERGING Merges tracks
%% Form
%   b = MHTTrackMerging( b, n )
%
%% Description
% Merges tracks.
%
% Rules: 1 measurement is associated with each track
% If two tracks only differ by missed measurements they are
% merged
%
%% Inputs
%   b        (m,n)  [scans, tracks]
%
%% Outputs
%   kD       (1,:)  Tracks to delete
%
%% References
% A. Amditis1, G. Thomaidis1, P. Maroudis, P. Lytrivis1 and
% G. Karaseitanidis1, "Multiple Hypothesis Tracking
% Implementation," www.intechopen.com.

function kD = MHTTrackMerging( b )

% Demo
if( nargin < 1 )
  Demo
  return;
end

[n, m] = size(b);
p      = 1;
kD     = [];

% [scan, track]
for k = 1:m
    j = find(b(:,k) ~= 0 );
    for i = k+1:m
        if( b(j,k) - b(j,i)  == 0 )
            if( length(j) == n )
                kD = [kD i];
            else
                kD = [kD k];
            end            
        end
    end
end

%% MHTTrackMerging>>Demo
function Demo
     
disp('Example 1 - each row is a scan');
    
b = [1 2 2 0 2;...
     1 2 4 1 3;...
     1 2 4 1 2;...
     2 1 1 0 1;...
     2 1 3 2 0;...
     2 1 3 2 1]';
     
disp(b)
     
k = MHTTrackMerging( b );
b(:,k) = [];
    
disp(b)
    
disp('Example 2 - each row is a scan');
    
b = [0 0 0 0 3;...
     0 0 0 0 5;...
     1 2 4 1 0;...
     1 2 4 1 3;...
     1 2 4 1 5]';
     
disp(b)
     
k = MHTTrackMerging( b );
b(:,k) = [];
    
disp(b)


