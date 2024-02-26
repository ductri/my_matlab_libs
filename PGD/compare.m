%% Clear all things
clc; clear; close all; path(pathdef);
addpath('~/code/matlab/common/prox_ops')

n = 1000;
x = 100*rand(n, 1);
A = rand(n, n);
A = A'*A + 0.01*eye(size(A));
b = 2*A*x;
%b = rand(100, 1);

f_fn = @(x) x'*A*x - b'*x;
g_fn = @(x) 2*A'*x - b;

x_star = 0.5*(A\b);
f_star = f_fn(x_star);

p_fn = @(x, l) proj_nonnegative(x);
step_size = 1/eigs(A, 1)/2;
minEigvalue = 2*eigs(A, 1, 'sm');
init_point = randn(n, 1);

ops = struct;
ops.verbose = false;
ops.maxIters = 3000;
ops.debug = true;
ops.fFn = f_fn;
ops.groundTruth = x_star;
[~, t6] = pgd_vfista(g_fn, p_fn, step_size, init_point, minEigvalue, ops);

ops = struct;
ops.debug = true;
ops.verbose = true;
ops.max_iters = 3000;
ops.tol = 1e-16;
ops.f_fn = f_fn;
ops.ground_truth = x_star;

[~, t5] = pgd_fista_fixed_restart(g_fn, p_fn, step_size, init_point, 100, ops);
[~, t4] = pgd_fista_fixed_restart(g_fn, p_fn, step_size, init_point, 200, ops);
[~, t3] = pgd_fista_adaptive_restart(g_fn, p_fn, step_size, init_point, ops);
[~, t2] = pgd_fista_fixed_restart(g_fn, p_fn, step_size, init_point, 280, ops);
[~, t1] = pgd_fista(g_fn, p_fn, step_size, init_point, ops);


figure();
semilogy(t6.time, t6.obj - f_star, 'DisplayName', 'v-fista');
hold on
semilogy(t5.time, t5.obj - f_star, 'DisplayName', 'fixed restart interval=100');
semilogy(t4.time, t4.obj - f_star, 'DisplayName', 'fixed restart interval=200');
semilogy(t2.time, t2.obj - f_star, 'DisplayName', 'fixed restart interval=280');
semilogy(t3.time, t3.obj - f_star, '-.', 'DisplayName',  'adaptive restart', 'linewidth', 2);
semilogy(t1.time, t1.obj - f_star, '-.', 'DisplayName', 'fista PGD', 'linewidth', 2);
legend
ylabel('f - f-star');
xlabel('time (second)')
title('toy example')
saveas(gcf, 'results/compare-time-0.01.eps', 'epsc')


figure();
semilogy(t6.obj - f_star, 'DisplayName', 'v-fista');
hold on
semilogy(t5.obj - f_star, 'DisplayName', 'fixed restart interval=100');
semilogy(t4.obj - f_star, 'DisplayName', 'fixed restart interval=200');
semilogy(t2.obj - f_star, 'DisplayName', 'fixed restart interval=280');
semilogy(t3.obj - f_star, '-.', 'DisplayName',  'adaptive restart', 'linewidth', 2);
semilogy(t1.obj - f_star, '-.', 'DisplayName', 'fista PGD', 'linewidth', 2);
legend
ylabel('f - f-star');
xlabel('time (second)')
title('toy example')
legend
ylabel('f - f-star');
xlabel('step')
title('toy example')
saveas(gcf, 'results/compare-iters-0.01.eps', 'epsc')
