%% CHECKFORDUPLICATETRACKS Check trk data structure for duplicate tracks.
%% Form
%   dup = CheckForDuplicateTracks( trk, allTrees )
%
%% Description
% Check for duplicate tracks. Compares treeID, measHist, scanHist.
%
% Cycles through all tracks. Compares j'th track with k'th track (k>j).
% If the two tracks have identical (treeID, measHist, scanHist), they are
% marked as a duplicate pair.
%
% If the two tracks have identical (measHist, scanHist) and input
% "allTrees" is true, they are marked as a duplicate pair.
%
%% Inputs
%   trk       (.)     Track data structure array. Must include fields:
%                       .treeID     Integer track-tree ID
%                       .measHist   Integer array of measurement numbers.
%                       .scanHist   Integer array of scan numbers
%   allTrees  (1,1)   If 1, then look for duplicates across all trees. 
%                     If 0, then look for duplicates within each tree.
%                     Default is 0.
%
%% Outputs
%   dup       (N,2)   Matrix of duplicate tracks. N rows of index pairs. 
%                     For example, dup = [3 5;4 7] means that trk(3) and 
%                     trk(5) are duplicates, and that trk(4) and trk(7) are
%                     duplicates.

function dup = CheckForDuplicateTracks( trk, allTrees )

if( nargin<2 )
  allTrees = 0;
end

dup = zeros(0,2);

if( isempty(trk) )
  return
end

ids = [trk.treeID];
n = 0;

for j=1:length(trk) 
  
  for k=j+1:length(trk) 
    
    if( allTrees || ids(j) == ids(k) )
      if( length(trk(j).scanHist) == length(trk(k).scanHist) )
        if( trk(j).scanHist == trk(k).scanHist )
          if( length(trk(j).measHist) == length(trk(k).measHist) )
            if( trk(j).measHist == trk(k).measHist )
              n = n+1;
              dup(n,:) = [j k];
            end
          end
        end
      end
    end 
    
  end
end
