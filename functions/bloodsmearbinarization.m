
function [mask,rgbMask] = bloodsmearbinarization(rgbImage,colorSpace, binarizationMethod, binarizationSensitivity, openingValue, closingValue)
% #outputs banary image of the WBCs in blood smear by defined method ( otsu,
% graythresh or adaptive).
% sensitivity for adaptive thresholding method is set to 0.9.
% thershold level is retrived from rgb or gray scale image and performed on
% s channel of hsv color space as this channel performes better on
% segmentation of white blood cells.
    switch colorSpace
        case 'hsv'
            hsvImage = rgb2hsv(rgbImage);
            grayscaleImage = rgb2gray(rgbImage);
            s_channel = hsvImage(:,:,2);
            s_channel = imadjust(s_channel);
            switch binarizationMethod
                case 'otsu'
                    [counts, x] = imhist(grayscaleImage, 32);
                    [level, em] = otsuthresh(counts);
                    binaryImage = im2bw(s_channel, level);
                    binaryImage = imopen(binaryImage, strel('disk', openingValue));
                    mask = imclose(binaryImage, strel('disk', closingValue));
                case 'graythresh'
                    level = graythresh(rgbImage);
                    binaryImage = im2bw(s_channel, level);
                    binaryImage = imerode(binaryImage, strel('disk', openingValue));
                    mask = imdilate(binaryImage, strel('disk', closingValue));
                    mask = imfill(mask);
                case 'adaptive'
                    level = adaptthresh(s_channel, binarizationSensitivity);
                    binaryImage = imbinarize(s_channel, level);
                    binaryImage = imopen(binaryImage, strel('disk', openingValue));
                    mask = imclose(binaryImage, strel('disk', closingValue)); 
                    mask = imfill(mask,'holes');
                case 'manual'
%                     level = adaptthresh(s_channel, binarizationSensitivity);
                    binaryImage = imbinarize(s_channel, binarizationSensitivity);
                    %binaryImage = imopen(binaryImage, strel('disk', openingValue));
                    mask = imclose(binaryImage, strel('disk', closingValue));
                    %mask = bwareaopen(mask,200,4); % area size should be related to image size
                    mask = imfill(mask,'holes');
                    mask = imerode(mask, strel('disk', openingValue));
%                     mask = imdilate(mask, strel('disk', closingValue));
                    mask = bwareaopen(mask,200,4);
                    mask = imfill(mask,'holes');
                    %mask = imopen(binaryImage, strel('disk', closingValue));
                    
            end
            
        case 'cmyk'
            cmykImage = rgb2cmyk(rgbImage);
            y_channel = cmykImage(:,:,3);
            %y_channel = y_channel .*2;
            %y_channel = imadjust(y_channel,stretchlim(y_channel),[0,1]);
            %y_channel = y_channel.*3;
            %y_channelFilled = imfill(y_channel,26);
            %y_channel = imdilate(imerode(y_channelFilled,strel('disk',1)),strel('disk',1));
            %imshow(y_channel)
            k_channel = cmykImage(:,:,4);
            %k_channel = k_channel.*2;
            %k_channel = imadjust(k_channel,stretchlim(k_channel),[0,1]);
            k_channelFilled = imfill(k_channel);
            k_channelADJ = imadjust(k_channelFilled,stretchlim(k_channelFilled),[0,1]);
            %imshow(y_channel)
            switch binarizationMethod
                case 'adaptive'
                    
                    klevel = adaptthresh(k_channelADJ, binarizationSensitivity);
                    kMask = imbinarize(k_channelADJ, klevel);
                    
                    %kMaskDilated = imdilate(kMask,strel('disk',2));
                    %mask = uint8(kMaskDilated);
                    mask = uint8(kMask);
                    yROI = y_channel .* mask;
                    yROI = imfill(yROI);
                    yROI = imadjust(imdilate(imerode(yROI,strel('disk',2)),strel('disk',3)));
                    %imshow(yROI)
                    level = adaptthresh(yROI, binarizationSensitivity);
                    binary = imbinarize(yROI, level);
                    binary = imdilate(binary, strel('disk',5));
                    binary = imfill(binary,'holes');
                    binary = imerode(binary,strel('disk',5));
                    %binary = imdilate(binary, strel('disk',2));
                    k_channelMasked = k_channel;
                    k_channelMasked(imcomplement(binary)) = 0;
                    leveltest = adaptthresh(k_channelMasked,0.8);
                    bintest = imbinarize(k_channelMasked,leveltest);
                    bintest = imfill(bintest,'holes');
                    bintest = bwareaopen(bintest,1000,8);
                    k_channelMasked(imcomplement(bintest)) = 0;
                    imshow(k_channelMasked)
                    
            end
            
    end
                    %mask = imclose(binaryImage, strel('disk', closingValue));
                    rgbMask = rgbImage;
                    rgbMask(repmat(~mask,[1 1 3])) = 0;
                    clear hsvImage level s_channel grayscaleImage


end