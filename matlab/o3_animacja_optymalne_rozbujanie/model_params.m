%% Params
M = 0.416 ; mc = 0; mp = 0.089;
Lp = 0.113 / 2; Lc = 2*Lp; % 
g = 9.8145; 
b_lepkie = 1.5; gamma = 0.005;
% obliczone parametry
mr = mc + mp;
Mt = mr + M;
L  = (Lc*mc + Lp*mp) / mr;
Jcm = (L^2)*mr + (Lc^2)*mc + 4/3 * (Lp^2)*mp;
Jt  = Jcm + mr*L^2;
alpha = 1.719;
beta = 7.682;
% dodatkowe parametry do tarcia stribecka
miu_c = 0.0861; 
miu_s = 0.04287; 
vs = 0.105; 
i_ = 2; 
b_stribeck = 3;
delta = 400; % do tanh zamiast signum

%%
% save('model_params')