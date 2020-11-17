%% init
clear; clc; %close all;
addpath(genpath([fileparts(matlab.desktop.editor.getActiveFilename),'\..']))

%% create test function
syms x y z
pol_x = poly2sym(1:4,x);
pol_y = poly2sym(1:4,y);
pol_z = poly2sym(1:4,z);

fun = pol_x*pol_y;
fun = expand(fun);

%% horner factorisation (Ceberio2004)
var = symvar(fun);
nVar = length(var);

coef = horner(coeffs(fun,var(1),'All'));
funH = combineHorner(coef,var(1));

fun
funH

function funH = combineHorner(coef,var)
% coef = coefficient vector highest to lowest
% var = symbolic variable

nCoef = length(coef); % # coeff

funH = sym('0');
for i = 1:nCoef-1
    funH = var(1)*(coef(i)+funH);
end
funH = coef(nVar) + funH;
end