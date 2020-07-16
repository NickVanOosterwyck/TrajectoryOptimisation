%% init
clear; clc; close all;
addpath(genpath([fileparts(matlab.desktop.editor.getActiveFilename),'\..\..']))

%% forward
%% trapF (1/3)
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'trap';
input.timeA = 0;
input.timeB = 0.0738;
input.posA = 0;
input.posB = 3.0299;

% optional
input.d_J = 4;
input.d_Tl = 5;

trapF = TrajOpt(input);
trapF.optimizeTrajectory();

%% poly5F (reference)
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'poly5';
input.timeA = 0;
input.timeB = 0.07375;
input.posA = 0;
input.posB = 3.0299;

% optional
input.d_J = 4;
input.d_Tl = 5;

poly5F = TrajOpt(input);
poly5F.optimizeTrajectory();

%% cheb7F
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'cheb';
input.timeA = 0;
input.timeB = 0.07375;
input.posA = 0;
input.posB = 3.0299;
input.DOF = 2;
input.sSolver = 'quasi-newton';

% optional
input.d_J = 4;
input.d_Tl = 5;
input.isTimeResc = true;
input.isPosResc = true;

cheb7F = TrajOpt(input);
cheb7F.optimizeTrajectory();

%% cheb9F
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'cheb';
input.timeA = 0;
input.timeB = 0.07375;
input.posA = 0;
input.posB = 3.0299;
input.DOF = 4;
input.sSolver = 'quasi-newton';

% optional
input.d_J = 4;
input.d_Tl = 5;
input.isTimeResc = true;
input.isPosResc = true;

cheb9F = TrajOpt(input);
cheb9F.optimizeTrajectory();

%% cheb13F
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'cheb';
input.timeA = 0;
input.timeB = 0.07375;
input.posA = 0;
input.posB = 3.0299;
input.DOF = 8;
input.sSolver = 'quasi-newton';

% optional
input.d_J = 4;
input.d_Tl = 5;
input.isTimeResc = true;
input.isPosResc = true;

cheb13F = TrajOpt(input);
cheb13F.optimizeTrajectory();

%% backward
%% trapB (1/3)
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'trap';
input.timeA = 0.1675;
input.timeB = 0.2250;
input.posA = 3.0299;
input.posB = 0;

% optional
input.d_J = 4;
input.d_Tl = 5;

trapB = TrajOpt(input);
trapB.optimizeTrajectory();

%% poly5B (reference)
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'poly5';
input.timeA = 0.1675;
input.timeB = 0.2250;
input.posA = 3.0299;
input.posB = 0;

% optional
input.d_J = 4;
input.d_Tl = 5;

poly5B = TrajOpt(input);
poly5B.optimizeTrajectory();

%% cheb7B
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'cheb';
input.timeA = 0.1675;
input.timeB = 0.2250;
input.posA = 3.0299;
input.posB = 0;
input.DOF = 2;
input.sSolver = 'quasi-newton';

% optional
input.d_J = 4;
input.d_Tl = 5;
input.isTimeResc = true;
input.isPosResc = true;

cheb7B = TrajOpt(input);
cheb7B.optimizeTrajectory();

%% cheb9B
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'cheb';
input.timeA = 0.1675;
input.timeB = 0.2250;
input.posA = 3.0299;
input.posB = 0;
input.DOF = 4;
input.sSolver = 'quasi-newton';

% optional
input.d_J = 4;
input.d_Tl = 5;
input.isTimeResc = true;
input.isPosResc = true;

cheb9B = TrajOpt(input);
cheb9B.optimizeTrajectory();

%% cheb13B
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'cheb';
input.timeA = 0.1675;
input.timeB = 0.2250;
input.posA = 3.0299;
input.posB = 0;
input.DOF = 8;
input.sSolver = 'quasi-newton';

% optional
input.d_J = 4;
input.d_Tl = 5;
input.isTimeResc = true;
input.isPosResc = true;

cheb13B = TrajOpt(input);
cheb13B.optimizeTrajectory();

%% combine symbolically
pauseA.q = 3.0299;
pauseA.breaks = [0.07375 0.1675];
pauseB.q = 0;
pauseB.breaks = [0.2250 0.3];

trap = combineSolutions('sym',trapF,pauseA,trapB,pauseB);
poly5 = combineSolutions('sym',poly5F,pauseA,poly5B,pauseB);
cheb7 = combineSolutions('sym',cheb7F,pauseA,cheb7B,pauseB);
cheb9 = combineSolutions('sym',cheb9F,pauseA,cheb9B,pauseB);
cheb13 = combineSolutions('sym',cheb13,pauseA,cheb13B,pauseB);

%% combine discrete
pauseA.q = 3.0299;
pauseA.breaks = [0.07375 0.1675];
pauseA.ts = 0.0025;
pauseB.q = 0;
pauseB.breaks = [0.2250 0.3];
pauseB.ts = 0.0025;

trap = combineSolutions('dis',trapF,pauseA,trapB,pauseB);
poly5 = combineSolutions('dis',poly5F,pauseA,poly5B,pauseB);
cheb7 = combineSolutions('dis',cheb7F,pauseA,cheb7B,pauseB);
cheb9 = combineSolutions('dis',cheb9F,pauseA,cheb9B,pauseB);
cheb13 = combineSolutions('dis',cheb13,pauseA,cheb13B,pauseB);

%% write discrete
writematrix(trap.t.','OptimisedTrajectoriesDiscrete.xlsx','Range','A3')
writematrix(trap.q.','OptimisedTrajectoriesDiscrete.xlsx','Range','B3')
writematrix(trap.Tm.','OptimisedTrajectoriesDiscrete.xlsx','Range','C3')
writematrix(poly5.q.','OptimisedTrajectoriesDiscrete.xlsx','Range','D3')
writematrix(poly5.Tm.','OptimisedTrajectoriesDiscrete.xlsx','Range','E3')
writematrix(cheb7.q.','OptimisedTrajectoriesDiscrete.xlsx','Range','F3')
writematrix(cheb7.Tm.','OptimisedTrajectoriesDiscrete.xlsx','Range','G3')
writematrix(cheb9.q.','OptimisedTrajectoriesDiscrete.xlsx','Range','H3')
writematrix(cheb9.Tm.','OptimisedTrajectoriesDiscrete.xlsx','Range','I3')

%% plot symbolically
fig = TrajPlot(input);
fig.addPlot(trap,'trap');
fig.addPlot(poly5,'poly5');
fig.addPlot(cheb7,'cheb7');
fig.addPlot(cheb9,'cheb9');
fig.addPlot(cheb13F,'cheb13F');
%fig.removeWhitespace();


