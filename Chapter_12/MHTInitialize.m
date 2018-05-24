
%% MHTINITIALIZE Initializes the MHT data structure.
%% Form
%  [trkData, trk] = MHTInitialize( varargin )
%
%% Description
% Enter parameter pairs.
%% Inputs
%  varargin       {:}  Parameter pairs
%
%% Outputs
%  trkData        (.)   MHT track data structure
%  trk            (1,1) First track data structure
%

function [trkData, trk] = MHTInitialize( varargin )

createTrack = 0;

% Cycle through all the parameter pairs
for k = 1:2:length(varargin)
    switch lower(varargin{k})
        case 'probability false alarm'
            trkData.pFA = varargin{k+1};
            
        case 'probability of signal if target present'
            trkData.pH1 = varargin{k+1};
            
        case 'probability of signal if target absent'
            trkData.pH0 = varargin{k+1};
            
        case 'probability of signal if target present function'
            trkData.fPH1 = varargin{k+1};
            
        case 'probability of signal if target absent function'
            trkData.fPH0 = varargin{k+1};

        case 'probability of detection'
            trkData.pD = varargin{k+1};
            
        case 'measurement volume'
            trkData.vC = varargin{k+1};
            
        case 'number of scans'
            trkData.nScan = varargin{k+1};
            
        case 'gate'
            trkData.gate = varargin{k+1};
            
        case 'm best'
            trkData.mBest = varargin{k+1};
            
        case 'number of tracks'
            trkData.nTrk = varargin{k+1};
            
        case 'scan to track function'
            trkData.fScanToTrack = varargin{k+1};
            
        case 'scan to track data'
            fScanToTrackData = varargin{k+1};
                
        case 'hypothesis scan last'
            trkData.hypScanLast = varargin{k+1};
                 
        case 'distance function'
            trkData.fDistance = varargin{k+1};         
           
        case 'hypothesis scan window',...
            trkData.hypScanWindow = varargin{k+1};
         
        case 'prune tracks'
           trkData.pruneTracks  = varargin{k+1};
           
        case 'remove duplicate tracks across all trees'
          trkData.removeDuplicateTracksAcrossAllTrees = varargin{k+1};
          
        case 'average score history weight'
          trkData.avgScoreHistoryWeight = varargin{k+1};
           
        case 'filter type'
            switch varargin{k+1}
                case 'ukf'
                    trkData.predict     = @UKFPredict;                 
                    trkData.update      = @UKFUpdate;
                    
                case 'ekf'
                    trkData.predict     = @EKFPredict;
                    trkData.update      = @EKFUpdate;
                     
                case 'kf'
                    trkData.predict     = @KFPredict;
                    trkData.update      = @KFUpdate;
            end
           
        case 'filter data'
            filter = varargin{k+1};
            
        case 'create track'
            createTrack = 1;

    end
end

% Create the first track
%-----------------------
if( createTrack == 1 )
    trk(1)                          = MHTInitializeTrk( filter );
	trkData.nTrk                    = 1;
    trkData.fScanToTrackData        = trk(1);
else
	trkData.nTrk                    = 0;
    trk                             = [];
    trkData.fScanToTrackData.filter	= filter;
    trkData.fScanToTrackData.p      = filter.p;
    trkData.fScanToTrackData.r      = filter.r;
end

% Create the ScanToTrackData field
%---------------------------------
if( ~isempty(fScanToTrackData) )
    f = fieldnames(fScanToTrackData);
    for k = 1:length(f)
        trkData.fScanToTrackData.(f{k}) = fScanToTrackData.(f{k});
    end
end
            