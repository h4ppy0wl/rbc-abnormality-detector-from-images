function rgbImageWbcRemoved = wbcremove(rgbImage)
 
    wbcMask = bloodsmearbinarization(rgbImage, 'adaptive');
    r_channel = rgbImage(:,:,1);
    g_channel = rgbImage(:,:,2);
    b_channel = rgbImage(:,:,3);
    r_channelWbcRemoved = regionfill(r_channel, wbcMask);
    g_channelWbcRemoved = regionfill(g_channel, wbcMask);
    b_channelWbcRemoved = regionfill(b_channel, wbcMask);
    %rgbImageWbcRemoved = zeros (size (rgbImage));
    rgbImageWbcRemoved = cat(3,r_channelWbcRemoved, g_channelWbcRemoved, b_channelWbcRemoved);
    %rgbImageWbcRemoved = roifill(rgbImage, wbcMask);
    clear wbcMask r_channel g_channel b_channel r_channelWbcRemoved g_channelWbcRemoved b_channelWbcRemoved
end