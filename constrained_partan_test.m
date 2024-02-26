addpath('~/code/matlab_libs');
addpath('~/code/matlab_libs/partan');

%% Clear all things
clc;
clear;
close all;


%% Function definitions
Q = [2 1 0 10; 1 4 3 0.5; 0 3 -5 6; 10 0.5 6 -7];
b = [-1; 0; -2; 3];

f = @(x) 0.5*x'*Q*x + b'*x;
f_grad = @(x) x'*Q' + b';

gamma = @(y) 0.5*norm(y, 2)^2;
gamma_grad = @(y) y';
g_plus = @(x) max(0, x);
max_func_grad = @(x) sign(x) == 1;
g_plus_grad_matrix = @(x) diag(max_func_grad(x));
g = @(x) -x;
g_grad_matrix = @(x) diag([-1 -1 -1 -1]);
P1 = @(x) gamma(g_plus(g(x)));
P1_grad = @(x) gamma_grad(g_plus(g(x))) * g_plus_grad_matrix(g(x)) * g_grad_matrix(x);

h = @(x) 0.5*(norm(x, 2)^2 -1)^2;
h_grad = @(x) (x'*x -1)*2*x';

P2 = @(x) h(x);
P2_grad = @(x) h_grad(x);

P = @(x) P1(x) + P2(x);
P_grad = @(x) P1_grad(x) + P2_grad(x);

%% Init 
tau = 10^-6;
x = [1 2 3 4]';
c = 1; beta = 1.1;

%% Main loop
options = struct();
options.max_iters = 200;
options.debug = true;
coef_fn = @(c) c
[out, logging] = constrained_partan(f, f_grad, P, P_grad, x, coef_fn, options);

t_criteria = logging.t_criteria;
t_f = logging.t_f;
t_P = logging.t_P;

%% Plots
close all;
fig1 = figure();
semilogy(1:size(t_criteria, 1), t_criteria)
title('c*P(x) versus iteration index');
xlabel('Iteration index')
ylabel('c*P(x)')
grid on

fig2 = figure();
semilogy(1:size(t_P, 1), t_P)
title('P vs iteration index');
xlabel('Iteration index')
ylabel('P')
grid on

fig3 = figure();
plot(1:size(t_f, 1)-1, t_f(1:size(t_f, 1)-1))
title('Objective function value versus iteration index');
xlabel('Iteration index')
ylabel('f(x)')
grid on

