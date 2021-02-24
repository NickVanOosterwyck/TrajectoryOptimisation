%%
times = 0.09:0.01:0.12;
n = length(times);
gain = zeros(1,n);
for i = 1:n
%% settings
time = times(i);
speed = 1400;
startangle = 0;
endangle = 90;

%% cvel
clear input
% required
input.sMechanism = 'BallJuggler';
input.sTrajType = 'cvel';
input.timeA = 0;
input.timeB = time;
input.posA = startangle/180*pi;
input.posB = endangle/180*pi;
input.speedB = speed/180*pi;

% optional
input.d_J = 4;
input.d_Tl = 4;

cvel = TrajOpt(input);
cvel.optimizeTrajectory();

%% cheb7
clear input
% required
input.sMechanism = 'BallJuggler';
input.sTrajType = 'cheb';
input.timeA = 0;
input.timeB = time;
input.posA = startangle/180*pi;
input.posB = endangle/180*pi;
input.speedB = speed/180*pi;
input.DOF = 2;
input.sSolver = 'quasi-newton';

% optional
input.d_J = 4;
input.d_Tl = 4;
input.isTimeResc = true;
input.isPosResc = true;

cheb7 = TrajOpt(input);
cheb7.optimizeTrajectory();

%saving
gain(i) = (cvel.res.Trms-cheb7.res.Trms)/cvel.res.Trms*100;

end

figure
plot(times,gain)
xlabel('time [s]')
ylabel('savings [\%]')

%%

