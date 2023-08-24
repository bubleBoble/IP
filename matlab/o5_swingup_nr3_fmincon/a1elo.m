%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%   OBLICZANIE OPTYM. TRAJEKTORII, SYMULACJA, ANIAMCJA
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
clc
clear
change_simulink_stupid_cache_directory;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%   Ustawienia
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
save_anim   = 0;
animateON   = 0;
track_len   = 0.47;
end_time    = 4;   % dla animacji

% zmieniam zeby porownac mdl lin z nielin
Uamp = 0;
delta_thetaIC = 0;
x_ic        = track_len/2;
theta_ic    = (180 - delta_thetaIC) * pi/180;
D_x_ic      = 0;
D_theta_ic  = 0;
IC = [x_ic, theta_ic, D_x_ic, D_theta_ic]';  
IClin = [x_ic, -delta_thetaIC*pi/180, 0, 0];

run('model_params.m')
params_lepkie = [M, mc, mp, Lp, Lc, g, b_lepkie, gamma, mr, Mt, L, Jcm, Jt, alpha, beta];
params_stribeck = [M, mc, mp, Lp, Lc, g, b_stribeck, gamma, mr, Mt, L, Jcm, Jt, alpha, beta, miu_c, miu_s, vs, i_, delta];

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% z bodea
% peak rezonansowy liniowego w omega=7.23 rad/sec 
%%
Kx = 7.5;
s = tf('s');
K = 2;
Td = 0.3;
a1 = 0.5; 
lead = (Td*s + 1) / (a1*Td*s + 1); 
Ti = 0.06;
a2 = 2; 
lag  = a2*(Ti*s + 1) / (a2*Ti*s + 1); 
H = series(lead, lag);
% bode(K*H)
% ==============================================================
%%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%   Symulacja
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
dt = 0.001;
time = 0:dt:end_time;

simout = sim('MDL_Tlepkie_opt.slx');

states  = simout.state_out.';
t    = simout.tout.';
u       = simout.u.';
x       = states(1, :);
the     = states(2, :);
dx      = states(3, :);
dthe    = states(4, :);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%   Animacja
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
if animateON
    utils.animate(IC, Lc, dt, x, the, t, save_anim)
    % utils.animate(IC, Lc, dt, xl, thel, t, save_anim)
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%   Ploty
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%% nieliniowy lead lag
figure(2);

subplot(321)
plot(t, x); hold on
ylabel('x')
title('Single Pendulum Swing-Up');
grid
legend('nieliniowy', 'liniowy')

subplot(322)
plot(t, the*180./pi)
ylabel('the')
grid

subplot(323)
plot(t, dx)
ylabel('dx')
grid

subplot(324)
plot(t, dthe*180./pi)
ylabel('dthe')
grid

subplot(325)
plot(t, u)
ylabel('u')
grid
