%% Clear all things
clc; clear; close all; path(pathdef);
addpath('./../prox_ops/')
addpath('./../')


x = rand(100, 1); x(x<0.5) = 0; x =x*100;
A = rand(100, 100); A = A' + A + 10*eye(size(A));
[V, D] = eig(A);
D(5, 5) = 1e-1;
A = V * D *V';

b = 2*A*x;

% A = add_noise(A, 15);
b = add_noise(b, 30);

f_fn = @(x) x'*A*x - b'*x;
g_fn = @(x) 2*A'*x - b;

x_star = 0.5*(A\b);
f_star = f_fn(x_star);

ops = struct;
ops.debug = true;
ops.verbose = false;
ops.max_iters = 1000;
ops.f_fn = f_fn;
ops.prox_weight = 0.1;
ops.ground_truth = x;

p_fn = @prox_l1;
% p_fn = @(x, l) x;
step_size = 1/eigs(A, 1)/2;
init_point = randn(100, 1);
[x_hat, tracking] = pgd(g_fn, p_fn, step_size, init_point, ops);

figure();
semilogy(tracking.obj - tracking.obj(end));

tracking.dis(end)
