function[new_parameters] = flip( window, parameters, description )
    if nargin == 2
        description = '';
    end;
    c = clock;
    
    Screen('Flip', window);
    
    if (strcmp(class(parameters), 'struct') == 1)
        log('Screen Flip', parameters(6).value);
        flips = parameters(4).value;
        descriptions = parameters(5).value;
        
        s = size(flips, 1);
        flips(s+1,:) = c;
 
        descriptions{s+1} = description;
        parameters(4).value = flips;
        parameters(5).value = descriptions;
    
        new_parameters = parameters;
    else
        new_parameters = -1;
    end;