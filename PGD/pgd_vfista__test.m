%% Clear all things
clc; clear; close all; path(pathdef);
addpath('~/code/matlab/common/prox_ops')

x = 100*rand(100, 1);
A = rand(100, 100);
A = A' + A + 10*eye(size(A));
b = 2*A*x;

f_fn = @(x) x'*A*x - b'*x;
g_fn = @(x) 2*A'*x - b;

x_star = 0.5*(A\b);
f_star = f_fn(x_star);

ops = struct;
ops.verbose = false;
ops.debug = true;
ops.fFn = f_fn;
ops.groundTruth = x_star;
p_fn = @(x, l) proj_nonnegative(x);
step_size = 1/eigs(A, 1)/2;
minEigvalue = 2*eigs(A, 1, 'sm');
init_point = randn(100, 1);
[x_hat, tracking] = pgd_vfista(g_fn, p_fn, step_size, init_point, minEigvalue, ops);

figure();
semilogy(tracking.obj-f_star);
ylabel('Obj')

norm(x_hat - x_star, 2)

