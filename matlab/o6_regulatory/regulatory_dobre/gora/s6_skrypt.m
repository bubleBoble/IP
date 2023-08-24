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
%=======================================================================%
%   Ustawienia
%=======================================================================%
dt          = 0.001;        % próbkowanie do symulacji i sygnałów 
track_len   = 0.47;         % długość suwnicy
the0deg     = 0;            % początkowa wartość kąta wychylenia wahadła
Dthe0deg    = 0;            % początkowa wartość pr. kątowej wahadła
end_time    = 12;           % końcowy czas symulacji
ampD        = 0.00;         % mnożnik zakłóceń
sat         = [12, -12];    % saturacja sygnału sterującego
animacjaON  = 0             % animacja on/off
save_anim   = 0             % zapisanie animacji on/off
%%
%=======================================================================%
%   Macierze do systemu rozszerzonego
%   stan = [x_w the Dx Dthe u Du]
%   Dxau2 = Aau2*xau2 + Bau2*DDu
%=======================================================================%
E = [1 0 0 0];

Aau2 = [A, B, zeros(4,1), zeros(4,2)];
Aau2 = [Aau2; zeros(1,5), 1, 0, 0];
Aau2 = [Aau2; zeros(1,8)];
A3 = A^3;
A2B = A^2 * B;
AB = A*B;
Aau2 = [Aau2; A3(3:4, :), A2B(3:4), AB(3:4), zeros(2,2)];

Bau2 = [zeros(5, 1); 1; B(3:4)];

%=======================================================================%
%   LQR 1
%=======================================================================%
% Qp = diag(5e3, 1e3, 0, 0, 0.1, 0, 0, 0);     % kary za: xw, the, Dxw, Dthe, u, Du, DDxw, DDthe
% Rp = 0.001;                                  % kara za DDu
% Np = zeros(8, 1);
% Qd = diag(0, 0, 0, 0, 0, 0, 0, 0);           % kary za: Dxw, Dthe, DDxw, DDthe, Du, DDu, DDDxw, DDDthe
% Nd = zeros(8,1);
% 
% Q = Qp + transpose(Aa) * Qd * Aa;
% R = transpose(Ba)*Qd*Ba + Rp + 2*transpose(Ba)*Nd;
% N = transpose(Aa)*transpose(Qd)*Ba + transpose(Aa)*Qd*Ba + 2*Np + 2*transpose(Aa)*Nd;

Q = diag(5e3, 1e3, 0, 0, 0.1, 0, 0, 0);     % kary za: xw, the, Dxw, Dthe, u, Du, DDxw, DDthe
R = 0.001;                                  % kara za DDu
N = zeros(8,1);

Fau2 = lqr(Aau2, Bau2, Q, R, N);
%%
%=======================================================================%
%   Symulacja
%=======================================================================%
t = 0:dt:end_time;
xw_ref_sim.time = t;

% bardziej zmienna
xw_ref_sim.signals.values(:, 1) = ( ...
    utils.ustep(t, 0)*track_len/2 + ...
    utils.ustep(t, 1)*(0.35 - track_len/2) - ...
    utils.ustep(t, 7)*(0.25) ) .* 1 ;

% % mniej zmienna
% xw_ref_sim.signals.values(:, 1) = ( ...
%     utils.ustep(t, 0)*track_len/2 + ...
%     utils.ustep(t, 1)*(0.35 - track_len/2) );
% xw_ref_sim.signals.dimensions = 1;

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
%%
simout = sim('s6_model.slx');
x       = simout.state_out;
t       = simout.tout;
u       = simout.u;
d       = simout.d;
ew      = simout.ew;
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
plot(t, u); grid on;
title('$$u(t)$$', 'FontSize', 13);

subplot(426);
plot(t, ew); grid on;
title('$$e_w(t)$$', 'FontSize', 13);

subplot(427);
plot( t(2:end), diff(x(:, 3)) ./dt ); grid on;
title('$$\ddot{x}_w(t)$$', 'FontSize', 13);
xlabel("t [sek]")

subplot(428);
plot( t(2:end), diff(x(:, 4)) ./dt ); grid on;
title('$$\ddot{\theta}(t)$$', 'FontSize', 13); 
xlabel("t [sek]")

title_str_format = "Q = diag[%d %d %d %d %d]\nR = %d";
title_str = sprintf(title_str_format, [diag(Q); R]);
sgtitle(title_str);
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%   Animacja
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
if animacjaON
    x(:, 2) = x(:, 2) * pi/180; 
    x(:, 4) = x(:, 4) * pi/180; 
    utils.animate(IC, Lc, dt, x(:, 1), x(:, 2), t, save_anim, "vid_new");
end



