%% Clear all things
clc; clear; close all; path(pathdef);
addpath('./../prox_ops/')
addpath('./../')

%n = 100; 
%x = rand(n, 1); x(x<0.8) = 0;
%tmp = randn(n, n); tmp = tmp' + tmp;
%[V, ~] = eig(tmp);
%D = diag(rand(n, 1));
%A = V*D*V';
%b = A*x;

load('debug.mat')
x_star = A\b;
f_star = 0;

b = add_noise(b, 20);
f_fn = @(x) norm(A*x - b)^2;
g_fn = @(x) 2*A'*(A*x-b);


ops = struct;
ops.debug = true;
ops.verbose = true;
ops.max_iters = 2000;
ops.f_fn = f_fn;
ops.prox_weight = 5e-4;
ops.ground_truth = x_star;
ops.tol = 1e-30;

p_fn = @prox_l1;
step_size = 1/eigs(A'*A, 1)/2;
init_point = randn(n, 1);
[x_hat, tracking] = pgd_fista(g_fn, p_fn, step_size, init_point, ops);

p_fn = @(x, l) x;
[x_hat2, tracking2] = pgd_fista(g_fn, p_fn, step_size, init_point, ops);


figure();
semilogy(tracking.dis , 'DisplayName', 'sparse');
hold on
semilogy(tracking2.dis, 'DisplayName', 'normal');
legend
ylabel('norm(X-X^*)^2')
saveas(gcf, 'results/compare-sparsity-dis.eps', 'epsc')


