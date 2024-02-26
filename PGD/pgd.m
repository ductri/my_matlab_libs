function [x, tracking] = pgd(g_fn, p_fn, step_size, init_point, varargin) 
    p = inputParser;
    p.addOptional('verbose', 0);
    p.addOptional('debug', 0);
    p.addOptional('f_fn', @(x) 100);
    p.addOptional('max_iters', 500);
    p.addOptional('tol', 1e-6);
    p.addOptional('prox_weight', 1);
    p.addOptional('logging_interval', 10);
    p.addOptional('shift_x_fn', @(x, step_size, d) x-step_size*d);
    p.addOptional('norm', @(x) norm(x, 'fro'));
    p.KeepUnmatched = true;
    p.parse(varargin{:});
    ops = p.Results;

    DEBUG = ops.debug;
    VERBOSE = ops.verbose;

    if VERBOSE, fprintf('Running pgd with DEBUG=%d ...\n', DEBUG), end;

    if ~isa(step_size,'function_handle') 
       stepsizeSchedule = @(i) step_size;
    else
       stepsizeSchedule = step_size;
    end

    tracking = struct;
    tracking.obj = 100*ones(ops.max_iters, 1);
    tracking.time = 100*ones(ops.max_iters, 1);
    tracking.norm_g = 100*ones(ops.max_iters, 1);
    tracking.dis = 100*ones(ops.max_iters, 1);
    tracking.Stepsize = 100*ones(ops.max_iters, 1);
    tracking.nnz = 100*ones(ops.max_iters, 1);
    
    duration = 0;
    step_tic = tic;
    x = init_point;
    g = g_fn(x);
    duration = duration + toc(step_tic);
    for i=1:ops.max_iters %TODO add criteria for early stopping
        step_tic = tic;

        stepSize = stepsizeSchedule(i);
        x = ops.shift_x_fn(x, stepSize, g);
        
        prox_weight = stepSize * ops.prox_weight;
        x = p_fn(x, prox_weight);
        g = g_fn(x);
        if ops.norm(g) < ops.tol, break; end;

        duration = duration + toc(step_tic);
        if DEBUG, tracking.obj(i) = ops.f_fn(x); end;
        if DEBUG, tracking.norm_g(i) = ops.norm(g); end;
        if DEBUG, tracking.time(i) = duration; end;
        % if DEBUG, tracking.dis(i) = norm(x - ops.ground_truth, 2)^2; end;
        if DEBUG, tracking.Stepsize(i) = stepSize; end;
        % if DEBUG, tracking.nnz(i) = nnz(x); end;
        if (mod(i, ops.logging_interval)==0) && VERBOSE
            fprintf('Iter: %d \n', i);
            if DEBUG
                fprintf('Obj: %e \n', tracking.obj(i));
            end
        end
    end
    tracking.num_iters = i;
end
