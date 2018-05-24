%% Demonstrate MATLAB plot types
% Demonstrate 2D plot types, plot, bar, barh and pie.
%% See also
% NewFigure

h = NewFigure('Plot Types');
x = linspace(0,10,10);
y = rand(1,10);

subplot(4,1,1);
plot(x,y);
subplot(4,1,2);
bar(x,y);
subplot(4,1,3);
barh(x,y);
ax4 = subplot(4,1,4);
pie(y)
colormap(ax4,'gray')
