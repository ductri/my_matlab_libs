clc; clear; close all;

x = 100*rand(100, 1);
A = rand(100, 100);
A = A' + A + 10*eye(size(A));
b = 2*A*x;

f_fn = @(x) x'*A*x - b'*x;
g_fn = @(x) 2*A'*x - b;

x_star = 0.5*(A\b);
f_star = f_fn(x_star);

ops = struct;
ops.verbose = true;
ops.debug = true;
ops.f_fn = f_fn;
p_fn = @(x) proj(x);
step_size = 1/eigs(A, 1)/2;
init_point = randn(100, 1);
[x_hat, tracking] = pgd_fista_ls(g_fn, p_fn, init_point, ops);

figure();
semilogy(tracking.obj-f_star);

norm(x_hat - x_star, 2)

function [x] = proj(x) 
    x(x<0) = 0;
end
