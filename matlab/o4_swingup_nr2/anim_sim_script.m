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
delta_thetaIC = 170;
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
%   Parametry modelu liniowego - dolne położenie
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
den = Jt*Mt-(L*mr)^2;
a1 = -(L^2)*g*(mr^2)/den;
a2 = -Jt*(b_lepkie+beta)/den;
a3 = -L*gamma*mr/den;
a4 = -L*Mt*g*mr/den;
a5 = -L*mr*(b_lepkie+beta)/den;
a6 = -Mt*gamma/den;
b1 = Jt*alpha/den;
b2 = L*mr*alpha/den;
h1 = (-Jt+L*Lc*mr)/den;
h2 = (Lc*Mt - L*mr)/den;
A = [
    0  0  1  0;
    0  0  0  1; 
    0  a1 a2 a3;
    0  a4 a5 a6;
];
B = [0;0;b1;b2];
H = [0;0;h1;h2];
    
%% ==============================================================
C = zeros(4);
C(2, 2) = 1;
sys = ss(A, B, C, zeros(4, 1));

% z bodea
% peak rezonansowy liniowego w omega=7.23 rad/sec 
s = tf('s');
Td = 1;
a1 = 0.5; 
lead = (Td*s + 1) / (a1*Td*s + 1); 
Ti = 0.01;
a2 = 2; 
lag  = a2*(Ti*s + 1) / (a2*Ti*s + 1); 
H = series(lead, lag);
bode(H)
% ==============================================================
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%   Symulacja
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
dt = 0.001;
time = 0:dt:end_time;

simout = sim('MDL_liniowy_nieliniowy.slx');

states  = simout.state_out.';
t    = simout.tout.';
u       = simout.u.';
x       = states(1, :);
the     = states(2, :);
dx      = states(3, :);
dthe    = states(4, :);

states   = simout.lin_state_out.';
xl       = states(1, :);
thel     = states(2, :);
dxl      = states(3, :);
dthel    = states(4, :);
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
%% porownanie liniony / nie liniowy
figure(2);

subplot(321)
plot(t, x); hold on
plot(t, xl); hold off
ylabel('x')
title('Single Pendulum Swing-Up');
grid
legend('nieliniowy', 'liniowy')


subplot(322)
plot(t, the*180./pi, t, thel*180./pi + 180)
ylabel('the')
grid

subplot(323)
plot(t, dx, t, dxl)
ylabel('dx')
grid

subplot(324)
plot(t, dthe*180./pi, t, dthel*180./pi)
ylabel('dthe')
grid

subplot(325)
plot(t, u)
ylabel('u')
grid

%% nieliniowy lead lag
figure(2);

subplot(321)
plot(t, x); hold on
plot(t, xl); hold off
ylabel('x')
title('Single Pendulum Swing-Up');
grid
legend('nieliniowy', 'liniowy')


subplot(322)
plot(t, the*180./pi, t, thel*180./pi + 180)
ylabel('the')
grid

subplot(323)
plot(t, dx, t, dxl)
ylabel('dx')
grid

subplot(324)
plot(t, dthe*180./pi, t, dthel*180./pi)
ylabel('dthe')
grid

subplot(325)
plot(t, u)
ylabel('u')
grid
