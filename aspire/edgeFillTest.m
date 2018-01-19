A = zeros(5);
w = ones(5);
B = [1:5;
     2:6;
     3:7;
     4:8;
     5:9];

m = [A A A;
     A B A
     A A A]

Z = m(:);
[X, Y] = meshgrid(1:size(m, 1), 1:size(m, 2));
sf = fit([X(:), Y(:)], Z, 'poly11', 'Exclude', Z == 0)
plot(sf, [X(:), Y(:)], Z)

out = reshape(sf(X,Y), size(m))

% image = [0 0 2 3; 0 0 2 3; 0 0 2 3; 0 0 2 3]
% % edgeFill(image, 3)
% 
% m = [0 0 0 0;
%      0 0 0 0;
%      0 0 3 4;
%      0 0 4 5]
% % edgeFill(m, 3)
% 
% 
% A = nan(5);
% w = ones(5);
% B = [1:5;
%      2:6;
%      3:7;
%      4:8;
%      5:9];
% 
% m = [A A A;
%      A B A
%      A A A]
% %edgeFill(m, 7)
% a = nanfft(m)
% ifft(a)


% line = [6 5 7 10]
% nSteps = 4
% m = length(line);             % number of points
% X = [ones(m,1), (1:m)'];   % forming X of X beta = y
% y = line';                % forming y of X beta = y
% betaHat = (X' * X) \ (X' * y);   % computing projection of matrix X on y, giving beta
% % display best fit parameters
% disp(betaHat);
% % plot the best fit line
% xx = linspace(0, 5, 2);
% yy = betaHat(1) + betaHat(2)*xx;
% plot(xx, yy)
% % plot the points (data) for which we found the best fit
% hold on
% plot(1:m, line, 'or')
% hold off
% 
