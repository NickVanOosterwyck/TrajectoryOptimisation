%% init
clear; clc; close all;
addpath(genpath([fileparts(matlab.desktop.editor.getActiveFilename),'\..']))

%%
%https://math.stackexchange.com/questions/1884439/generating-a-family-of-monotonic-polynomials-on-x-in-1-1-given-some-condit
syms x
for i = 1:6
f(i,1) = (3*x-x^3)/2 + 3/8*(1-x^2)^2*x^(2*(i-1));
end

figure
hold on
for i = 1:6
fplot(f(i),[-1,1]);
end

fplot(f(1),[-1,1])