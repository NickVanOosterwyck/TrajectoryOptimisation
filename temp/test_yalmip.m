sdpvar x y
F = [x^3+y^5 <= 5, y >= 0];
options = sdpsettings('verbose',1,'solver','bmibnb');
optimize(F,-x,options)