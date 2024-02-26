function [out] = sample_normal(n) 
% ----------------------------------------------------------------------
% 
% Use Central Limit theorem to sample standard normal distribution
% The X_i is drawn from Bernoulli distribution.
% Based on a nice post: https://bjlkeng.github.io/posts/sampling-from-a-normal-distribution/

% Author: Tri Nguyen (nguyetr9@oregonstate.edu)

% ----------------------------------------------------------------------
   out = zeros(n, 1);
   N = 10000;
   for i=1:n
       X = randi([0,1], 1, N);
       out(i) = (mean(X) - 0.5)*2*sqrt(N);
   end
end
