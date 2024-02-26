function [out, logging] = constrained_partan(f_fn, f_grad_fn, b_fn, b_grad_fn, init_point, coef_fn, options) 
%UNTITLED2 Summary of this function goes here
%   coef_fn: function of c, which is a coefficient to b_fn. It is either coef_fn = @(c) c; or coef_fn = @(c) 1/c
%   Output: out, logging
%   - logging:
%       t_criteria
%       t_f
%       t_P
%       t_e

    q_fn = @(c, x) f_fn(x) + coef_fn(c)*b_fn(x);
    q_grad_fn = @(c, x) f_grad_fn(x) + coef_fn(c)*b_grad_fn(x);

    %% Init 
    if ~isfield(options, 'tau')
        tau = 10^-6;
    else
        tau = options.tau
    end
    if ~isfield(options, 'max_iters')
        max_iters = 100;
    else
        max_iters = options.max_iters;
    end
    if ~isfield(options, 'debug')
        options.debug = false;
    end
    if ~isfield(options, 'logging_interval')
        options.logging_interval = 10;
    end
    if ~isfield(options, 'ground_truth')
        options.ground_truth = nan(size(init_point));
    end
    if ~isfield(options, 'beta')
        options.beta = 1.1;
    end

    x = init_point;
    c = 1; beta = options.beta;

    %% Tracking
    t_criteria = 1000*zeros(max_iters, 1);
    t_f = 1000*zeros(max_iters, 1);
    t_P = 1000*zeros(max_iters, 1);
    t_e = 1000*zeros(max_iters, 1);
    debug = 1;

    %% Main loop
    iter = 1;
    criteria = coef_fn(c)*b_fn(x);
    q_x_fn = @(x) q_fn(c, x);
    q_x_grad_fn = @(x) q_grad_fn(c, x);
    while iter < max_iters && abs(criteria) > tau
        q_x_fn = @(x) q_fn(c,x);
        q_x_grad_fn = @(x) q_grad_fn(c, x);
        
        partan_options.ground_truth = zeros(size(x));
        partan_options.max_iters = 50;
        partan_options.debug = true;
        [x, partan_logging] = partan(q_x_fn, q_x_grad_fn, x, partan_options);
        criteria = coef_fn(c)*b_fn(x);
        if (mod(iter, options.logging_interval) == 0) && debug==1
            if options.debug
                fprintf('Step %d - Norm: %f - criteria: %f - f(x): %f - b_fn(x): %f - c: %d - partan#iter: %d \n', iter, partan_logging.t_grad_norm(end), criteria, f_fn(x), b_fn(x), c, length(partan_logging.t_grad_norm)); 
            end
        end
        c = c*beta;
        
        % Tracking
        t_criteria(iter) = criteria;
        t_f(iter) = f_fn(x);
        t_P(iter) = b_fn(x);
        t_e(iter) = norm(x-options.ground_truth, 'fro');

        iter = iter+1;
    end
    if options.debug
        fprintf('constrained_partan: All done\n');
    end
    logging = struct();
    logging.t_criteria = t_criteria(1:iter-1);
    logging.t_f = t_f(1:iter-1);
    logging.t_P = t_P(1:iter-1);
    logging.t_e = t_e(1:iter-1);
    out = x;
end

