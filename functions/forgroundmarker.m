function [ fgm ] = forgroundmarker( grayscaleCellClusterImage )
% [ fgm ] = forgroundmarker( grayscaleCellClusterImage )
% Builds forground marker for cells to be used in watershed analysis.
% input image should be zoomed graysclae image of cells cluster.

level = adaptthresh(grayscaleCellClusterImage, 0.9);
binaryImage = imbinarize(grayscaleCellClusterImage, level);
binaryImage = imerode(binaryImage, strel('disk', 3));
binaryImage = imclose(binaryImage, strel('disk', 2));
binaryImage = imfill(binaryImage, 'holes');
fgm = imerode(binaryImage, strel('disk', 5));

end

