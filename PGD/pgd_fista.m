function [x_k, tracking] = pgd_fista(g_fn, p_fn, step_size, init_point, varargin) 

    p = inputParser;
    p.addOptional('verbose', 0);
    p.addOptional('debug', 0);
    p.addOptional('f_fn', @(x) 100);
    p.addOptional('max_iters', 500);
    p.addOptional('tol', 1e-6);
    p.addOptional('prox_weight', 1);
    p.addOptional('logging_interval', 10);
    p.addOptional('minus_fn', @(x, y) x-y);
    p.addOptional('scale_fn', @(x, alpha) alpha*x);
    p.addOptional('norm', @(x) sqrt(sum(x.*x, 'all')));

    p.KeepUnmatched = true;
    p.parse(varargin{:});
    ops = p.Results;


    if ~isa(step_size,'function_handle') 
       stepsizeSchedule = @(i) step_size;
    else
       stepsizeSchedule = step_size;
    end

    tracking = struct;
    max_iters = ops.max_iters;
    tracking.obj = 100*ones(max_iters, 1);
    tracking.norm_g2 = 100*ones(max_iters, 1);
    tracking.time = 100*ones(max_iters, 1);
    tracking.dis2 = 100*ones(max_iters, 1);
    tracking.Stepsize = 100*ones(max_iters, 1);
    tracking.nnz = 100*ones(max_iters, 1);

    duration = 0;
    step_tic = tic;
    x_km1 = init_point; y_k = x_km1;
    t_k = 1;
    duration = duration + toc(step_tic);
    for i=1:max_iters
        step_tic = tic;

        g = g_fn(y_k);
        stepSize = stepsizeSchedule(i);
        % u = y_k - stepSize.*g;
        u = ops.minus_fn(y_k, ops.scale_fn(g, stepSize));

        prox_weight = stepSize .* ops.prox_weight;
        x_k = p_fn(u, prox_weight);
        t_kp1 = (1 + sqrt(1+4*t_k^2))/2;
        y_kp1 = ops.minus_fn(x_k, ops.scale_fn(ops.minus_fn(x_k, x_km1), -(t_k-1)/t_kp1));
        
        % stopping_criteria = norm(y_kp1 - y_k, 'fro');
        stopping_criteria = ops.norm(ops.minus_fn(x_k,x_km1));
        x_km1 = x_k;
        y_k = y_kp1;
        t_k = t_kp1;

        duration = duration + toc(step_tic);
        DEBUG = ops.debug;
        if DEBUG, tracking.obj(i) = ops.f_fn(x_k); end;
        % if DEBUG, tracking.norm_g2(i) = trace(g'*g); end;
        if DEBUG, tracking.time(i) = duration; end;
        % if DEBUG, dis_current = x_k - ops.ground_truth; end;
        % if DEBUG, tracking.dis2(i) = trace(dis_current'*dis_current); end;
        if DEBUG, tracking.Stepsize(i) = mean(stepSize); end;
        if  stopping_criteria < ops.tol, break; end;
        if ops.verbose
            if mod(i, 10) == 0
                fprintf(sprintf('Iter %d\n', i))
                if DEBUG
                    fprintf('Obj: %e \n', tracking.obj(i));
                end
            end
        end


        % tracking.nnz(i) = nnz(x_k);
    end
    tracking.num_iters = i;
    tracking.stopping_criteria = stopping_criteria;

    tracking.obj = tracking.obj(1:i);
    tracking.norm_g2 = tracking.norm_g2(1:i);
    tracking.time = tracking.time(1:i);
    % tracking.dis2 = tracking.dis2(1:i);
    tracking.stopping_criteria = stopping_criteria;

end
