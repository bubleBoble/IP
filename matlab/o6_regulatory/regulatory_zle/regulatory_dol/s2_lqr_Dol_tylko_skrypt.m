%%
clc

%%
n=1; % 1-LD, 2-LG, 3-SD, 4-SG
[A, B, H] = macierze_mdl_liniowy(n); 
D=0;
C = eye(4);
sys = ss(A, B, C, D);

%% LQR, stan = [x the Dx Dthe]
% max x     = 0.2;
% max the   = 2pi;
% max Dx
% max Dthe
% max u     = 12;
Q = [
    55, 0, 0, 0;
    0, 60, 0, 0;
    0, 0, 0, 0;
    0, 0, 0, 0;
];
R = 5;
K = lqr(A, B, Q, R);
fprintf('K = \n%d \n%d \n%d \n%d\n', K);

%%
sys_cl = feedback(sys, K);

%%
t = 0:0.005:4;

r_sim.time = time;
r_sim.signals.values(:, 1) = utils.input_func_1(time);    % wymuszeznie dla obliczonej optymalnej trajektorii
r_sim.signals.dimensions = 1;
d_sim = v_sim;
% d_sim.signals.values(:, 1) = zeros(size(v_sim.signals.values(:, 1)));

the0deg = 15;
Dthe0deg = 15;
x0 = [
    0,
    the0deg*pi/180,
    0,
    Dthe0deg*pi/180
];
[y, tout, x] = lsim(sys_cl, r, t, x0);
[ys, touts, xs] = lsim(sys, r, t, x0);

x(:, 2) = x(:, 2)*180/pi;
xs(:, 2) = xs(:, 2)*180/pi;

%%
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
plot(t, r-K*x'); grid on; hold on;
yline(12); yline(-12); hold off;
title('sterowanie');







