function str = ypea_simplify_string(str)
    % Simplifies a String
    str = lower(str);
    str = replace(str, [" ", "-", "_", "."], '');
    
end