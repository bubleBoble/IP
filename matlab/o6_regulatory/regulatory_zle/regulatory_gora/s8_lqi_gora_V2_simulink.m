%=======================================================================%
%   Stabilizacja wahadła w górnym położeniu
%   LQI, śledzenie zmiennej pozycji wózka
%=======================================================================%

clc
clear
clf
%=======================================================================%
%   System
%=======================================================================%
n=2; % 1-LD, 2-LG, 3-SD, 4-SG
[A, B, H] = macierze_mdl_liniowy(n); 
D=0;
% C = eye(4);
% sys = ss(A, B, C, D);
%=======================================================================%
%   Ustawienia
%=======================================================================%
dt = 0.001;
track_len = 0.47;
the0deg  = 0;
Dthe0deg = 0;
end_time = 6;
ampD = 0.0;     % mnożnik zakłóceń
animacjaON=1
save_anim=1
vid_nr=1

% 0, 1 - LQI
% 2, 3, 4 - LQI z rozszerzony o u w zmiennych stanu
ktory_LQR = 3;
%%
%=======================================================================%
% Macierze do systemu rozszerzonego o stan całkowy  
% stan = [x_w the Dx Dthe int(x_w-x)]
%=======================================================================%
% Dxa = Aa*xa + Ba*u + G*c_ref
E = [1 0 0 0]; % wyj. sterowane = x_wózka
Aa = [A, zeros(4,1); E, 0];
Ba = [B;0];
G  = [zeros(4,1); -1];

switch ktory_LQR
    case 0
        %=======================================================================%
        % LQR 0
        %=======================================================================%
        Q = diag( [4e3, 1e3, 0, 0, 10] );
        R = 5;
        
        Fa=lqr(Aa, Ba, Q, R);
        Fa = [Fa, 0]; % żebym nie musiał odłączać u od wektora stanu w simulinku
    case 1
        %=======================================================================%
        % LQR 1
        %=======================================================================%
        Q = diag( [3e3, 1e3, 1, 10, 10] );
        R = 1;
        
        Fa=lqr(Aa, Ba, Q, R);
        Fa = [Fa, 0]; % żebym nie musiał odłączać u od wektora stanu w simulinku
    case 2
        %=======================================================================%
        % LQR 2,  stan = [x_w the Dx Dthe int(x_w-x), u]    (1x6)
        %=======================================================================%
        Aa = [A, zeros(4, 1); E, 0];
        Aa = [Aa; zeros(1, 5)];
        Aa = [Aa, [B;0;0]];
        Ba = [zeros(5, 1);1];
        Q = diag( [3e3, 1e3, 1, 10, 10, 1] );
        R = 0.1;
        Fa=lqr(Aa, Ba, Q, R);
    case 3
        Aa = [A, zeros(4, 1); E, 0];
        Aa = [Aa; zeros(1, 5)];
        Aa = [Aa, [B;0;0]];
        Ba = [zeros(5, 1);1];
        Q = diag( [3e9, 1e9, 1e6, 10e6, 10e6, 0.00001] );
        R = 2e4;
        Fa=lqr(Aa, Ba, Q, R);

    case 4
        Aa = [A, zeros(4, 1); E, 0];
        Aa = [Aa; zeros(1, 5)];
        Aa = [Aa, [B;0;0]];
        Ba = [zeros(5, 1);1];
        Q = diag( [1, 1, 0, 0, 1, 1] );
        R = 0.1;
        Fa=lqr(Aa, Ba, Q, R);

end % ktory_LQR

%%
%=======================================================================%
%   Symulacja
%=================5======================================================%
t = 0:dt:end_time;
xw_ref_sim.time = t;
xw_ref_sim.signals.values(:, 1) = ( ...
    utils.ustep(t, 0)*track_len/2 + ...
    utils.ustep(t, 1)*(0.4 - track_len/2) - ...
    utils.ustep(t, 3)*(0.3) ) .* 1;
xw_ref_sim.signals.dimensions = 1;
d_sim.time = t;
d_sim.signals.values(:, 1) = (utils.ustep(t, 4.5)-utils.ustep(t, 4.6)) .* ampD;
d_sim.signals.dimensions = 1;

IC = [
    track_len/2;
    the0deg*pi/180;
    0;
    Dthe0deg*pi/180];
run('model_params.m')
params_lepkie = [M, mc, mp, Lp, Lc, g, b_lepkie, gamma_, mr, Mt, L, Jcm, Jt, alpha_, beta_];
params_stribeck = [M, mc, mp, Lp, Lc, g, b_stribeck, gamma_, mr, Mt, L, Jcm, Jt, alpha_, beta_, miu_c, miu_s, vs, i_, delta];
%%
simout = sim('s8_MDL_Tlepkie_lqi_gora_V2.slx');
x       = simout.state_out;
t       = simout.tout;
u       = simout.u;
d       = simout.d;
xi      = simout.int_state_out;
ew      = simout.ew;
%=======================================================================%
%   ploty
%=======================================================================%
fig = figure(1); 

subplot(421); 
plot(t, x(:, 1)); grid on;
ylim([0, track_len]);
title('$$x_w(t)$$', 'FontSize', 13);

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
plot(t, xw_ref_sim.signals.values); grid on;
title('$$x_{w, ref}(t)$$', 'FontSize', 13);
xlabel("t [sek]")

subplot(428);
plot(t, ew); grid on;
title('$$e_w(t)$$', 'FontSize', 13);
xlabel("t [sek]")

switch ktory_LQR % lqr 2 ma o jedną zmienną stanu więcej
    case 1
        title_str_format = "Q = diag[%d %d %d %d %d]\nR = %d";
    otherwise
        title_str_format = "Q = diag[%d %d %d %d %d %d]\nR = %d";
end

title_str = sprintf(title_str_format, [diag(Q); R]);
sgtitle(title_str);
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%   Animacja
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
if animacjaON
    x(:, 2) = x(:, 2) * pi/180; 
    x(:, 4) = x(:, 4) * pi/180; 
    utils.animate(IC, Lc, dt, x(:, 1), x(:, 2), t, save_anim, sprintf("vid_%d_LQR_%d", vid_nr, ktory_LQR));
end





