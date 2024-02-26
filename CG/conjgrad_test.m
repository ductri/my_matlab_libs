%% Clear all things
clc; clear; close all; path(pathdef);

n = 6000;
m = 8000;
A = randn(n,m);
A = A * A';
b = randn(n,1);
tic, x = conjgrad(A,b); toc
norm(A*x-b)
