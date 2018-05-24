%% MLOG Generate a message log
%% Form
%
%   MLog('init')        % Initialize a new blank MLog window
%   MLog('init',text)   % Initialize a new blank MLog window with text
%   MLog('name',name)   % Use the supplied name in the figure heading
%   MLog('add',text)    % Append text as new element at end of the set
%   MLog('add',text,k)  % Append text to end of the kth element of the set
%   MLog('add',text,0)  % Append text to end of the last element of the set
%   MLog('show',k)      % Show the kth element of the set
%   MLog('reset')       % Delete stored text array and reset display
%   t = MLog('get',k)   % Return text of kth element
%% Description
%   Message log. Keeps an ordered, scrollable set of messages.
%
%   Type MLog('demo') for an example.
%  
%
%% Inputs
%   action    ''    Can be: {init, name, add, reset, get}
%   text      ''    Text to store in MLog window
%   index     (1,1) Optional. Index of text cell array.
%
%% Outputs
%   t         ''    Text of kth element if called as t = MLog('get',k)
%

function out = MLog( action, text, index )

persistent h d

if( nargin<1 )
  if( isempty(h) )
    Initialize;
    return
  else
    figure(h)
    return
  end
end

if( nargin<2 )
  text = '';
end

if( nargin<3 )
  index = [];
end

if( nargout )
  out = [];
end

switch lower(action)
  case 'demo'
    Demo;
    
  case {'init','initialize'}
    Initialize(text);
    
  case {'up','update','add'}
    Update(text,index);
    
  case {'clear','reset'}
    Reset;
    Update(text);
        
  case 'get'
    out = GetLog(index);
    
  case 'name'
    if( ~ischar(text) )
      warning('You must supply a string for the second input.')
      return;
    end
    if( isempty(findobj('tag','MLog')) )
      Initialize;
    end
    d = GetData;
    set(d.h,'name',sprintf('MLog - %s',text));
    
  case 'show'
    if( nargin<3 )
      index = text;
    end
    Show(index);
end


%% MLog>>Initialize
function Initialize( text )

if( nargin<1 )
  text = {};
end

d.h = [];
if (isempty(h) || ~ishandle(h))
  h = findobj('tag','MLog');
  d.h = h;
elseif (ishandle(h) && strcmp(get(h,'tag'),'MLog'))
  d.h = h;
end
if( isempty(d.h) )
  h = figure('units','pixels','position',[200 800 500 300],...
    'tag','MLog','name','MLog','numbertitle','off','color','k');
  d.h = h;
else
  Reset;
  Update(text);
  return
end

d.logs = text;
n = length(text);

if( n>0 )
  initText = text{n};
else
  initText = '';
end
d.logWin2 = uicontrol('style','edit','string',initText,'value',1,...
  'backgroundcolor','k','foregroundcolor','g','units','normalized',...
  'fontname','courier','enable','inactive','max',500,...
  'position',[.025 .05 .875 .9],'fontsize',14,'horizontalalignment','left');

d.indexSlider = SliderBar(1,max(2,n),1,@(x) SetLogIndex(x,d.h),'',[.85 .1 .12 .75],d.h);
d.indexDisplay = uicontrol('style','text','string',int2str(n),...
  'backgroundcolor','k','foregroundcolor','w',...
  'fontname','courier','horizontalalignment','right',...
  'fontsize',12,'units','normalized','position',[.91 .88 .09 .12]);

set(d.h,'userdata',d)

end

%% MLog>>SetLogIndex
function SetLogIndex(x,~)
%u = get(h,'userdata');
val = get(d.indexSlider,'max')-round(x)+1;
%set(u.logWin,'value',val)
if( ~isempty(d.logs) )
  set(d.logWin2,'string',d.logs{val})
else
  set(d.logWin2,'string','')
end
set(d.indexDisplay,'string',sprintf('%d / %d ',val,length(d.logs)));

end

%% MLog>>GetLog
function g = GetLog(k)
d = GetData;
if( k>=1 && k<=length(d.logs) && rem(k,1)<eps )
  g = d.logs{k};
else
  g = '';
end

end

%% MLog>>Update
function Update(text,index)

if( isempty(text) )
  return
end

if( ~iscell(text) && ischar(text) )
  text = {text};
end

d = GetData;
if( isempty(d) )
  Initialize(text)
  d = GetData;
end

% put the supplied text into the logs list in the correct place
if( nargin>1 && ~isempty(index) )
  if( index==0 )
    % append text to last entry of logs
    if( isempty(d.logs) )
      d.logs{1} = text; % first entry
    else
      d.logs{end} = [d.logs{end},text];
    end
  else
    % append text to specified log index
    if( index>length(d.logs) )
      d.logs{index} = {};
    end
    d.logs{index} = [d.logs{index},text];
  end
else
  % append new text to list of logs
  d.logs = [d.logs,text];
end
PutData( d );

% update the max value of the slider
if( length(d.logs)==1 )
  set(d.indexSlider,'min',0,'max',max(length(d.logs)));
else
  set(d.indexSlider,'min',1,'max',max(length(d.logs)));
end

% update the string contents of d.logWin
%set(d.logWin,'string',d.logs)

% set to the last index
SetLogIndex(1,d.h);

end

%% MLog>>Show
function Show(index)

if( index<1 || rem(index,1)>eps )
  return;
end

d = GetData;
if( isempty(d) )
  return
end

SetLogIndex(length(d.logs)-index+1,d.h)
set(d.indexSlider,'value',length(d.logs)-index+1)

end

%% MLog>>Reset
function Reset

%d = GetData;
ok = CheckData;
if (ok)
  d.logs = {};
  %PutData(d);

  %set(d.logWin,'value',2,'string',{'',''});
  set(d.logWin2,'string','');
  set(d.indexSlider,'value',1,'max',2);
  set(d.indexDisplay,'string','N/A ');
end

end


%% MLog>>GetData
function data = GetData

if (isempty(h) || ~ishandle(h))
  h = findobj('tag','MLog');
end
if( isempty(h) )
  warning('Could not find figure with tag "MLog".');
  data = [];
  return
end
%d = get(h,'userdata');
data = d;

end

%% MLog>>CheckData
% Check that the figure still exists, otherwise clear persistent data
function ok = CheckData
  
ok = 1;
if (isempty(h) || ~ishandle(h))
  h = findobj('tag','MLog');
end
if( isempty(h) )
  d = [];
  ok = 0;
end

end

%% MLog>>PutData
function PutData( ~ )

end


%% MLog>>Demo
function Demo
% Shows some examples of using MLog

txt = {'This','is an example','of what you can do','with MLog.',help('MLog')};
MLog('name','DEMO')
MLog('init',txt)
MLog('show',1)


end

end