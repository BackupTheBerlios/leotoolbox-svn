function out = normalize_dbls(dbl_array, scale_to)
    % scales the array linearly to values 
    % between +scale_to and -scale_to

    maxval = max(dbl_array);
    minval = min(dbl_array);
    halfdiff = (maxval - minval)/2;
    medianval = maxval - halfdiff;
    newmax = (maxval-medianval)*halfdiff;
    scalefactor = scale_to/halfdiff;
    for i = 1 : length(dbl_array)
        %new_array(i) = (dbl_array(i)-medianval)*halfdiff
        new_array(i) = (dbl_array(i)-medianval)*scalefactor;
    end
    out = new_array;
    