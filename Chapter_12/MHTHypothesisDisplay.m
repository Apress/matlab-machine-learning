%% MHTHYPOTHESISDISPLAY Display hypothesis data in a console view.
%% Form:
%   MHTHypothesisDisplay( hyp, trk, k, t )
%
%% Description
%   Display hypothesis data in a console view.
%
%% Inputs
%   hyp         (.)     Hypothesis data structure
%   trk         (:)     Tracks array
%   k           (1,1)   Scan
%   t           (1,1)   Time
%

function MHTHypothesisDisplay( hyp, trk, k, t )

if( ~isempty(hyp) )
  str = sprintf('New hypothesis at t = %8g:\n================\n',t);
  lMax        = ceil(log10(max([trk.scanHist])));
  if( isempty(lMax ) )
      lMax = 2;
  end
  tmp         = sort(unique([trk.scanHist]));
  n           = 2*length(tmp);
  dA          = zeros(1,n);
  dA(1:2:n)	= lMax;
  dA(2:2:n)	= tmp;
  scanStr     = sprintf('S%*d ',dA);
  str = [str,sprintf('Tree ID \t %s \t Score\n',scanStr)];
  for j=1:size(hyp.tracks,1)
    tmp         = hyp.tracks(j,:);
    n           = 2*length(tmp);
    dA          = zeros(1,n);
    dA(1:2:n)   = lMax;
    dA(2:2:n)   = tmp;

    scanStr = sprintf(' %*d ', dA);
    str     = [str,sprintf('%7d \t %s \t %2.2f \n', hyp.treeID(j), scanStr, hyp.trackScores(j))];
  end
  MLog('add',str,k);    
end
