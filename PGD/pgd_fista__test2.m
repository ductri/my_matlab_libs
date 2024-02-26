clc; clear; close all;
addpath('~/code/matlab/common')



n = 100; 
x = randn(n, 1);
tmp = randn(n, n); tmp = tmp' + tmp;
[V, ~] = eig(tmp);
D = diag(rand(n, 1));
A = V*D*V';
b = A*x;

x_star = A\b;
f_star = 0;

b = add_noise(b, 200);
f_fn = @(x) norm(A*x - b)^2;
g_fn = @(x) 2*A'*(A*x-b);


ops = struct;
ops.verbose = false;
ops.debug = true;
ops.f_fn = f_fn;
ops.ground_truth = x_star;
ops.max_iters = 1000;
p_fn = @(x, l) proj(x);
step_size = 1/eigs(A'*A, 1)/2;
init_point = randn(100, 1);
[x_hat, tracking] = pgd_fista(g_fn, p_fn, step_size, init_point, ops);

figure();
semilogy(tracking.obj-f_star);
ylabel('Objective')

norm(x_hat - x_star, 2)

function [x] = proj(x) 
    % x(x<0) = 0;
    x =x ;
end
