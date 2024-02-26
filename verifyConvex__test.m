%% Clear all things
clc; clear; close all; path(pathdef);

fFun = @(x) norm(x - 10)^2;

x0 = rand(10, 1);
v = rand(size(x0));
t1 = -1000; t2 = 1000;

[~] = verifyConvex(x0, v, t1, t2, fFun)


fFun = @(x) 1/norm(x - 10);

x0 = rand(10, 1);
v = rand(size(x0));
t1 = -10; t2 = 100;

[~] = verifyConvex(x0, v, t1, t2, fFun)


fFun = @(X) norm(X - 10, 'fro');

X0 = rand(10, 12);
V = rand(size(X0));
t1 = -1000; t2 = 1000;

[~] = verifyConvex(X0, V, t1, t2, fFun)
