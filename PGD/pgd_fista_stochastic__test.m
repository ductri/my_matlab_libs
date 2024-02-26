clc; clear; close all;

n = 100; d = 20000;
x = rand(n, 1);
A = rand(d, n);
b = A*x;
f_fn = @(x) (1/d) * 0.5*norm(A*x - b, 2)^2;
x_star = x;
f_star = f_fn(x_star);

g_stochastic_fn = @(x) computeGrad(x, A, b, 10);
g_deterministic_fn = @(x) computeGradDeterministic(x, A, b);
d_step_size = 1/eigs(A'*A, 1)*d;
p_fn = @(x, l) proj(x);
m = eigs(A'*A, 1, 'sm');


ops = struct;
ops.verbose = true;
ops.debug = true;
ops.f_fn = f_fn;
ops.ground_truth = x_star;
ops.max_iters = 30000;
init_point = randn(n, 1);
stepsizeHandler = @(i, g) stepsizeSchedule1(i, m, d);
[x_hat, trackingS1] = pgd_fista(g_stochastic_fn, p_fn, stepsizeHandler, init_point, ops);

global gh;
gh = zeros(n, 1);
stepsizeHandler = @(i, g) stepsizeSchedule2(i, g, m, d);
[x_hat, trackingS2] = pgd_fista(g_stochastic_fn, p_fn, stepsizeHandler, init_point, ops);


ops.max_iters = 1000;
[x_hat, trackingD] = pgd_fista(g_deterministic_fn, p_fn, d_step_size, init_point, ops);

figure();
semilogy(trackingS1.time, trackingS1.obj-f_star, 'DisplayName', 'StochasticGrad');
hold on
semilogy(trackingS2.time, trackingS2.obj-f_star, 'DisplayName', 'ADAGrad');
semilogy(trackingD.time, trackingD.obj-f_star, 'DisplayName', 'Full Grad');
ylabel('Obj distance')
xlabel('Time (seconds)')
legend
saveas(gcf, 'results/stochastic-compare.eps', 'epsc')

figure();
semilogy(trackingS1.time, trackingS1.dis, 'DisplayName', 'StochasticGrad');
hold on;
semilogy(trackingS2.time, trackingS2.dis, 'DisplayName', 'ADAGrad');
semilogy(trackingD.time, trackingD.dis, 'DisplayName', 'Full Grad');
ylabel('Solution distance')
legend

figure();
plot(trackingS2.Stepsize - trackingS2.Stepsize(end))

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

function [out] = stepsizeSchedule1(i, m, d) 
    Beta = (1/m)*10^3;
    Gamma = 1e6/d*3;
    out = Beta / (Gamma + i);
end

function [out] = stepsizeSchedule2(i, g, m, d)
    global gh;
    epsilon = 1e-8;
    step_size_default = 0.01;
    gh = gh + g.^2;
    out = step_size_default./(sqrt(gh) + epsilon);
end
