clc; clear; close all;

n = 100; d = 3000;
x = rand(n, 1);
A = rand(d, n);
b = A*x;

f_fn = @(x) (1/d) * 0.5*norm(A*x - b, 2)^2;
g_fn = @(x) computeGrad(x, A, b, 3000);

x_star = x;
f_star = f_fn(x_star);

ops = struct;
ops.verbose = true;
ops.debug = true;
ops.f_fn = f_fn;
ops.ground_truth = x_star;
ops.max_iters = 10000;

p_fn = @(x, l) proj(x);
step_size = 1/eigs(A'*A, 1)*d;
m = eigs(A'*A, 1, 'sm');
stepsizeHandler = @(i) stepsizeSchedule(i, m, d);
init_point = randn(n, 1);
[x_hat, trackingS] = pgd(g_fn, p_fn, stepsizeHandler, init_point, ops);


%% DETERMINISTIC
g_fn = @(x) computeGradDeterministic(x, A, b);

x_star = x;
f_star = f_fn(x_star);

ops = struct;
ops.verbose = true;
ops.debug = true;
ops.f_fn = f_fn;
ops.ground_truth = x_star;
ops.max_iters = 2000;

p_fn = @(x, l) proj(x);
step_size = 1/eigs(A'*A, 1)*d;
m = eigs(A'*A, 1, 'sm');
stepsizeHandler = @(i) stepsizeSchedule(i, m, d);
init_point = randn(n, 1);
[x_hat, trackingD] = pgd(g_fn, p_fn, stepsizeHandler, init_point, ops);

figure();
semilogy(trackingS.time, trackingS.obj-f_star, 'DisplayName', 'Stochastic');
hold on
semilogy(trackingD.time, trackingD.obj-f_star, 'DisplayName', 'Full Grad');
ylabel('Obj distance')
legend

figure();
semilogy(trackingS.time, trackingS.dis, 'DisplayName', 'Stochastic');
hold on;
semilogy(trackingD.time, trackingD.dis, 'DisplayName', 'Full Grad');
ylabel('Solution distance')
legend

norm(x_hat - x_star, 2)

function [x] = proj(x) 
    x(x<0) = 0;
    x = x;
end

function [out] = computeGradDeterministic(x, A, b) 
    out = (1/size(A, 1)) * (A'*A*x  - A'*b);
end
function [out] = computeGrad(x, A, b, sampleSize) 
    indices = datasample(1:size(A, 1), sampleSize, 'Replace', false);
    A = A(indices, :);
    b = b(indices);
    out = (1/sampleSize) * (A'*A*x  - A'*b);
end

function [out] = stepsizeSchedule(i, m, d) 
    Beta = (1/m)*10^13;
    Gamma = 1e16/d*3;
    out = Beta / (Gamma + i);
end
