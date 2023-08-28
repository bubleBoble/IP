function [A, B, H] = macierze_mdl_liniowy(n)
%
%       [A, B, H] = macierze_mdl_liniowy(1);
%
%       n = 1 -> lepkie / dolne
%       n = 2 -> lepkie / górne
%       n = 3 -> Stribecka / dolne
%       n = 4 -> Stribecka / górne
%

% parametry ze skryptu 'model_params.m'
    run('utils.model_params.m');

%=======================================================================%
%   tarcie lepkie, położenie dolne
%=======================================================================%
    den = Jt*Mt-(L*mr)^2;
    a1 = -(L^2)*g*(mr^2)/den;
    a2 = -Jt*(b_lepkie+beta_)/den;
    a3 = -L*gamma_*mr/den;
    a4 = -L*Mt*g*mr/den;
    a5 = -L*mr*(b_lepkie+beta_)/den;
    a6 = -Mt*gamma_/den;
    b1 = Jt*alpha_/den;
    b2 = L*mr*alpha_/den;
    h1 = (-Jt+L*Lc*mr)/den;
    h2 = (Lc*Mt - L*mr)/den;
    ALD = [
        0  0  1  0;
        0  0  0  1; 
        0  a1 a2 a3;
        0  a4 a5 a6;
    ];
    BLD = [0;0;b1;b2];
    HLD = [0;0;h1;h2];
%=======================================================================%
%   tarcie lepkie, położenie górne
%=======================================================================%
    ALG = [
        0  0  1  0;
        0  0  0  1; 
        0  a1 a2 -a3;
        0  -a4 -a5 a6;
    ];
    BLG = [0;0;b1;-b2];
    HLG = [0;0;-h1;h2];
%=======================================================================%
%   tarcie Stribecka, położenie dolne
%=======================================================================%
    a2 = -Jt*(400*Mt*g*miu_s+b_stribeck+beta_)/den;
    a5 = -L*mr*(400*Mt*g*miu_s+b_stribeck+beta_)/den;
    ASD = [
        0  0  1  0;
        0  0  0  1; 
        0  a1 a2 a3;
        0  a4 a5 a6;
    ];
    BSD = [0;0;b1;b2];
    HSD = [0;0;h1;h2];
    
%=======================================================================%
%   tarcie Stribecka, położenie górne
%=======================================================================%
    ASG = [
        0  0  1  0;
        0  0  0  1; 
        0  a1 a2 -a3;
        0  -a4 -a5 a6;
    ];
    BSG = [0;0;b1;-b2];
    HSG = [0;0;-h1;h2];
%=======================================================================%
%   return
%=======================================================================%
    switch n
        case 1  % lepkie dół
            A=ALD; B=BLD; H=HLD;
        case 2  % lepkie góra
            A=ALG; B=BLG; H=HLG;
        case 3  % Stribeck dół
            A=ASD; B=BSD; H=HSD;
        case 4  % Stribeck góra 
            A=ASG; B=BSG; H=HSG;
    end % switch
end % function














