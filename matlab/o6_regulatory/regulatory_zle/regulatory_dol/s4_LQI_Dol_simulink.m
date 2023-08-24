%=======================================================================%
%   Stabilizacja wahadła w dolnym położeniu
%   LQI, śledzenie zmiennej pozycji wózka
%=======================================================================%

clc
clear
clf
%=======================================================================%
%   System
%=======================================================================%
n=1; % 1-LD, 2-LG, 3-SD, 4-SG
[A, B, H] = macierze_mdl_liniowy(n); 
D=0;
% C = eye(4);
% sys = ss(A, B, C, D);
%=======================================================================%
%   Ustawienia
%=======================================================================%
dt = 0.001;
track_len = 0.47;
the0deg = 180;
Dthe0deg = 0;
end_time = 24;
pos_com1 = 0.1;
pos_com2 = 1;
ampD = 0;
animacjaON=1
save_anim=0
%=======================================================================%
%   LQI     stan = [x the Dx Dthe int(p-x)]
%=======================================================================%
% -----------------LQI1--------------------
Aa = [A, zeros(4,1); 1, zeros(1,4)];
Ba = [B;0];
Di = [zeros(4,1); -1];

Q = diag( [0e3, 1e3, 0e3, 1.3e3, 1000e3] );
R = 0.007;
K=lqr(Aa, Ba, Q, R);

%=======================================================================%
%   Symulacja
%=======================================================================%
t = 0:dt:end_time;
% p_sim.time = t;
% p_sim.signals.values(:, 1) = ...
%     utils.ustep(t, 2).*pos_com1 - ...
%     utils.ustep(t, 6).*(pos_com1 - pos_com2) ;
p_sim.time = t;
p_sim.signals.values(:, 1) = ( ...
    utils.ustep(t, 2).*pos_com1 - ...
    utils.ustep(t, 8).*(pos_com1 - pos_com2) - ...
    utils.ustep(t, 12).*(1) ) .* 1;
p_sim.signals.dimensions = 1;
d_sim.time = t;
d_sim.signals.values(:, 1) = (utils.ustep(t, 1)-utils.ustep(t, 1.1)) .* ampD;
d_sim.signals.dimensions = 1;

x0NL = [
    track_len/2;
    the0deg*pi/180;
    0;
    Dthe0deg*pi/180];
x0L = [track_len/2; pi; 0; 0] - x0NL;
PP = [track_len/2; pi; 0; 0];
run('model_params.m')
params_lepkie = [M, mc, mp, Lp, Lc, g, b_lepkie, gamma_, mr, Mt, L, Jcm, Jt, alpha_, beta_];
params_stribeck = [M, mc, mp, Lp, Lc, g, b_stribeck, gamma_, mr, Mt, L, Jcm, Jt, alpha_, beta_, miu_c, miu_s, vs, i_, delta];

simout = sim('s4_MDL_Tlepkie_lqi_dol.slx');
x       = simout.state_out;
t       = simout.tout;
u       = simout.u;
d       = simout.d;
xs      = simout.state_out_s;
xi      = simout.int_state_out;
xs(:, 2) = xs(:, 2) * 180/pi; 
xs(:, 4) = xs(:, 4) * 180/pi; 
%=======================================================================%
%   ploty
%=======================================================================%
figure(1); 
subplot(421); 
plot(t, x(:, 1)); grid on; hold on;
% plot(t, xs(:, 1)); yline(0.2); yline(-0.2); hold off;
title('x_w'); 
% legend('sterowany', 'swobodne');

subplot(422);
plot(t, x(:, 2)); grid on; hold on;
% plot(t, xs(:, 2)); hold off;
title('\theta');
% legend('sterowany', 'swobodne');

subplot(423);
plot(t, x(:, 3)); grid on; hold on;
% plot(t, xs(:, 3)); hold off;
title('Dx_w'); 
% legend('sterowany', 'swobodne');

subplot(424);
plot(t, x(:, 4)); grid on; hold on
% plot(t, xs(:, 4)); hold off;
title('D\theta'); 
% legend('sterowany', 'swobodne');

subplot(425);
plot(t, xi); grid on;
title('zmienna całkowa'); 
% legend('sterowany');

subplot(427);
plot(t, p_sim.signals.values); grid on;
title('zadane przesunięcie wozka');

subplot(426);
plot(t, u); grid on; hold on;
yline(12); yline(-12); hold off;
title('sterowanie');

subplot(428);
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





