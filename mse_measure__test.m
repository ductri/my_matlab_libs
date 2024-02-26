clc; clear; close all;

W1 = rand(10, 5);
W2 = [rand(10, 1) W1(:, 1:4)];

[MSE, o] = mse_measure(W1, W2);

