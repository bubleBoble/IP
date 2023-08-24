%=======================================================================%
%   Stabilizacja wahadła w górnym położeniu
%   LQI, śledzenie zmiennej pozycji zadanej wózka
%=======================================================================%
clc
clear
clf
% change_simulink_stupid_cache_directory
% utils.change_text_interpreter_to_latex
%=======================================================================%
%   Macierze
%=======================================================================%
n=2; % 1-LD, 2-LG, 3-SD, 4-SG
[A, B, H] = utils.macierze_mdl_liniowy(n); 
D=0;
% C = eye(4);
% sys = ss(A, B, C, D);
%=======================================================================%
%   Ustawienia
%=======================================================================%
dt          = 0.001;        % próbkowanie do symulacji i sygnałów 
track_len   = 0.47;         % długość suwnicy
the0deg     = 5;            % początkowa wartość kąta wychylenia wahadła
Dthe0deg    = 0;            % początkowa wartość pr. kątowej wahadła
end_time    = 6;            % końcowy czas symulacji
ampD        = 0.02;         % mnożnik zakłóceń
sat         = [12, -12];    % saturacja sygnału sterującego
animacjaON  = 0             % animacja on/off
save_anim   = 0             % zapisanie animacji on/off
%%
%=======================================================================%
%   Macierze do systemu rozszerzonego o stan całkowy  
%   stan = [x_w the Dx Dthe int(x_w-x)]
%   Dxa = Aa*xa + Ba*u + G*c_ref
%=======================================================================%
E = [1 0 0 0]; % wyj. sterowane = x_wózka
Aa = [A, zeros(4,1); E, 0];
Ba = [B;0];
G  = [zeros(4,1); -1];

%=======================================================================%
%   LQR 0
%=======================================================================%
Q = diag( [400e3, 0, 200, 0, 6e6] );
R = 200;
Fa=lqr(Aa, Ba, Q, R);
%%
%=======================================================================%
%   Symulacja
%=======================================================================%
t = 0:dt:end_time;
xw_ref_sim.time = t;
% bardziej zmienna
% xw_ref_sim.signals.values(:, 1) = ( ...
%     utils.ustep(t, 0)*track_len/2 + ...
%     utils.ustep(t, 1)*(0.35 - track_len/2) - ...
%     utils.ustep(t, 3)*(0.25) ) .* 1 + ...
%     utils.ustep(t, 4.5)*(track_len/2 - 0.1);

% mniej zmienna - użyłem do podania zakłócenia
xw_ref_sim.signals.values(:, 1) = ( ...
    utils.ustep(t, 0)*track_len/2 + ...
    utils.ustep(t, 1)*(0.35 - track_len/2) );

xw_ref_sim.signals.dimensions = 1;
d_sim.time = t;
d_sim.signals.values(:, 1) = (utils.ustep(t, 2.5)-utils.ustep(t, 4.6)) * ampD;
d_sim.signals.dimensions = 1;

IC = [
    track_len/2;
    the0deg*pi/180;
    0;
    Dthe0deg*pi/180];
run('utils.model_params.m')
params_lepkie = [M, mc, mp, Lp, Lc, g, b_lepkie, gamma_, mr, Mt, L, Jcm, Jt, alpha_, beta_];
simout = sim('s2_model_LQI_gora.slx');
x       = simout.state_out;
t       = simout.tout;
u       = simout.u;
d       = simout.d;
xi      = simout.int_state_out;
ew      = simout.ew;
%%
%=======================================================================%
%   ploty
%=======================================================================%
fig = figure(1); 

subplot(421); 
plot(t, x(:, 1), 'LineWidth', 2); grid on; hold on;
plot(t, xw_ref_sim.signals.values, '--', 'Color', 'red'); hold off;
ylim([0, track_len]);
legend('$$x_w$$', '$$x_{w, ref}$$')
title('$$x_w(t)$$, $$x_{w, ref}(t)$$', 'FontSize', 13);

subplot(422);
plot(t, x(:, 2)); grid on;
title('$$\theta(t)$$', 'FontSize', 13);

subplot(423);
plot(t, x(:, 3)); grid on;
title('$$\dot{x}_w(t)$$', 'FontSize', 13);

subplot(424);
plot(t, x(:, 4)); grid on;
% title('$\dot{\theta}$','interpreter','latex', 'FontSize', 11); 
title('$$\dot{\theta}(t)$$', 'FontSize', 13); 

subplot(425);
plot(t, xi); grid on;
title('$$x_I(t)$$', 'FontSize', 13); 

subplot(426);
plot(t, u); grid on;
title('$$u(t)$$', 'FontSize', 13);

subplot(427);
plot(t, d_sim.signals.values); grid on;
title('$$d(t)$$', 'FontSize', 13);
xlabel("t [sek]")

subplot(428);
plot(t, ew); grid on;
title('$$e_w(t)$$', 'FontSize', 13);
xlabel("t [sek]")

title_str_format = "Q = diag[%d %d %d %d %d]\nR = %d";
title_str = sprintf(title_str_format, [diag(Q); R]);
sgtitle(title_str);
%=======================================================================%
%   Animacja
%=======================================================================%
if animacjaON
    x(:, 2) = x(:, 2) * pi/180; 
    x(:, 4) = x(:, 4) * pi/180; 
    utils.animate(IC, Lc, dt, x(:, 1), x(:, 2), t, save_anim, "vid_new");
end





