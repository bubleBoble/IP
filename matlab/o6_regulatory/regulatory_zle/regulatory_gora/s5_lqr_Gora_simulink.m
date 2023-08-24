%=======================================================================%
%   Stabilizacja wahadła w górnym położeniu
%   LQR
%=======================================================================%
clc
clear
%=======================================================================%
%   System
%=======================================================================%
n=2; % 1-LD, 2-LG, 3-SD, 4-SG
[A, B, H] = macierze_mdl_liniowy(n); 
D=0;
C = eye(4);
E = [1, 0, 0, 0]; % x_w do zmiennej całkowej
% sys = ss(A, B, C, D);
%=======================================================================%
%   Ustawienia
%=======================================================================%
dt = 0.001;
end_time = 6;
ampD = 0;
track_len = 0.47;
xw0 = 0.12;
the0deg = 5;
Dthe0deg = 0;
animacjaON=0
save_anim=0
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
Q = diag( [9000e3, 2000e3, 0.1e3, 30e2] );
R = 0.2;
% -----------------LQR2--------------------
% Q = diag( [1e3, 10e3, 15e3, 0.1e3] );
% R = 0.1;
% -----------------LQR3--------------------
% Q = diag( [900e3, 0.001e3, 0.1e3, 60e3] );
% R = 0.1;
K = lqr(A, B, Q, R)
% fprintf('K = \n%d \n%d \n%d \n%d\n', K);
%=======================================================================%
%   Symulacja
%=======================================================================%
t = 0:dt:end_time;
xw_ref_sim.time = t;
xw_ref_sim.signals.values(:, 1) = utils.ustep(t, 3)*0.1;
xw_ref_sim.signals.dimensions = 1;
d_sim.time = t;
d_sim.signals.values(:, 1) = (utils.ustep(t, 3)-utils.ustep(t, 3.1)) .* ampD;
d_sim.signals.dimensions = 1;

IC = [
    xw0;
    the0deg*pi/180;
    0;
    Dthe0deg*pi/180
];
% IC_lin = [track_len/2; pi; 0; 0] - IC;
run('model_params.m')
params_lepkie = [M, mc, mp, Lp, Lc, g, b_lepkie, gamma_, mr, Mt, L, Jcm, Jt, alpha_, beta_];
params_stribeck = [M, mc, mp, Lp, Lc, g, b_stribeck, gamma_, mr, Mt, L, Jcm, Jt, alpha_, beta_, miu_c, miu_s, vs, i_, delta];

simout = sim('s5_MDL_Tlepkie_lqr_gora.slx');
x       = simout.state_out;
t       = simout.tout;
u       = simout.u;
d       = simout.d;
%=======================================================================%
%   ploty
%=======================================================================%
figure(1); 
subplot(321); 
plot(t, x(:, 1)); grid on; title('x_w');

subplot(322);
plot(t, x(:, 2)); grid on; title('\theta');

subplot(323);
plot(t, x(:, 3)); grid on; title('Dx_w');

subplot(324);
plot(t, x(:, 4)); grid on; title('D\theta');

subplot(325);
plot(t, u); grid on; title('sterowanie');

subplot(326);
plot(t, d); grid on; title('zakłócenie');
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%   Animacja
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
if animacjaON
    x(:, 2) = x(:, 2) * pi/180; 
    x(:, 4) = x(:, 4) * pi/180; 
    utils.animate(IC, Lc, dt, x(:, 1), x(:, 2), t, save_anim, "sterowane");
end





