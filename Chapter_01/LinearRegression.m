%% LinearRegression Script that demonstrates linear regression
% Fit a linear model to linear or quadratic data

%% Generate the data and perform the regression

x     = linspace(0,1,500)';
n     = length(x);

% Model a polynomial, y = ax2 + mx + b
a     = 1.0;     % quadratic - make nonzero for larger errors
m     = 1.0;     % slope
b     = 1.0;     % intercept
sigma = 0.1; % standard deviation of the noise
y0    = a*x.^2 + m*x + b;
y     = y0 + sigma*randn(n,1);

% Perform the linear regression using pinv
a     = [x ones(n,1)];
c     = pinv(a)*y;
yR    = c(1)*x + c(2); % the fitted line

%% Generate plots
h = figure;
h.Name = 'Linear Regression';
plot(x,y); hold on;
plot(x,yR,'linewidth',2);
grid on
xlabel('x');
ylabel('y');
title('Linear Regression');
legend('Data','Fit')

figure('Name','Regression Error')
plot(x,yR-y0);
grid on
xlabel('x');
ylabel('\Delta y');
title('Error between Model and Regression')
