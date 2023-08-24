%=======================================================================%
%   Stabilizacja wahadła w górnym położeniu
%   LQR, śledzenie zmiennej pozycji zadanej wózka
%   Funkcja podcałkowa z funkcji celu z LQR zmieniona na *
%   * = x' Qp x + u' Rp u + 2x' Np u + Dx' Qd Dx + 2Dx' Nd u
%   Dx - pierwsza pochodna x po czasie
%   x' - transpozycja x
%   
%   po co:
%       zamiast uwzględniać sygnał. sterujące w zmiennych stanu i 
%       w LQR ustawiać karę za pochodną syg. sterującego, tutaj 
%       ustawia się karę bezpośrednio za przyśpieszenia wózka i wahadła
%       
%       wcześniej, ustawienie kary za pochodną syg. wej. skutkowało w
%       mniejszym szarpaniu wózkiem i wahadłem - mniejsze wartości
%       przyśpieszeń

%   Możliwość wprowadzenia kary za:
%       - stan
%       - synał sterujący
%       - pochodną sygnału sterującego
%       - x' * u
%=======================================================================%
clc
clear
clf
change_simulink_stupid_cache_directory
utils.change_text_interpreter_to_latex
%=======================================================================%
%   Macierze
%=======================================================================%
n=2; % 1-LD, 2-LG, 3-SD, 4-SG
[A, B, H] = utils.macierze_mdl_liniowy(n); 
D=0; E=[1 0 0 0];
%=======================================================================%
%   Ustawienia
%=======================================================================%
dt          = 0.001;        % próbkowanie do symulacji i sygnałów 
track_len   = 0.47;         % długość suwnicy
the0deg     = 0;            % początkowa wartość kąta wychylenia wahadła
Dthe0deg    = 0;            % początkowa wartość pr. kątowej wahadła
end_time    = 10;            % końcowy czas symulacji
ampD        = 0.00;         % mnożnik zakłóceń
sat         = [12, -12];    % saturacja sygnału sterującego
animacjaON  = 0             % animacja on/off
save_anim   = 0             % zapisanie animacji on/off

%% 
%=======================================================================%
%   LQR 1a
%   szybka zmiana pozycji
%   duża zmiana wychylenia
%   
%   Dla Np=0, Qd=0, Nd=0, LQR1a powinno dać takie same wyniki jak LQR1b
%=======================================================================%
if 0
    Qp = diag( [400e3, 0, 0.2e3, 0] );  % koszt: xw, the, Dxw, Dthe
    Rp = 200;                           % koszt u
    Np = zeros(4, 1);                   % koszt x' * u
    Qd = diag( [0, 0, 0, 0] );          % koszt Dxw, Dthe, DDxw, DDthe
    Nd = zeros(4, 1);                   % koszt Dx' * u
    
    Q = Qp + transpose(A) * Qd * A;
    R = transpose(B)*Qd*B + Rp + 2*transpose(B)*Nd;
    N = transpose(A)*transpose(Qd)*B + transpose(A)*Qd*B + 2*Np + 2*transpose(A)*Nd;
    
    F=lqr(A, B, Q, R, N);
end
%=======================================================================%
%   LQR 1b
%=======================================================================%
if 1
    Q = diag( [400e3, 0, 0.2e3, 0] );  % koszt: xw, the, Dxw, Dthe
    R = 200;                           % koszt u
    F=lqr(A, B, Q, R);
end
%=======================================================================%
%   LQR 2
%   wolna zmiana pozycji
%   mała zmiana wychylenia
%=======================================================================%
if 0
    Q = diag( [400e3, 4e6, 0, 10e3] );
    R = 200;
    F=lqr(A, B, Q, R);
end
%=======================================================================%
%   LQR 3
%=======================================================================%
if 1
    Qp = diag( [400e6, 0, 0.2e3, 0] );  % koszt: xw, the, Dxw, Dthe
    Rp = 200;                           % koszt u
    Np = zeros(4, 1);                   % koszt x' * u
    Qd = diag( [0, 0, 1e4, 0] );     % koszt Dxw, Dthe, DDxw, DDthe
    Nd = zeros(4, 1);                   % koszt Dx' * u
    
    Q = Qp + transpose(A) * Qd * A;
    R = transpose(B)*Qd*B + Rp + 2*transpose(B)*Nd;
    N = transpose(A)*transpose(Qd)*B + transpose(A)*Qd*B + 2*Np + 2*transpose(A)*Nd;
    
    F=lqr(A, B, Q, R, N);
end
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
    utils.ustep(t, 4)*(0.25) ) .* 1 + ...
    utils.ustep(t, 8)*(track_len/2 - 0.1);

% % mniej zmienna
% xw_ref_sim.signals.values(:, 1) = ( ...
%     utils.ustep(t, 0)*track_len/2 + ...
%     utils.ustep(t, 1)*(0.35 - track_len/2) );

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
simout = sim('s4_model_rozszerzony_LQR.slx');
x       = simout.state_out;
t       = simout.tout;
u       = simout.u;
d       = simout.d;
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

title_str_format = "Q = diag[%d %d %d %d]\nR = %d";
title_str = sprintf(title_str_format, [diag(Q); R]);
sgtitle(title_str);

%%
% =========================================================================== %
%   Animacja
% =========================================================================== % 
if animacjaON
    x(:, 2) = x(:, 2) * pi/180; 
    x(:, 4) = x(:, 4) * pi/180; 
    utils.animate(IC, Lc, dt, x(:, 1), x(:, 2), t, save_anim, "vid_new");
end





