function [x_k, tracking] = pgd_fista_ls(g_fn, p_fn, init_point, ops) 

    if isfield(ops, 'max_iters'), max_iters = ops.max_iters; else max_iters = 500; end;
    if isfield(ops, 'debug'), DEBUG = ops.debug; else DEBUG = false; end;
    if isfield(ops, 'verbose'), VERBOSE = ops.verbose; else VERBOSE = true; end;
    if isfield(ops, 'f_fn'), f_fn = ops.f_fn; end;
    if isfield(ops, 'tol'), tol = ops.tol; else tol = 1e-6; end;

    if VERBOSE, fprintf('Running pgd_fista_ls with DEBUG=%d ...\n', DEBUG); end;

    tracking = struct;
    tracking.obj = 100*ones(max_iters, 1);
    tracking.norm_g = 100*ones(max_iters, 1);
    tracking.time = 100*ones(max_iters, 1);

    duration = 0;
    step_tic = tic;
    x_km1 = init_point; y_k = x_km1;
    t_k = 1;
    duration = duration + toc(step_tic);
    for i=1:max_iters
        step_tic = tic;

        g = g_fn(y_k);

        backtracking_ops = struct;
        backtracking_ops.max_iters = 100;
        backtracking_ops.verbose = false;
        step_size = backtracking(f_fn, y_k, -g, g', 0.9, 1.2, backtracking_ops);
        if VERBOSE, fprintf('pgd_fista_ls: step_size=%f\n', step_size); end;

        u = y_k - step_size*g;
        x_k = p_fn(u);
        t_kp1 = (1 + sqrt(1+4*t_k^2))/2;
        y_kp1 = x_k + (t_k-1)/t_kp1*(x_k - x_km1);
        
        x_km1 = x_k;
        y_k = y_kp1;
        t_k = t_kp1;

        duration = duration + toc(step_tic);
        if norm(g, 'fro') < tol, break; end;
        if DEBUG, tracking.obj(i) = f_fn(x_k); end;
        if DEBUG, tracking.norm_g(i) = norm(g, 2); end;
        if DEBUG, tracking.time(i) = duration; end;
    end
    tracking.num_iters = i;

end
