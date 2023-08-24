function dx = IPdynamics(x, u, params_lepkie)
    % x : stan
    % u : input - napięcie

    % State, function input: x = [x Dx theta Dtheta]'
    x1 = x(1, :);
    x2 = x(2, :); 
    x3 = x(3, :);
    x4 = x(4, :);

    params_lepkie = num2cell(params_lepkie);
    [M, mc, mp, Lp, Lc, g, b, gamma, mr, Mt, L, Jcm, Jt, alpha, beta] = params_lepkie{:};
    d = 0;

    % Equations for pendulum dynamics
    Ff = b*x3;
    Fi = alpha*u - beta*x3;
    A = d*cos(x2) - Ff + L*mr*(x4.^2).*sin(x2) + Fi;
    B = d*Lc + L*g*mr*sin(x2) - gamma*x4;
    DEN = Jt*Mt - (L*mr*cos(x2)).^2;

    ddt_x1 = x3;
    ddt_x2 = x4;
    ddt_x3 = (Jt*A - L*mr*cos(x2).*B) ./ DEN;
    ddt_x4 = (Mt*B - L*mr*cos(x2).*A) ./ DEN;

    dx = [ddt_x1; ddt_x2; ddt_x3; ddt_x4];
end   