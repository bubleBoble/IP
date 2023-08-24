% which optimTraj
% C:\Users\Adam\AppData\Roaming\MathWorks\MATLAB Add-Ons\Collections\OptimTraj  --  Trajectory Optimization Library
run('model_params.m')
params_lepkie = [M, mc, mp, Lp, Lc, g, b_lepkie, gamma, mr, Mt, L, Jcm, Jt, alpha, beta];
params_stribeck = [M, mc, mp, Lp, Lc, g, b_stribeck, gamma, mr, Mt, L, Jcm, Jt, alpha, beta, miu_c, miu_s, vs, i_, delta];

track_len   = 0.47; % długość suwnicy
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                    tutaj testowałem obliczanie
%                    optymalnych trajektorii
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
maxU        = 12;   % ograniczenie napięcia na DCM
duration    = 15;    % końcowy czas

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                     Set up function handles                             %
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
problem.func.dynamics   = @(t,x,u)( IPdynamics(x,u,params_lepkie) );
problem.func.pathObj    = @(t,x,u)( u.^2 );

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                     Set up problem bounds                               %
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
problem.bounds.initialTime.low = 0;
problem.bounds.initialTime.upp = 0;
problem.bounds.finalTime.low = duration;
problem.bounds.finalTime.upp = duration;

problem.bounds.initialState.low = [track_len/2;pi;0;0];
problem.bounds.initialState.upp = [track_len/2;pi;0;0];
problem.bounds.finalState.low = [track_len/2;0;0;0];
problem.bounds.finalState.upp = [track_len/2;0;0;0];

problem.bounds.state.low = [-2*track_len;-2*pi;-inf;-inf];
problem.bounds.state.upp = [2*track_len;2*pi;inf;inf];

problem.bounds.control.low = -maxU;
problem.bounds.control.upp = maxU;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                    Initial guess at trajectory                          %
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
problem.guess.time = [0,duration];
problem.guess.state = [problem.bounds.initialState.low, problem.bounds.finalState.low];
problem.guess.control = [0,0];

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                         Solver options                                  %
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
problem.options.nlpOpt = optimset(...
    'Display','iter',...
    'MaxFunEvals',1e6);

problem.options.method = 'trapezoid';
% problem.options.method = 'hermiteSimpson';
% problem.options.method = 'rungeKutta';
% problem.options.method = 'chebyshev';

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                            Solve                                        %
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
soln = optimTraj(problem);  

%%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                     Unpack the simulation                               %
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
tOT = linspace(soln.grid.time(1), soln.grid.time(end), 350);
stateOT = soln.interp.state(tOT);
uOT = soln.interp.control(tOT);
uOT_func = soln.interp.control;

xOT    = stateOT(1, :);
theOT  = stateOT(2, :);
dxOT   = stateOT(3, :);
dtheOT = stateOT(4, :);

%%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                            Plot                                         %
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% The soln.interp struct contains a set of function handles that are used for
% method-consistent interpolation the solution trajectory
% chyba najciekawsze
% soln.interp % two func handles - .state(t) and .control(t) + collCst =
% value of collocation constraint = error metric
% soln.info
% soln.problem

if 1 % ustawić na 1 tylko żeby zobaczyć wygenerowane przebiegi
    figure(1); clf;
    
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