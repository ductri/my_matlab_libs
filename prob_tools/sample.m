function [out] = sample(cdf_fn, n, range_value, interval) 
% ----------------------------------------------------------------------
% 
% Simple inverse transform sampling

% Author: Tri Nguyen (nguyetr9@oregonstate.edu)

% ----------------------------------------------------------------------
    
    out = zeros(n, 1);
    for i=1:n
        for x=1:interval:range_value
            seed = rand();
            if cdf_fn(x) >= seed
                out(i) = x;
                break
            end
        end
    end
end

