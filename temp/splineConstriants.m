clear; clc;

nPieces = 4;

syms x
% define symbolic variables
p0i= sym('p%d0',[1 nPieces]).';
symVar = sym('p%d%d',[nPieces 3]);
symVar = [p0i symVar];
% create position function
pol=x.^(0:3).';
q=symVar*pol;
% calculate derivatives
qd1 = diff(q,x);
qd2 = diff(qd1,x);

