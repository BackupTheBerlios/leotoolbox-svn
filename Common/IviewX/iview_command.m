function[ ep ] = iview_command( name, parameters )

ep = 0; % expected_parameters = 0;
switch( name ) 
    case 'ET_ACC'
        ep = 0;
        %Accept cal. point
    case 'ET_AUX' 
        ep = 1;
         %"String" message in data buffer
    case 'ET_BMP' 
        ep = 1; %"bitmap" loads bitmap
    case 'ET_BRK'
        ep = 0; %cal. is cancelled
    case 'ET_CAL'
        ep = 1; %           start cal usage 'ET_cal n 'ET_csz x y, 'ET_pnt i x y
    case 'ET_CFG'
        ep = 0; %current config
    case 'ET_CHG'
        ep = 1; %change of calib point
    case 'ET_CLR'
        ep = 0; %clear buffer interlnal
    case 'ET_CNT'  
        ep = 0; %continue recording without inc. s'ET number
    case 'ET_CPA'  
        ep = 2; % cal. param'ETers  0 = wait valid data, 1 randomize point order, 2 auto accept CPA 1 (0/1) on/off
    case 'ET_CSZ'  
        ep = 2; % cal. area (screen param)
    case 'ET_DEF'  
        ep = 0; %default positions of cal. points
    case 'ET_EIM'  
        ep = 0; % end transfer of mime video
    case 'ET_EST'  
        ep = 0; %stop continuous data output
    case 'ET_FIN'  
        ep = 1 ; % sent when cal. has finished successfully
    case 'ET_FRM'
        % data format
    case 'ET_IMG'
    case 'ET_INC' 
        ep = 0; %increment recording s'ET
    case 'ET_LEV' %level cal. 0=none, 1=weak, 2=medium, 3=strong
    case 'ET_LNS' %
    case    'ET_MOV' %
    case    'ET_PNT' %s'ET cal.point 'ET_pnt 1 400 300
           ep = 3;
    case   'ET_PSE' %pause current recording
    case    'ET_RCL' %drift correction start
    case    'ET_REC' %start rectording optional time 'ET_rec 5 = secondes
    case    'ET_REM' %remark in data
    case    'ET_SAV' %svave data to file : 'ET_sav "c:\t.idf"
    case    'ET_SFT' %remotely control tracker param'ETers : eye type (0 left/1 right), param'ETer type
        % 0 = pupil threshold
        % 1 = reflex threshold
        % 2 = show aio
        % 3 = show contour
        % 4 = show pupil
        % 5 = show reflex
        % 6 = dyn. threshold

    case 'ET_SIM' % = eye video image
    case 'ET_SPL' % = sample is generated
        ep = 3;
    case 'ET_STP' % = stop recording

    case 'ET_STR' % = start continuous data output : param'ETer subsampling_factor
    case 'ET_VRE' %= start video recording
    case 'ET_VST' %= stop video recording
    case ''
        ep = 0;
    otherwise
        e = ['Unknown command : ' name];
        error(e);
end;


 