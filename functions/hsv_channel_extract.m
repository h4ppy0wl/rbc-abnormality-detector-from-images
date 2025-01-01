function channel = hsv_channel_extract (hsv, requested_channel)
%This function extracts requested channel of input hsv color space image.
    BlackHSV = zeros(size(hsv,1),size(hsv,2), 'double');
    switch requested_channel
        case 'h'
            h_channel = hsv(:,:,1);
            channel = cat(3, h_channel, BlackHSV, BlackHSV);
        case 's'
            s_channel = hsv(:,:,2);
            channel = cat(3, BlackHSV, s_channel,BlackHSV);
        case 'v'
            v_channel = hsv(:,:,v);
            channel = cat(3,BlackHSV, BlackHSV, v_channel);            
        otherwise
            error('second argument of the function should be one of the "h", "s" or "v" channel names')
    end
end