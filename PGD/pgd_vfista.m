function [x_k, Tracking] = pgd_vfista(g_fn, p_fn, step_size, init_point, ...
        min_egivalue, varargin) 

    p = inputParser;
    p.addOptional('maxIters', 500);
    p.addOptional('debug', false);
    p.addOptional('display', true);
    p.addOptional('fFn', @(x) x);
    p.addOptional('tolX', 1e-6);
    p.addOptional('proxWeight', 0);
    p.addOptional('groundTruth', nan);
    p.KeepUnmatched = true;
    p.parse(varargin{:});
    options = p.Results;

    if options.display
        fprintf('Running pgd_vFISTA with DEBUG=%d ...\n', options.debug); 
    end

    Tracking = struct;
    Tracking.obj = [];
    Tracking.normG = [];
    Tracking.time = [];
    Tracking.dis = [];

    duration = 0;
    step_tic = tic;
    x_k = init_point; y_k = x_k;
    duration = duration + toc(step_tic);
    kappa = (1/step_size)/min_egivalue;
    yStepSize = (sqrt(kappa)-1)/(sqrt(kappa)+1);
    for i=1:options.maxIters
        step_tic = tic;

        g = g_fn(y_k);
        u = y_k - step_size*g;

        proxWeight = step_size * options.proxWeight;
        x_kp1 = p_fn(u, proxWeight);
        y_kp1 = x_kp1 + yStepSize*(x_kp1 - x_k);
        
        % stoppingCriteria = norm(y_kp1 - y_k, 'fro');
        stoppingCriteria = norm(x_kp1 - x_k, 'fro');
        if  stoppingCriteria < options.tolX, break; end;
        x_k = x_kp1;
        y_k = y_kp1;

        duration = duration + toc(step_tic);
        if options.debug, Tracking.obj(end+1) = options.fFn(x_k); end;
        if options.debug, Tracking.normG(end+1) = norm(g, 2)^2; end;
        if options.debug, Tracking.time(end+1) = duration; end;
        if options.debug, Tracking.dis(end+1) = norm(x_k - ...
                options.groundTruth)^2; end;
    end
    Tracking.itersNo = i;
    Tracking.stoppingCriteria = stoppingCriteria;

end
