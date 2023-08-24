%%
clc

%=======================================================================%
%   Macierze
%=======================================================================%
s = tf('s');

n=2; % 1-LD, 2-LG, 3-SD, 4-SG
[A, B, H] = macierze_mdl_liniowy(n); 

%% Sterowalność
rank(ctrb(A, B))

%%
%=======================================================================%
%   TF = Xw(s)/V(s)
%=======================================================================%
C = [1 0 0 0]; D = 0;
sys = ss(A, B, C, D);
[num, den] = ss2tf(A,B,C,D);
G1 = tf(num, den);

[p, z] = pzmap(G1);
scatter(real(p), imag(p), 100, 'x', 'LineWidth', 2); hold on; grid on;
scatter(real(z), imag(z), 100, 'o', 'LineWidth', 2); hold off;
% xlim([-20, 1]); ylim([-8, 8])

% Obserwowalność (tak G) (tak D)
fprintf('obserwowalny: %d\n', rank(obsv(A, C)) == 4);

%%
%=======================================================================%
%   TF = THETA(s)/V(s)
%=======================================================================%
C = [0 1 0 0]; D = 0;
sys = ss(A, B, C, D);
[num, den] = ss2tf(A,B,C,D);
G2 = tf(num, den);

[p, z] = pzmap(G2);
scatter(real(p), imag(p), 100, 'x', 'LineWidth', 2); hold on; grid on;
scatter(real(z), imag(z), 100, 'o', 'LineWidth', 2); hold off;

% Obserwowalność (nie G) (nie D)
fprintf('obserwowalny: %d\n', rank(obsv(A, C)) == 4);

%%
%=======================================================================%
%   TF = D_THETA(s)/V(s)
%=======================================================================%
C = [0 0 0 1]; D = 0;
sys = ss(A, B, C, D);
[num, den] = ss2tf(A,B,C,D);
G3 = tf(num, den);

[p, z] = pzmap(G3);
scatter(real(p), imag(p), 100, 'x', 'LineWidth', 2); hold on; grid on;
scatter(real(z), imag(z), 100, 'o', 'LineWidth', 2); hold off;

% Obserwowalność (nie G) (nie D)
fprintf('obserwowalny: %d\n', rank(obsv(A, C)) == 4);

%%
%=======================================================================%
%   TF = D_Xw(s)/V(s)
%=======================================================================%
C = [0 0 1 0]; D = 0;
sys = ss(A, B, C, D);
[num, den] = ss2tf(A,B,C,D);
G4 = tf(num, den);

[p, z] = pzmap(G4);
scatter(real(p), imag(p), 100, 'x', 'LineWidth', 2); hold on; grid on;
scatter(real(z), imag(z), 100, 'o', 'LineWidth', 2); hold off;

% Obserwowalność (nie G) (nie D)
fprintf('obserwowalny: %d\n', rank(obsv(A, C)) == 4);

%%
%=======================================================================%
%   TF = X_końcówki_wahadła(s)/V(s)
%=======================================================================%
run('model_params.m');
C = [1 Lc 0 0]; D = 0;
sys = ss(A, B, C, D);
[num, den] = ss2tf(A,B,C,D);
G5 = tf(num, den);

[p, z] = pzmap(G5);
scatter(real(p), imag(p), 100, 'x', 'LineWidth', 2); hold on; grid on;
scatter(real(z), imag(z), 100, 'o', 'LineWidth', 2); hold off;

%%
%=======================================================================%
% y = the + Dthe
%=======================================================================%
C = [0 1 1 0]; D = 0;
sys = ss(A, B, C, D);
[num, den] = ss2tf(A,B,C,D);
G3 = tf(num, den);

[p, z] = pzmap(G3);
scatter(real(p), imag(p), 100, 'x', 'LineWidth', 2); hold on; grid on;
scatter(real(z), imag(z), 100, 'o', 'LineWidth', 2); hold off;

% Obserwowalność (nie G) (nie D)
fprintf('obserwowalny: %d\n', rank(obsv(A, C)) == 4);

%%
%=======================================================================%
% y = (the, Dthe)
%=======================================================================%
C = [
    0 0 0 0;
    0 1 0 0;
    0 0 1 0;
    0 0 0 0;]; D = zeros(4,1);
sys = ss(A, B, C, D);

% Obserwowalność (nie G) (nie D)
fprintf('obserwowalny: %d\n', rank(obsv(A, C)) == 4);

%%
%=======================================================================%
% y = (the, Dthe, Dx)
%=======================================================================%
C = [
    0 0 0 0;
    0 1 0 0;
    0 0 1 0;
    0 0 0 1;]; D = zeros(4,1);
sys = ss(A, B, C, D);

% Obserwowalność (nie G) (nie D)
fprintf('obserwowalny: %d\n', rank(obsv(A, C)) == 4);


%%
%=======================================================================%
%   Częstotliwość naturalna i wsp. tłumienia
%=======================================================================%

wn = sqrt(L*mr*g/Jt);
zeta = gamma_/2*sqrt(1/(Jt*L*mr*g));

bode(G2)



