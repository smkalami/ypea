%% Cultural Algorithm
% This document shows how
% *Cultural Algorithm (CA)*
% as a part of Yarpiz Evolutionary Algorithms Toolbox (YPEA)
% cab be used to solve optimization problems.

%% Problem Definition
% First of all, we need to define optimization problem. We must define the
% search space (decision variables) and objective function.

%%
% Let's ceate an instance of optimization problem.
problem = ypea_problem();

%%
% Assume that the problem is to find 20 real numbers, in range -10 to 10.
problem.vars = ypea_var('x', 'real', 'size', 20, 'lower_bound', -10, 'upper_bound', 10);

%%
% And, the objective is to minimize the well-known _sphere_ function
% in this domain.
sphere = ypea_test_function('sphere');
problem.obj_func = @(sol) sphere(sol.x);

%%
% To get more information on the optimization problems and decision variables,
% you can go to
% <doc_ypea_problem.html Optimization Problems> and
% <doc_ypea_var.html Decision Variables>.

%% Cultural Algorithm
% Now, we are ready to create, initialize and utilize the
% Cultural Algorithm (CA)
% to solve the optimization problem, defined above.

%%
% First, we must create an instance of algorithm class:
alg = ypea_ca();

%%
% There are four type of influence method for Cultural Algorithm
% available in YPEA Toolbox. The method is defined and set by
% |alg.influence_type|. Available culture influence methods are listed
% below:
% 
% * *Using only normative component of culture* (for size),
% which can be set and used by |alg.influence_type = 1|.
% * *Using only situational component of culture* (for direction),
% which can be set and used by |alg.influence_type = 2|.
% * *Using both normative and situational components of culture*,
% which can be set and used by |alg.influence_type = 3|. This is the
% default method.
% * *Using normative component of culture* (for both size ans direction),
% which can be set and used by |alg.influence_type = 4|.
% 

%%
% Other parameters for the Cultural Algorithm are listed below:
% 
% * Acceptance Rate, which determines the number of individuals used to adjust culture (|accept_rate|, default: 0.2)
% * Step Size Coefficient (|alpha|, default: 0.9)
% * Scaling Factor, which is only used by 4th influence method (|beta|, default: 0.5)
% 

%%
% Now, let's set the parameters of the algorithm.

% Maximum Number of Iterations
alg.max_iter = 100;

% Population Size
alg.pop_size = 50;

% Type of Culture Influence Method
alg.influence_type = 3;

% Acceptance Rate
alg.accept_rate = 0.2;

% Step Size Coefficient
alg.alpha = 0.9;


%%
% We are ready to run the algorithm and solve the problem.
% The solve method, gets problem as input and returns |best_sol|, the best solution found
% by the algorithm.

best_sol = alg.solve(problem);

%%
% You may turn of the text output, by disabling the display property, just
% befor running the algorithm (i.e. calling |alg.solve(problem)|).
alg.display = false;

%% Results

%%
% The actual solution, is stored in the |solution| field of |best_sol|.

best_sol.solution

%%
% The values of 20 decision variables, denoted by |x| is as follows:
best_sol.solution.x

%%
% and the related objective value is:
best_sol.obj_value

%%
% Total run time of the algorithm is given by (in seconds):
alg.run_time

%%
% and total number of function evaluations is given by:
alg.nfe

%%
% We can illustrate the result of optimization process by plotting
% best objective value history (|alg.best_obj_value_history|)
% vs. number of function evaluations (|alg.nfe_history|).

figure;
alg.semilogy('nfe', 'LineWidth', 2);
xlabel('NFE');
ylabel('Best Objective Value');
title(['Results of ' alg.full_name]);
grid on;
