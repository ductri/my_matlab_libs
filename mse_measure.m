function [MSE, order]= mse_measure(A_est,A_true)
% =====================================
% Input:
% A_est is the estimation of mixing matrix
% A_true is the true mixing matrix
% Output:
% A_est_order is the reordered (in column-wise manner) A_est 
% MSE is mean sqaure error between A_est_order and A_true
%======================================
    fprintf('WARNING: DONT USE IT FOR NOW, use mse_measure_norm!!!! \n\n');
    [m,k] = size(A_true);
    L = zeros(k, k);
    for i=1:k
        for j=1:k
           L(i, j) = norm(A_est(:, i) - A_true(:, j), 'fro').^2;
        end
    end

    M = matchpairs(L, 100000000);
    ind = sub2ind([k, k], M(:, 1), M(:, 2));
    MSE = sum(L(ind));
    order = M(:, 1);
end

