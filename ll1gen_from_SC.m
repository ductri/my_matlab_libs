function [out] = ll1gen_from_SC(S, C) 
    if length(S) ~= size(C, 2)
        error('S and C must have the same length');
    end
    [I, J] = size(S{1});
    [K, R] = size(C);

    out = zeros(I, J, K);
    for k=1:K
        for r=1:R
            out(:,:,k) = S{r}*C(k,r) + out(:,:,k);
        end
    end 
end
