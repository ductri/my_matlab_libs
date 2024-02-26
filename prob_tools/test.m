%% Clear all things
clc; clear; close all; path(pathdef);

x = dirichlet_rnd(ones(1, 3), 1000);
max(x(:))

scatter(x(1, :), x(2, :))

