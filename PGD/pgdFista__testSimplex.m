clc; clear; close all;
addpath('./../')
addpath('./../prox_ops/')

M = 100; L = 1000; N = 50;
S = dirichletRand(ones(N, 1), L);
A = rand(M, N);
X = A*S;
% Objective: min_S ||X - A*S||_F^2

fFn = @(S) norm(X - A*S, 'fro')^2;
gFn = @(S) 2*A'*(A*S - X);

xStar = S;
fStar = 0;

ops = struct;
ops.verbose = true;
ops.debug = true;
ops.fFn = fFn;
ops.ground_truth = xStar;
ops.maxIters = 1000;
pFn = @(X, l) projSimplexMatrix(X);
stepSize = 1/eigs(A'*A, 1)/2;
initPoint = randn(size(S));
[xHat, tracking] = pgdFista(gFn, pFn, stepSize, initPoint, ops);

figure();
semilogy(tracking.obj-fStar);

norm(xHat - xStar, 2)

