function [fun_horner] = hornerMulti(fun)
%HORNERMULTI Converts any polynomial function 'fun' to a nested 
%   mulitvariate horner representation 'fun_horner'. Note that in contrast
%   to univariate polynomials, several different versions of Horner's
%   scheme are possible for multivariate polynomials. This function applies
%   the Herner scheme recursively according to the ardor obtained with
%   'symvar'.
fun = expand(fun);
var = symvar(fun);
nVar=length(var);
for i = 1:nVar
    fun = horner(fun,var(nVar-i+1));
    fun_horner = fun;
end
end

