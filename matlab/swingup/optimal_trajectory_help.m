%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%   SKRYPT POMOCNICZY DLA "sim_script.m"
%
%   tutaj można zmieniać:
%       - ograniczenia: stan, sterowanie, czas
%         wartości początkowych, końcowych i dla całego przebiegu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

run('model_params.m')
params_lepkie = [M, mc, mp, Lp, Lc, g, b_lepkie, gamma, mr, Mt, L, Jcm, Jt, alpha, beta];
params_stribeck = [M, mc, mp, Lp, Lc, g, b_stribeck, gamma, mr, Mt, L, Jcm, Jt, alpha, beta, miu_c, miu_s, vs, i_, delta];

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                     Set up function handles                             %
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
problem.func.dynamics   = @(t,x,u)( IPdynamics(x,u,params_lepkie) );
problem.func.pathObj    = @(t,x,u)( 0.25*(u.^2) + 3*x(3, :).^2 + 2*x(4, :).^2 + 100*(x(1, :) - track_len) );

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                     Set up problem bounds                               %
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
problem.bounds.initialTime.low = t0low;
problem.bounds.initialTime.upp = t0upp;
problem.bounds.finalTime.low = tflow;
problem.bounds.finalTime.upp = tfupp;

problem.bounds.initialState.low = x0low;
problem.bounds.initialState.upp = x0upp;
problem.bounds.finalState.low = xflow;
problem.bounds.finalState.upp = xfupp;

problem.bounds.state.low = xlow;
problem.bounds.state.upp = xupp;

problem.bounds.control.low = ulow;
problem.bounds.control.upp = uupp;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                    Initial guess at trajectory                          %
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
problem.guess.time = time_guess;
problem.guess.state = state_guess;
problem.guess.control = control_guess;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                         Solver options                                  %
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
problem.options.nlpOpt = optimset(...
    'Display','iter',...
    'MaxFunEvals',1e7, ....
    'MaxIter', MaxIter);
problem.options.trapezoid.nGrid = duration/dt / 5; % !!!!!!!!!!!!!!!
% problem.options.hermiteSimpson.nSegment = duration/dt / 5;
% problem.options.chebyshev.nColPts
problem.options.rungeKutta.nSegment = 40;
problem.options.rungeKutta.nSubStep = 3;

% ZMIENNA method JEST ZE SKRYPTU "sim_script.m"
problem.options.method = method;
problem.options.verbose = 3;
problem.options.defaultAccuracy = "high";
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                            Solve                                        %
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
soln = optimTraj(problem);  

%%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                     Unpack the simulation                               %
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
tOT = linspace(soln.grid.time(1), soln.grid.time(end), end_time/dt);
stateOT = soln.interp.state(tOT);
uOT = soln.interp.control(tOT);
uOT_func = soln.interp.control;

xOT    = stateOT(1, :);
theOT  = stateOT(2, :);
dxOT   = stateOT(3, :);
dtheOT = stateOT(4, :);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                            Plot                                         %
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
if plotOT % ustawić na 1 tylko żeby zobaczyć wygenerowane przebiegi
    figure();
    
    subplot(321)
    plot(tOT, xOT)
    ylabel('x')
    title('Single Pendulum Swing-Up');
    grid
    
    subplot(322)
    plot(tOT, theOT)
    ylabel('the')
    grid
    
    subplot(323)
    plot(tOT, dxOT)
    ylabel('dx')
    grid
    
    subplot(324)
    plot(tOT, dtheOT)
    ylabel('dthe')
    grid
    
    subplot(325)
    plot(tOT, uOT)
    ylabel('u')
    grid
end