%% SLIDERBAR Create a slider
%% Form
%   SliderBar( valMin, valMax, val0, callback, name, position )
%
%% Description
%   Create a slider in a new figure with continuous calls to callback.
%   Can optionally put the slider into an existing figure.
%
%   Type SliderBar for a demo.
%
%% Inputs
%   valMin      (1,1)   Minimum value for slider bar
%   valMax      (1,1)   Maximum value for slider bar
%   val0        (1,1)   Initial value of slider
%   callback            Callback function, 1 var. Example: @(x) disp(sin(x))
%   name        (1,:)   String name for figure (optional)
%   position    (1,4)   Position information. 
%                         * If a new figure is created, this input defines 
%                         the position of the new figure in pixels on the
%                         screen. OR...
%                       	* If an existing figure is specified, this input
%                       	defines the position of the slider within the
%                       	given figure window. 
%   fig         (1,1)   Figure handle. Optional. Supply this input to put
%                       the slider inside this figure, rather than creating
%                       a new figure.
%
%% Outputs
%   u           (1,1)   Handle to the slider object.
%

function u = SliderBar( valMin, valMax, val0, callback, name, position, fig )

% Demo
if( nargin < 1 )
  Demo
  return;
end

if( nargin < 6 )
  position = [300 500 350 50];
end
if( nargin < 5 )
  name = 'Slider';
end
if( nargin < 7 )
  fig = figure('color',[0 0 0],'position',position,...
    'numbertitle','off','menubar','none','name',name);
  pos = [.1 .1 .8 .8];
else
  pos = position;
end
u=uicontrol('parent',fig,'style','slider','units','normalized',...
  'position',pos,'min',valMin,'max',valMax,'value',val0);

if( verLessThan('matlab','7.0') )
  actionName = 'ActionEvent';
else
  actionName = 'ContinuousValueChange';
end

if( ~iscell(callback) )
  fh = @(xx,yy) callback( get(u,'value') );
  lh = addlistener( u, actionName, fh );
else
  for i=1:length(callback)
    fh{i} = @(xx,yy) callback{i}( get(u,'value') );
    lh{i} = addlistener( u, actionName, fh{i} );
  end
end

%% SliderBar>>Demo
function Demo
% Generate a 2D graphic and add a slider bar to control the magnitude
% of the peaks.

[x,y,z]=peaks(40); 
figure('position',[124   386   560   420])
s=surf(x,y,z,'edgecolor','none'); axis([-5 5 -5 5 -10 10])
tau = linspace(0,2*pi);
set(gcf,'position',[684   386   560   420]), hold on
a=8000;
plot(a*cos(tau),a*sin(tau),'r'); m=line('xdata',a,'ydata',0,'marker','s');
valMin=0; valMax=2;
val0=1;
callback={...
    @(x) set(s,'zdata',x*z), ...
    @(x) set(m,'xdata',a*cos(x*pi),'ydata',a*sin(x*pi))};
name = 'Slider Demo';
position = [334   334   600    30];
SliderBar( valMin, valMax, val0, callback, name, position );


