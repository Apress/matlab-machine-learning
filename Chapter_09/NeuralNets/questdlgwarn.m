function ButtonName=questdlg(Question,Title,Btn1,Btn2,Btn3,Default)
%QUESTDLG Question dialog box.
%  ButtonName=QUESTDLG(Question) creates a modal dialog box that 
%  automatically wraps the cell array or string (vector or matrix) 
%  Question to fit an appropriately sized window.  The name of the 
%  button that is pressed is returned in ButtonName.  The Title of 
%  the figure may be specified by adding a second string argument.  
%
%  The default set of buttons names for QUESTDLG are 'Yes','No' and 
%  'Cancel'.  The default answer for the above calling syntax is 'Yes'.  
%  This can be changed by adding a third arugment which specifies the 
%  default Button.  i.e. ButtonName=questdlg(Question,Title,'No').
%
%  Up to 3 custom button names may be specified by entering
%  the button string name(s) as additional argumenets to the function 
%  call.  If custom ButtonName's are entered, the default ButtonName
%  must be specified by adding an extra argument. i.e.
%    ButtonName=questdlg(Question,Title,Btn1,Btn2,Btn1);
%  makes Btn1, the default answer.
%
%  A sample application of this function is:
%    ButtonName=questdlg('What is your wish?', ...
%                        'Genie Question', ...
%                        'Food','Clothing','Money','Money');
%  
%    switch ButtonName,
%       case 'Food', 
%        disp('Food is delivered');
%      case 'Clothing',
%        disp('The Emperor''s  new clothes have arrived.')
%      case 'Money',
%        disp('A ton of money falls out the sky.');
%    end % switch
%
%  See also TEXTWRAP.

%  Author: L. Dean
%  Copyright (c) 1984-97 by The MathWorks, Inc.
%  $Revision: 1.1 $

if nargin<1,error('Too Few arguments for QUESTDLG');end

if ~iscell(Question),Question=cellstr(Question);end

if strcmp(Question{1},'#FigKeyPressFcn'),
  QuestFig=get(0,'CurrentFigure');
  AsciiVal= abs(get(QuestFig,'CurrentCharacter'));
  if ~isempty(AsciiVal),
    if AsciiVal==32 | AsciiVal==13,
      set(QuestFig,'UserData',1);
      uiresume(QuestFig);
    end %if AsciiVal
  end %if ~isempty
  return
end
%%%%%%%%%%%%%%%%%%%%%
%%% General Info. %%%
%%%%%%%%%%%%%%%%%%%%%
Black      =[0       0        0      ]/255;
LightGray  =[192     192      192    ]/255;
LightGray2 =[160     160      164    ]/255;
MediumGray =[128     128      128    ]/255;
White      =[255     255      255    ]/255;

%%%%%%%%%%%%%%%%%%%%
%%% Nargin Check %%%
%%%%%%%%%%%%%%%%%%%%
if nargout>1,error('Wrong number of output arguents for QUESTDLG');end
if nargin==1,Title=' ';end
if nargin<=2, Default='Yes';end
if nargin==3, Default=Btn1;end
if nargin<=3, Btn1='Yes'; Btn2='No'; Btn3='Cancel';NumButtons=3;end
if nargin==4, Default=Btn2;Btn2=[];Btn3=[];NumButtons=1;end
if nargin==5, Default=Btn3;Btn3=[];NumButtons=2;end
if nargin==6, NumButtons=3;end
if nargin>6, error('Too many input arguments');NumButtons=3;end

%%%%%%%%%%%%%%%%%%%%%%%
%%% Create QuestFig %%%
%%%%%%%%%%%%%%%%%%%%%%%
FigPos=get(0,'DefaultFigurePosition');
FigWidth=75;FigHeight=45;
FigPos(3:4)=[FigWidth FigHeight];
QuestFig=dialog(                                               ...
               'Visible'         ,'off'                      , ...
               'Name'            ,Title                      , ...
               'Pointer'         ,'arrow'                    , ...
               'Units'           ,'points'                   , ...
               'Position'        ,FigPos                     , ...
               'KeyPressFcn'     ,'questdlg #FigKeyPressFcn;', ...
               'UserData'        ,0                          , ...
               'IntegerHandle'   ,'off'                      , ...
               'WindowStyle'     ,'normal'                   , ... 
               'HandleVisibility','callback'                 , ...
               'Tag'             ,Title                        ...
               );

%%%%%%%%%%%%%%%%%%%%%
%%% Set Positions %%%
%%%%%%%%%%%%%%%%%%%%%
DefOffset=3;

IconWidth=32;
IconHeight=32;
IconXOffset=DefOffset;
IconYOffset=FigHeight-DefOffset-IconHeight;
IconCMap=[Black;get(QuestFig,'Color')];

DefBtnWidth=40;
BtnHeight=20;
BtnYOffset=DefOffset;
BtnFontSize=get(0,'FactoryUIControlFontSize');

BtnWidth=DefBtnWidth;

ExtControl=uicontrol(QuestFig   , ...
                     'Style'    ,'pushbutton', ...
                     'String'   ,' '         , ...
                     'FontUnits','points'   , ...                     
                     'FontSize' ,BtnFontSize   ...
                     );
                     
for lp=1:NumButtons,
  eval(['ExtBtnString=Btn' num2str(lp) ';']);
  set(ExtControl,'String',ExtBtnString);
  BtnExtent=get(ExtControl,'Extent');
  BtnWidth=max(BtnWidth,BtnExtent(3)+8);
end % lp
delete(ExtControl);

MsgTxtXOffset=IconXOffset+IconWidth;

FigWidth=max(FigWidth,MsgTxtXOffset+NumButtons*(BtnWidth+2*DefOffset));
FigPos(3)=FigWidth;
set(QuestFig,'Position',FigPos);

BtnXOffset=zeros(NumButtons,1);

if NumButtons==1,
  BtnXOffset=(FigWidth-BtnWidth)/2;
elseif NumButtons==2,
  BtnXOffset=[MsgTxtXOffset
              FigWidth-DefOffset-BtnWidth];
elseif NumButtons==3,
  BtnXOffset=[MsgTxtXOffset
              0
              FigWidth-DefOffset-BtnWidth];
  BtnXOffset(2)=(BtnXOffset(1)+BtnXOffset(3))/2;
end

MsgTxtYOffset=DefOffset+BtnYOffset+BtnHeight;
MsgTxtWidth=FigWidth-DefOffset-MsgTxtXOffset-IconWidth;
MsgTxtHeight=FigHeight-DefOffset-MsgTxtYOffset;
MsgTxtForeClr=Black;
MsgTxtBackClr=get(QuestFig,'Color');

CBString='uiresume(gcf)';
for lp=1:NumButtons,
  eval(['ButtonString=Btn',num2str(lp),';']);
  ButtonTag=['Btn' num2str(lp)];
  
  BtnHandle(lp)=uicontrol(QuestFig            , ...
                         'Style'              ,'pushbutton', ...
                         'Units'              ,'points'    , ...
                         'Position'           ,[ BtnXOffset(lp) BtnYOffset  ...
                                                 BtnWidth       BtnHeight   ...
                                               ]           , ...
                         'CallBack'           ,CBString    , ...
                         'String'             ,ButtonString, ...
                         'HorizontalAlignment','center'    , ...
                         'FontUnits'          ,'points'    , ...
                         'FontSize'           ,BtnFontSize , ...
                         'Tag'                ,ButtonTag     ...
                         );
                                   
end

MsgHandle=uicontrol(QuestFig            , ...
                   'Style'              ,'text'         , ...
                   'Units'              ,'points'       , ...
                   'Position'           ,[MsgTxtXOffset      ...
                                          MsgTxtYOffset      ...
                                          0.95*MsgTxtWidth   ...
                                          MsgTxtHeight       ...
                                         ]              , ...
                   'String'             ,{' '}          , ...
                   'Tag'                ,'Question'     , ...
                   'HorizontalAlignment','left'         , ...    
                   'FontUnits'          ,'points'       , ...
                   'FontWeight'         ,'bold'         , ...
                   'FontSize'           ,BtnFontSize    , ...
                   'BackgroundColor'    ,MsgTxtBackClr  , ...
                   'ForegroundColor'    ,MsgTxtForeClr    ...
                   );

[WrapString,NewMsgTxtPos]=textwrap(MsgHandle,Question,75);

NumLines=size(WrapString,1);

MsgTxtWidth=max(MsgTxtWidth,NewMsgTxtPos(3));
MsgTxtHeight=NewMsgTxtPos(4);

MsgTxtXOffset=IconXOffset+IconWidth+DefOffset;
FigWidth=max(NumButtons*(BtnWidth+DefOffset)+DefOffset, ...
             MsgTxtXOffset+MsgTxtWidth+DefOffset);

        
% Center Vertically around icon  
if IconHeight>MsgTxtHeight,
  IconYOffset=BtnYOffset+BtnHeight+DefOffset;
  MsgTxtYOffset=IconYOffset+(IconHeight-MsgTxtHeight)/2;
  FigHeight=IconYOffset+IconHeight+DefOffset;    
% center around text    
else,
  MsgTxtYOffset=BtnYOffset+BtnHeight+DefOffset;
  IconYOffset=MsgTxtYOffset+(MsgTxtHeight-IconHeight)/2;
  FigHeight=MsgTxtYOffset+MsgTxtHeight+DefOffset;    
end    
  
if NumButtons==1,
  BtnXOffset=(FigWidth-BtnWidth)/2;
elseif NumButtons==2,
  BtnXOffset=[(FigWidth-DefOffset)/2-BtnWidth
              (FigWidth+DefOffset)/2      
              ];
          
elseif NumButtons==3,
  BtnXOffset(2)=(FigWidth-BtnWidth)/2;
  BtnXOffset=[BtnXOffset(2)-DefOffset-BtnWidth
              BtnXOffset(2)
              BtnXOffset(2)+BtnWidth+DefOffset
             ];              
end

ScreenUnits=get(0,'Units');
set(0,'Units','points');
ScreenSize=get(0,'ScreenSize');
set(0,'Units',ScreenUnits);

FigPos(1)=(ScreenSize(3)-FigWidth)/2;
FigPos(2)=(ScreenSize(4)-FigHeight)/2;
FigPos(3:4)=[FigWidth FigHeight];


set(QuestFig ,'Position',FigPos);

BtnPos=get(BtnHandle,{'Position'});BtnPos=cat(1,BtnPos{:});
BtnPos(:,1)=BtnXOffset;
BtnPos=num2cell(BtnPos,2);  
set(BtnHandle,{'Position'},BtnPos);  

set(MsgHandle, ...
   'Max'     ,NumLines                                              , ...
   'Position',[MsgTxtXOffset MsgTxtYOffset MsgTxtWidth MsgTxtHeight], ...
   'String'  ,WrapString                                              ...
   );
   

IconAxes=axes(                                      ...
             'Units'       ,'points'              , ...
             'Parent'      ,QuestFig              , ...  
             'Position'    ,[IconXOffset IconYOffset  ...
                             IconWidth IconHeight], ...
             'NextPlot'    ,'replace'             , ...
             'Tag'         ,'IconAxes'              ...
             );         
 
set(QuestFig ,'NextPlot','add');

IconData= ...
   [2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 2 2 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2; 
    2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 2 2 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2; 
    2 2 2 2 2 2 2 2 2 2 2 2 1 1 2 2 2 2 1 1 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 1 1 2 2 2 2 1 1 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 1 1 2 2 2 2 2 2 1 1 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 1 1 2 2 1 1 2 2 1 1 2 2 2 2 2 2 2 2 2 2 2; 
    2 2 2 2 2 2 2 2 2 2 1 1 2 2 1 1 1 1 2 2 1 1 2 2 2 2 2 2 2 2 2 2; 
    2 2 2 2 2 2 2 2 2 2 1 1 2 2 1 1 1 1 2 2 1 1 2 2 2 2 2 2 2 2 2 2; 
    2 2 2 2 2 2 2 2 2 1 1 2 2 2 1 1 1 1 2 2 2 1 1 2 2 2 2 2 2 2 2 2; 
    2 2 2 2 2 2 2 2 2 1 1 2 2 2 1 1 1 1 2 2 2 1 1 2 2 2 2 2 2 2 2 2; 
    2 2 2 2 2 2 2 2 1 1 2 2 2 2 1 1 1 1 2 2 2 2 1 1 2 2 2 2 2 2 2 2; 
    2 2 2 2 2 2 2 2 1 1 2 2 2 2 1 1 1 1 2 2 2 2 1 1 2 2 2 2 2 2 2 2; 
    2 2 2 2 2 2 2 1 1 2 2 2 2 2 1 1 1 1 2 2 2 2 2 1 1 2 2 2 2 2 2 2; 
    2 2 2 2 2 2 2 1 1 2 2 2 2 2 1 1 1 1 2 2 2 2 2 1 1 2 2 2 2 2 2 2; 
    2 2 2 2 2 2 1 1 2 2 2 2 2 2 1 1 1 1 2 2 2 2 2 2 1 1 2 2 2 2 2 2; 
    2 2 2 2 2 2 1 1 2 2 2 2 2 2 1 1 1 1 2 2 2 2 2 2 1 1 2 2 2 2 2 2; 
    2 2 2 2 2 1 1 2 2 2 2 2 2 2 1 1 1 1 2 2 2 2 2 2 2 1 1 2 2 2 2 2; 
    2 2 2 2 2 1 1 2 2 2 2 2 2 2 2 1 1 2 2 2 2 2 2 2 2 1 1 2 2 2 2 2;
    2 2 2 2 1 1 2 2 2 2 2 2 2 2 2 1 1 2 2 2 2 2 2 2 2 2 1 1 2 2 2 2;
    2 2 2 2 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 2 2 2 2;
    2 2 2 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 2 2 2;
    2 2 2 1 1 2 2 2 2 2 2 2 2 2 2 1 1 2 2 2 2 2 2 2 2 2 2 1 1 2 2 2;
    2 2 1 1 2 2 2 2 2 2 2 2 2 2 1 1 1 1 2 2 2 2 2 2 2 2 2 2 1 1 2 2;
    2 2 1 1 2 2 2 2 2 2 2 2 2 2 1 1 1 1 2 2 2 2 2 2 2 2 2 2 1 1 2 2;
    2 1 1 2 2 2 2 2 2 2 2 2 2 2 2 1 1 2 2 2 2 2 2 2 2 2 2 2 2 1 1 2;
    2 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 2;
    1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1;
    1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1; 
    2 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 2];


Img=image('CData',IconData,'Parent',IconAxes);
set(QuestFig, 'Colormap', IconCMap);
set(IconAxes, ...
   'Visible','off'           , ...
   'YDir'   ,'reverse'       , ...
   'XLim'   ,get(Img,'XData'), ...
   'YLim'   ,get(Img,'YData')  ...
   );
set(findobj(QuestFig),'HandleVisibility','callback');
set(QuestFig ,'WindowStyle','modal','Visible','on');
drawnow;

uiwait(QuestFig);

TempHide=get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');

if any(get(0,'Children')==QuestFig),
  if get(QuestFig,'UserData'),
    ButtonName=Default;
  else,
    ButtonName=get(get(QuestFig,'CurrentObject'),'String');
  end
  delete(QuestFig);
else
  ButtonName=Default;
end

set(0,'ShowHiddenHandles',TempHide);
