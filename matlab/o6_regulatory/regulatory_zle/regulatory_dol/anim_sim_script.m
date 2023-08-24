%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%   OBLICZANIE OPTYM. TRAJEKTORII, SYMULACJA, ANIAMCJA
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
clc
% clear
change_simulink_stupid_cache_directory;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%   Ustawienia
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
lepkie_1_stribeck_0 = 1;
save_anim   = 0;
animateON   = 0;
track_len   = 0.47;
plotOT      = 0;
end_time    = 4;   % dla animacji
duration    = 4;   % końcowy czas dla optymalizacji
maxU        = 15;  % ograniczenie napięcia na DCM  
MaxIter     = 1e2;

% stan x = [ x the dx dthe ]
x0low   = [track_len/2;pi;0;0];
x0upp   = x0low;
xflow   = [track_len/2-0.1; -0.1; 0; 0];
xfupp   = [track_len/2+0.1; 0.1; 0; 0];
% xlow    = [-2*track_len;-2*pi;-inf;-inf];
% xupp    = [2*track_len;2*pi;inf;inf];
xlow    = [0; -3*pi;-inf;-inf];
xupp    = [track_len; 3*pi;inf;inf];
ulow    = -maxU;
uupp    = maxU;
t0low   = 0;
t0upp   = 0;
tflow   = duration;
tfupp   = duration;

% method = 'trapezoid';
% method = 'hermiteSimpson';
method = 'rungeKutta';
% method = 'chebyshev';

% initial guess - linear functions
% time_guess = 0:0.01:duration;
% state_guess = ((xflow - x0low)/duration)*time_guess;
% control_guess = sin(2*pi*10*time_guess);
time_guess = [0,duration];
state_guess = [x0low, xflow];
control_guess = [0,0];

x_ic        = track_len/2;
theta_ic    = 2 * pi/180;
D_x_ic      = 0;
D_theta_ic  = 0;
IC = [x_ic, theta_ic, D_x_ic, D_theta_ic]';  

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%   Czas do symulacji, sygnały wejściowe
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
dt = 0.001;
time = 0:dt:end_time;

%%
% IP inputs
% run("optimal_trajectory_help.m");

%%
v_sim.time = time;
v_sim.signals.values(:, 1) = uOT_func(time);    % wymuszeznie dla obliczonej optymalnej trajektorii
v_sim.signals.dimensions = 1;
d_sim = v_sim;
d_sim.signals.values(:, 1) = zeros(size(v_sim.signals.values(:, 1)));

% % wyłączyłem bo to i tak się odpala w "optimal_trajectory.m"
% run('model_params.m')
% params_lepkie = [M, mc, mp, Lp, Lc, g, b_lepkie, gamma, mr, Mt, L, Jcm, Jt, alpha, beta];
% params_stribeck = [M, mc, mp, Lp, Lc, g, b_stribeck, gamma, mr, Mt, L, Jcm, Jt, alpha, beta, miu_c, miu_s, vs, i_, delta];

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%   Symulacja
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%%
if lepkie_1_stribeck_0
    simout = sim('MDL_Tlepkie_x.slx');
else
    simout = sim('MDL_Tstribeck.slx');
end

% można porównać z wynikami z OT
% tOT, xOT, theOT, dxOT, dtheOT, uOT

states  = simout.state_out.';
tout    = simout.tout.';
u       = simout.u.';
d       = simout.d.';

x       = states(1, :);
the     = states(2, :);
dx      = states(3, :);
dthe    = states(4, :);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%   Animacja
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%%
animateON=1;
if animateON
    utils.animate(IC, Lc, dt, x, the, tout, save_anim)
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%   Ploty
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%%
figure();

subplot(321)
plot(tOT, xOT, tout, x)
ylabel('x')
title('Single Pendulum Swing-Up');
grid

subplot(322)
plot(tOT, theOT*180./pi, tout, the*180./pi)
ylabel('the')
grid

subplot(323)
plot(tOT, dxOT, tout, dx)
ylabel('dx')
grid

subplot(324)
plot(tOT, dtheOT*180./pi, tout, dthe*180./pi)
ylabel('dthe')
grid

subplot(325)
plot(tOT, uOT, tout, u)
ylabel('u')
grid

disp('step size:')
disp(soln.info.stepsize)
disp('NLP time')
disp(soln.info.nlpTime)



