function [ L ] = cellclusterwatershed( binarryImage )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
%%imageResizeFactor = 0.6;
% grayscaleImage1 = grayscaleImage(:,:,2);
%%grayscaleImage = imresize(grayscaleImage,imageResizeFactor);
% bin = ~imbinarize(grayscaleImage1);
bin = binarryImage;

%start test
D = -bwdist(~bin);
mask = imextendedmin(D,1);
D2 = imimposemin(D,mask);
L = watershed(D2,8);
%end test

end

