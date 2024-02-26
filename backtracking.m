function [alp] = backtracking(f_fn, x, d, g, eps, eta, ops) 
%UNTITLED2 Backtracking to find proper step size
%   f: Objective function, callable function
%   x: Current point, in column format
%   d: Direction to search, in column format
%   g: Gradient at x, in row format
%   eps: Coefficient of backtracking, should be 0.4 in default
%   eta: Coefficient of backtracking, should be 1.2 in default

    if isfield(ops, 'max_iters'), max_iters = ops.max_iters; else max_iters = 100; end;
    if isfield(ops, 'verbose'), VERBOSE = ops.verbose; else VERBOSE = false; end;
    alp = 1.0;
    iter = 1;
    while true & iter<max_iters
        if f_fn(x + alp*d) <= f_fn(x) + eps*alp*g*d
            break
        else
            alp = alp/eta;
        end
        iter = iter+1;
    end
    if VERBOSE
        if iter>=max_iters
            fprintf('WARNING from backtracking: Exceeding max_iters=%d\n', max_iters);
        end
        fprintf('backtracking took %d steps\n', iter);
    end
end
