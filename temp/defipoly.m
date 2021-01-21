function P = defipoly(poly,indets,silent)
% The instruction
%
%   P = DEFIPOLY(POLY,INDETS)
%
% converts a cell array of character strings (polynomial objectives,
% inequality or equality constraints) into a cell array of polynomial
% constraint coefficients for use with GLOPTIPOLY
%
% A comma-separated string of polynomial indeterminates must be specified
% as a second input argument. It establishes the correspondance between
% polynomial variables and indices in the coefficient matrices.
%
% For example, P = DEFIPOLY({'min 3+2*x*y+x^2', 'x>=0'}, 'x,y')
% returns a structure P with fields
% P{1}.c = [3 0;0 2;1 0], P{1}.t = 'min',
% P{2}.c = [0;1] and P{2}.t = '>='
%
% If the number of elements in the coefficient matrix P.c is less
% than 100, then P.c is a standard n-D full matrix and P.s is an
% empty field. Otherwise, P.c is converted to a sparse vector and
% P.s is the vector of dimensions of P.c, as returned by size(P.c)
% if P.c were not sparse.
%
% If a non-empty third input argument is specified,
% then the screen output is turned off
%  
% The Symbolic Math Toolbox 2.1 (Maple kernel) must be installed
  
% Written by D. Henrion and C. P. Jeannerod, December 7, 2001
% Last modified by D. Henrion, May 9, 2006
  
if nargin < 2,
 error('Indeterminates must be specified');
end;

if nargin < 3,
 silent = [];
end;

P = [];

if isa(poly,'cell'),
 for k = 1:length(poly),
   P{k} = defipoly(poly{k},indets,silent);
 end;
 return;
end;

silent = ~isempty(silent);

% Valid character strings ?
if ~isa(poly,'char') | (size(poly, 1) ~= 1),
  error('First input argument is not a valid character string.');
elseif ~isa(indets,'char') | (size(indets, 1) ~= 1),
  error('Second input argument is not a valid character string.');
end;

% Objective function
ind = [findstr(poly, 'min') findstr(poly, 'Min') findstr(poly, 'MIN')];
if ~isempty(ind),
 if length(ind) > 1,
  error(['Invalid objective function:' poly]);
 else
  if ~silent, disp(['Objective function to minimize: ' poly]); end;
  P.c = []; P.t = 'min';
  [P.c,sizeP] = coefpoly([poly(1:ind-1) poly(ind+3:end)],indets);
 end;
end;

ind = [findstr(poly, 'max') findstr(poly, 'Max') findstr(poly, 'MAX')];
if ~isempty(ind),
 if ~isempty(P),
  error(['Invalid objective function: ' poly]);   
 end;
 if length(ind) > 1,
  error(['Invalid objective function: ' poly]);
 end;
 if ~silent, disp(['Objective function to maximize: ' poly]); end;
 P.c = []; P.t = 'max';
 [P.c,sizeP] = coefpoly([poly(1:ind-1) poly(ind+3:end)],indets);
end;

% Inequality
ind = [findstr(poly, '>=') findstr(poly, '=>')];
if ~isempty(ind),
 if ~isempty(P),
  error(['Invalid inequality: ' poly]);   
 end;
 if length(ind) > 1,
  error(['Invalid inequality: ' poly]);
 end;
 if ~silent, disp(['Positive inequality: ' poly]); end;
 P.c = []; P.t = '>=';
 [P.c,sizeP] = coefpoly([poly(1:ind-1) '-(' poly(ind+2:end) ')'],indets);
end;

ind = [findstr(poly, '<=') findstr(poly, '=<')];
if ~isempty(ind),
 if ~isempty(P),
  error(['Invalid inequality: ' poly]);   
 end;
 if length(ind) > 1,
  error(['Invalid inequality: ' poly]);
 end;
 if ~silent, disp(['Negative inequality: ' poly]); end;
 P.c = []; P.t = '<=';
 [P.c,sizeP] = coefpoly([poly(1:ind-1) '-(' poly(ind+2:end) ')'],indets);
end;

% Equality
ind = findstr(poly, '==');
if ~isempty(ind),
 if ~isempty(P),
  error(['Invalid equality: ' poly]);   
 end;
 if length(ind) > 1,
  error(['Invalid equality: ' poly]);
 end;
 if ~silent, disp(['Equality: ' poly]); end;
 P.c = []; P.t = '==';
 [P.c,sizeP] = coefpoly([poly(1:ind-1) '-(' poly(ind+2:end) ')'],indets);
end;

if isempty(P),
 disp('An operator (min, max, >=, <=, ==) is missing');
 error(['Invalid expression: ' poly]);
end;

if ~isempty(sizeP), % sparse matrix
 P.s = sizeP;
end;

function [P,sizeP] = coefpoly(poly,indets)
% The instruction
%
%    [P,SIZEP] = COEFPOLY(POLY)
%
% converts a symbolic polynomial POLY to its coefficient matrix P
% with the Symbolic Toolbox Maple kernel
%
% For example COEFPOLY('x^2+2*x*y*z-3') returns a 3-D matrix with
% entries (1,1,1)=-3, (2,2,2)=2 and (3,1,1)=1
%
% If the number of elements in P (product of dimensions) is less
% than 100, then P is a standard n-D full matrix and SIZEP is an
% empty vector. Otherwise, P is converted to a sparse vector and
% SIZEP is the vector of dimensions of P, as returned by size(P) if
% P were not sparse.
%
% An optional input argument can specify the ordering of the indeterminates,
% hence the ordering of the indices in the coefficient matrix, as in
% COEFPOLY('x^2+2*x*y*z-3','x,z,y')

if exist('maple') ~= 2,
 error('Matlab Symbolic Math Toolbox is not properly installed');
end;
%maple('restart');
%clear maplemex

% Expand and declare the polynomial to Maple
[result,status] = maple(['poly := expand(' poly ');']);
if strcmp(result,'FAIL') | status,
  error(['Unable to evaluate polynomial: ' poly]);
end;

if nargin == 1,
 indets = [];
end;

if isempty(indets),
 % Extract and order indeterminates
 [result,status] = ...
     maple('indet := sort(convert(indets(poly),list),lexorder);');
 if strcmp(result,'FAIL') | status,
  error('Unable to extract polynomial indeterminates');
 end;
else
 % Declare ordered indeterminates to Maple
 [result,status] = maple(['indet := [' indets '];']);
 if strcmp(result,'FAIL') | status,
   error(['Unable to evaluate indeterminates: ' indets]);
 end;
end;

% Number of indeterminates
nbindet = eval(maple('nops(indet);'));

% List of degrees in each indeterminate
deg = cell(1,nbindet);
sizeP = zeros(1,nbindet);
for k = 1:nbindet,
 [result,status] = maple(['degree(poly,indet[' int2str(k) ']);']);
 if strcmp(result,'FAIL') | status,
  error(['Unable to evaluate polynomial: ' poly]);
 end;
 degmon = eval(result);
 if isinf(degmon), % if the polynomial is zero
  degmon = 0;
 end;
 sizeP(k) = degmon+1;
 deg{k} = sizeP(k);
end;
if length(sizeP) == 1
 sizeP = [sizeP 1];
end

% More than 100 elements, create sparse coefficient matrix
if prod(sizeP) > 100,
 if prod(sizeP) > 2^31-2,
  disp('Matlab maximum index exceeded');
  error('Polynomial coefficient cannot be represented');
 end;
 P = sparse(prod(sizeP),1);
else % otherwise, standard n-D matrix
 % Coefficient array
 if nbindet == 1,
  P = zeros(deg{1},1); % vector
 else
  P = zeros(deg{:}); % or matrix
 end;
 sizeP = []; % not sparse
end;

% List of monomials
[result, status] = maple('mono := [op(poly)];');
nbmono = eval(maple('nops(mono);'));

% Filter strange Maple behaviors:
% op(-x) returns -1,x instead of -x
% op(2*x^2) returns 2,x^2 instead of 2*x^2
% op(x^2) returns x,2 instead of x^2
ldeg = eval(maple('ldegree(poly);'));
ldegm = +Inf;
for k = 1:nbmono,
 ldegm = min(ldegm, eval(maple(['ldegree(mono[' int2str(k) ']);'])));
end;
if (ldegm ~= ldeg),
 maple('mono := [poly];');
 nbmono = 1;
end;

% For each non-constant monomial, extract the corresponding indices
% in the coefficient matrix and extract the coefficient
for i = 1:nbmono,
 index = cell(1,nbindet);
 for j = 1:nbindet,
  degmon = ...
      eval(maple(['degree(mono[' int2str(i) '],indet[' int2str(j) ']);']))+1;
  if isinf(degmon), % filter zero polynomial
   degmon = 1;
  end;
  index{j} = degmon;
 end;
 coef = eval(maple(['coeffs(mono[' int2str(i) ']);']));
 if isempty(sizeP), % non-sparse
  P(index{:}) = P(index{:}) + coef;
 else % sparse
  P(sub2ind(sizeP,index{:})) = P(sub2ind(sizeP,index{:})) + coef;
 end;
end;

