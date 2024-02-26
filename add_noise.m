function [out] = add_noise(X, SNR) 

    normX_square = X(:)'*X(:);
    xichma2 = (1/prod(size(X))) * normX_square / 10^(SNR/10);
    out = X + normrnd(0, xichma2, size(X));
end
