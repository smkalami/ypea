% Cultural Algorithm (CA)
classdef ypea_ca < ypea_algorithm
    
    properties
        
        % Acceptance Rate
        accept_rate = 0.2;
        
        % Influence Method Type
        % Possible Values:
        % 1 - Using only normative component of culture (for size)
        % 2 - Using only situational component of culture (for direction)
        % 3 (default) - Using both normative and situational components of culture
        % 4 - Using normative component of culture (for both size and direction)
        influence_type = 3;
        
        % Step Size
        alpha = 0.9;
        
        % Scaling Factor
        beta = 1;
        
    end
    
    methods
        
        % Constructor
        function this = ypea_ca()
            
            % Base Class Constructor
            this@ypea_algorithm();
            
            % Set the Algorithm Name
            this.name = 'Cultural Algorithm';
            this.short_name = 'CA';
            
        end
        
        % Setter for Influence Method Type
        function set.influence_type(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'integer'});
            
            if value < 1 || value > 4
                str = "Accepted values for Influence Method Type are:" + ...
                    newline + ...
                    newline + ...
                    "1 - Using only normative component of culture (for size)" + ...
                    newline + ...
                    "2 - Using only situational component of culture (for direction)" + ...
                    newline + ...
                    "3 - Using both normative and situational components of culture" + ...
                    newline + ...
                    "4 - Using normative component of culture (for both size and direction)" + ...
                    newline;
                    error(str);
            end
            
            this.influence_type = value;
        end
        
        % Setter for Acceptance Rate
        function set.accept_rate(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'nonnegative'});
            this.accept_rate = value;
        end
        
        % Setter for Step Size (alpha)
        function set.alpha(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'nonnegative'});
            this.alpha = value;
        end
        
        % Setter for Scaling Factor (beta)
        function set.beta(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'nonnegative'});
            this.beta = value;
        end
                
    end
    
    methods(Access = protected)
        
        % Initialization
        function initialize(this)
            
            % Create Initial Population (Sorted)
            sorted = true;
            this.init_pop(sorted);
            
            % Number of Accepted Solutions
            this.params.accept_count = round(this.accept_rate*this.pop_size);
            
            % Worst Objective Value
            worst_obj_value = this.problem.worst_value;
            
            % Variable Vector Size
            var_size = this.problem.var_size;
            
            % Initialize Situational Component of Culture
            culture.situational = this.empty_individual;
            culture.situational.obj_value = worst_obj_value;
            
            % Initialize Normative Component of Culture
            culture.normative.xmin = inf(var_size);
            culture.normative.xmax = -inf(var_size);
            culture.normative.L = repmat(worst_obj_value, var_size);
            culture.normative.U = repmat(worst_obj_value, var_size);
            
            % Initialize Culture
            this.params.culture = culture;
            
            % Adjust Culture
            this.adjust_culture();
            
        end
        
        % Adjust Cluture
        function adjust_culture(this)
            
            culture = this.params.culture;
            
            for i = 1:this.params.accept_count
                
                % Update Situational Component
                if this.is_better(this.pop(i), culture.situational)
                    culture.situational = this.pop(i);
                    this.best_sol = culture.situational;
                end
                
                % Update Normative Component
                for j = 1:this.problem.var_count
                    
                    % Update Lower Side
                    if this.pop(i).position(j) < culture.normative.xmin(j) ...
                            || this.is_better(this.pop(i), culture.normative.L(j))
                        
                        culture.normative.xmin(j) = this.pop(i).position(j);
                        culture.normative.L(j) = this.pop(i).obj_value;
                        
                    end
                    
                    % Update Upper Side
                    if this.pop(i).position(j) > culture.normative.xmax(j) ...
                            || this.is_better(this.pop(i), culture.normative.U(j))
                        
                        culture.normative.xmax(j) = this.pop(i).position(j);
                        culture.normative.U(j) = this.pop(i).obj_value;
                        
                    end
                    
                end
                
            end
            
            culture.normative.size = culture.normative.xmax - culture.normative.xmin;
            
            this.params.culture = culture;
            
        end
        
        % Iterations
        function iterate(this)
            
            % Get the Culture
            culture = this.params.culture;
            
            % Influence fo Culture
            switch this.influence_type
                
                % Using only normative component of culture (for size)
                case 1
                    for i = 1:this.pop_size
                        sigma = this.alpha*culture.normative.size;
                        dx = sigma.*randn(this.problem.var_size);
                        this.pop(i).position = this.pop(i).position + dx;
                        this.pop(i) = this.eval(this.pop(i));
                    end
                    
                % Using only situational component of culture (for direction)    
                case 2
                    for i = 1:this.pop_size
                        for j = 1:this.problem.var_count
                            sigma = this.alpha*0.1;
                            dx = sigma*randn;
                            if this.pop(i).position(j) < culture.situational.position(j)
                                dx = abs(dx);
                            elseif this.pop(i).position(j) > culture.situational.position(j)
                                dx = -abs(dx);
                            end
                            this.pop(i).position = this.pop(i).position + dx;
                        end
                        this.pop(i) = this.eval(this.pop(i));
                    end
                    
                % Using both normative and situational components of culture
                case 3
                    for i = 1:this.pop_size
                        for j = 1:this.problem.var_count
                            sigma = this.alpha*culture.normative.size(j);
                            dx = sigma*randn;
                            if this.pop(i).position(j) < culture.situational.position(j)
                                dx = abs(dx);
                            elseif this.pop(i).position(j) > culture.situational.position(j)
                                dx = -abs(dx);
                            end
                            this.pop(i).position = this.pop(i).position + dx;
                        end
                        this.pop(i) = this.eval(this.pop(i));
                    end
                    
                % Using normative component of culture (for both Size and direction)
                case 4
                    for i = 1:this.pop_size
                        for j = 1:this.problem.var_count
                            sigma = this.alpha*culture.normative.size(j);
                            dx = sigma*randn;
                            if this.pop(i).position(j) < culture.normative.xmin(j)
                                dx = abs(dx);
                            elseif this.pop(i).position(j) > culture.normative.xmax(j)
                                dx = -abs(dx);
                            else
                                dx = this.beta*dx;
                            end
                            this.pop(i).position = this.pop(i).position + dx;
                        end
                        this.pop(i) = this.eval(this.pop(i));
                    end
                    
            end
                        
            % Sort Population
            this.pop = this.sort_population(this.pop);
            
            % Adjust Culture
            this.adjust_culture();
            
        end
    end
    
end
