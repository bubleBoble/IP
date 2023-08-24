%=======================================================================%
%   Stabilizacja wahadła w dolnym położeniu
%   LQR
%=======================================================================%

clc
clear
%=======================================================================%
%   System
%=======================================================================%
n=1; % 1-LD, 2-LG, 3-SD, 4-SG
[A, B, H] = macierze_mdl_liniowy(n); 
D=0;
C = eye(4);
sys = ss(A, B, C, D);
%=======================================================================%
%   Ustawienia
%=======================================================================%
dt = 0.001;
end_time = 4;
ampD = 1;
track_len = 0.47;
the0deg = 180;
Dthe0deg = 0;
animacjaON=1;
save_anim=1;
%=======================================================================%
%   LQR     stan = [x the Dx Dthe]
%=======================================================================%
% Q = [
%     20000, 0, 0, 0;
%     0, 10000, 0, 0;
%     0, 0, 3000, 0;
%     0, 0, 0, 0.001];
% R = 0.005;
%            xw     the    Dxw   Dthe
% -----------------LQR1--------------------
Q = diag( [6000e3, 2e3, 0.1e3, 120e2] );
R = 0.5;
% -----------------LQR2--------------------
% Q = diag( [1e3, 10e3, 15e3, 0.1e3] );
% R = 0.1;
% -----------------LQR3--------------------
% Q = diag( [900e3, 0.001e3, 0.1e3, 60e3] );
% R = 0.1;

K = lqr(A, B, Q, R);

% % PLACE
% % zcl = 0.69001; % analitycznie, dominujące bieguny
% zcl = 1.5;
% wncl = 4.649;
% p1 = -zcl*wncl + wncl*sqrt(1-zcl^2)*1j;
% p2 = -zcl*wncl - wncl*sqrt(1-zcl^2)*1j;
% p3 = -300;
% p4 = -330;
% K = place(A, B, [p1, p2, p3, p4]);
% fprintf('K = \n%d \n%d \n%d \n%d\n', K);
%=======================================================================%
%   Symulacja
%=======================================================================%
t = 0:dt:end_time;
r_sim.time = t;
r_sim.signals.values(:, 1) = zeros(size(t));
r_sim.signals.dimensions = 1;
d_sim.time = t;
d_sim.signals.values(:, 1) = (utils.ustep(t, 1)-utils.ustep(t, 1.1)) .* ampD;
d_sim.signals.dimensions = 1;

x0NL = [
    track_len/2;
    the0deg*pi/180;
    0;
    Dthe0deg*pi/180
];

x0L = [track_len/2; pi; 0; 0] - x0NL;
PP = [track_len/2; pi; 0; 0];

run('model_params.m')
params_lepkie = [M, mc, mp, Lp, Lc, g, b_lepkie, gamma_, mr, Mt, L, Jcm, Jt, alpha_, beta_];
params_stribeck = [M, mc, mp, Lp, Lc, g, b_stribeck, gamma_, mr, Mt, L, Jcm, Jt, alpha_, beta_, miu_c, miu_s, vs, i_, delta];

simout = sim('s3_MDL_Tlepkie_lqr_dol.slx');
x       = simout.state_out;
t       = simout.tout;
u       = simout.u;
d       = simout.d;
xs      = simout.state_out_s;
xs(:, 2) = xs(:, 2) * 180/pi; 
xs(:, 4) = xs(:, 4) * 180/pi; 
%=======================================================================%
%   ploty
%=======================================================================%
figure(1); 
subplot(321); 
plot(t, x(:, 1)); grid on; hold on;
plot(t, xs(:, 1)); yline(0.2); yline(-0.2); hold off;
title('x_w'); legend('sterowane', 'swobodne');

subplot(322);
plot(t, x(:, 2)); grid on; hold on;
plot(t, xs(:, 2)); hold off;
title('\theta'); legend('sterowane', 'swobodne');

subplot(323);
plot(t, x(:, 3)); grid on; hold on;
plot(t, xs(:, 3)); hold off;
title('Dx_w'); legend('sterowane', 'swobodne');

subplot(324);
plot(t, x(:, 4)); grid on; hold on
plot(t, xs(:, 4)); hold off;
title('D\theta'); legend('sterowane', 'swobodne');

subplot(325);
plot(t, u); grid on; hold on;
yline(12); yline(-12); hold off;
title('sterowanie');

subplot(326);
plot(t, d); grid on; hold on; hold off;
title('zakłócenie');
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%   Animacja
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
if animacjaON
    x(:, 2) = x(:, 2) * pi/180; 
    x(:, 4) = x(:, 4) * pi/180; 
    utils.animate(x0NL, Lc, dt, x(:, 1), x(:, 2), t, save_anim, "sterowane");
    xs(:, 2) = xs(:, 2) * pi/180; 
    xs(:, 4) = xs(:, 4) * pi/180; 
    utils.animate(x0NL, Lc, dt, xs(:, 1), xs(:, 2), t, save_anim, "swobodne");
end





