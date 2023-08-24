%=======================================================================%
%   Stabilizacja wahadła w górnym położeniu równowagi
%   LQI, śledzenie zmiennej pozycji wózka
%=======================================================================%
%%
clc
clear
clf
%%
%=======================================================================%
%   System
%=======================================================================%
n=2; % 1-LD, 2-LG, 3-SD, 4-SG
[A, B, H] = macierze_mdl_liniowy(n); % H - macierz mnożąca zakłucenia
D=0;
%%
%=======================================================================%
%   Ustawienia
%=======================================================================%
dt = 0.001;
track_len = 0.47;
end_time = 16;
pos_com1 = 0.1;
pos_com2 = 1;
ampD = 0.3;
%%
%=======================================================================%
%   LQI     stan = [x the Dx Dthe int(p-x)]
%=======================================================================%
% Dxa = Aa*xa + Ba*u + G*c_ref
E = [1 0 0 0]; % wyj. sterowane = x_wózka
Aa = [A, zeros(4,1); E, 0];
Ba = [B;0];
G = [0;0;0;0;-1];
Ca = eye(5,5); Da = zeros(5, 1);

Q = diag( [30e3, 5e3, 0e3, 0e3, 2e3] );
R = 0.02;
K=lqr(Aa, Ba, Q, R)

% muszę to tak zrobić żeby przetestować zmienne c_ref
% system zamkniety, u=-K*xa
% Dxa = (Aa - Ba*K)xa + G*c_ref
Acl = Aa - Ba*K;
Bcl = G;
Ccl = eye(5,5); Dcl = zeros(5,1);

syscl = ss(Acl, Bcl, Ccl, Dcl);

%%
%=======================================================================%
%   Symulacja. c_ref=x_ref
%=======================================================================%
t = 0:dt:end_time;
x_ref = ( ...
    utils.ustep(t, 2).*pos_com1 - ...
    utils.ustep(t, 8).*(pos_com1 - pos_com2) - ...
    utils.ustep(t, 12).*(1) ) .* 1;
IC = [
    track_len/2;
    0 *pi/180;
    0;
    0 *pi/180;
    0];
% x_ref*0 bo chce patrzeć tylko na odpowiedź swobodną
[y, tout, state_out] = lsim(syscl, x_ref*0, t, IC);
x       = state_out;
x(:, 2) = x(:, 2).*180/pi;
x(:, 4) = x(:, 4).*180/pi;
t       = tout;
%=======================================================================%
%   ploty
%=======================================================================%
figure(1); 
subplot(421); 
plot(t, x(:, 1)); grid on;
title('x_w');

subplot(422);
plot(t, x(:, 2)); grid on;
title('\theta');

subplot(423);
plot(t, x(:, 3)); grid on;
title('Dx_w');

subplot(424);
plot(t, x(:, 4)); grid on;
title('D\theta'); 

subplot(425);
plot(t, x(:, 5)); grid on;
title('zmienna całkowa'); 

subplot(426);
plot(t, -K*transpose(x)); grid on;
title('sterowanie u'); 

subplot(427);
plot(t, x_ref); grid on;
title('zadane przesunięcie wozka');

