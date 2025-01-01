rgb = imread('20180730_174633cropped.jpg');
%[mask1, rgbMask1] = bloodsmearbinarization(rgb, 'hsv','adaptive',0.5,1,10);
[rgbMask1, lighten] = WBC_SegProposed(rgb,1);
%imshow(mask1)
rgbMasked = lighten;
rgbMasked(:,:,1) = rgb(:,:,1) + (rgbMask1(:,:,1)); %regionfill(rgb(:,:,1),rgbMask1(:,:,1));
rgbMasked(:,:,2) = rgb(:,:,2) + (rgbMask1(:,:,2));%regionfill(rgb(:,:,2),rgbMask1(:,:,2));
rgbMasked(:,:,3) = rgb(:,:,3) + (rgbMask1(:,:,3));%regionfill(rgb(:,:,3),rgbMask1(:,:,3));
imshow(rgbMasked)