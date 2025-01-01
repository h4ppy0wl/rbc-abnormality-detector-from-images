function [ subAnalysisResults ] = regionsegmentor( oneDimage, maskfinal, cellMask, houghSensitivity, houghCircleRange, rbcAreaThreshold, mainRegionID, offsetType, offsetNumber )
%UNTITLED Summary of this function goes here
%   I have developed the function by K channel of CMYK color space as
%   "oneDimage". using other color spaces and channels should be
%   offsetType is Offset direction : offset0, offset45, offset90, offset135
%   offsetNumber is number of points
%   examined.
%   
%ID of each final region is an array composed of [main region ID, subregion ID]. subregion ID can be rbc or fragment. 
%WatershedAnalysisResults =
%   int             int         int                 array       struct
%{'numObjects',0,'numRBCs',0,'numFragments',0,'fragmentIDs',[],'region',{'id',0,'mask',cellMask,'cell',regionSingle,'GLCMinput',false}}

%% Defaults:
if ~exist('houghSensitivity','var')
    houghSensitivity = 0.95; %default value for houghSensitivity
end
if ~exist('houghCircleRange','var')
    houghCircleRange = [20,40]; %default value for houghCircleRange
end

if ~exist('rbcAreaThreshold','var')
    rbcAreaThreshold = 2000; %default value for rbcAreaThreshold
end
numRBCs = 0;

if ~exist('offsetType','var')
    offsetType = 'offset45'; %default value for rbcAreaThreshold
end

if ~exist('offsetNumber','var')
    offsetNumber = 40; %default value for rbcAreaThreshold
end

%end Defaluts

%% preparation
regionSingle = double(oneDimage);  %test if double does not deteriotates image data(?!)

regionSingle(~cellMask) = NaN; % masking CMYK channel K by single region mask
imshow(regionSingle)% just for visualization
regionStats = regionprops(cellMask, 'Area','BoundingBox', 'Centroid', 'Image', 'MajorAxisLength','MinorAxisLength'); %region properties of selected region that is detected in watershed analysis

% cropping single region
cropBox = size(regionStats.BoundingBox);
cropBox(1) = regionStats.BoundingBox(1) -10;
cropBox(2) = regionStats.BoundingBox(2) -10;
cropBox(3) = regionStats.BoundingBox(3) +20;
cropBox(4) = regionStats.BoundingBox(4) +20;
regionSinglezoomed = imcrop(regionSingle, cropBox); %not sure if I will use this!
%end

%cropping single region mask
cellMaskzoomed = imcrop(cellMask, cropBox);
%end

%% Hough Transform
%calculating the hough circles areas in single region (single cell cluster)
[centers, radii] = imfindcircles(regionSingle, houghCircleRange,'Sensitivity',houghSensitivity); % finding circles in single region houghSensitivity = 0.95
h = viscircles(centers, radii,'EdgeColor','b'); %Just to visualize the result in development phase
[houghCentersRowN,houghCentersColN] = size(centers);   %count circle numbers by counting the centers
if houghCentersRowN ~= 0
    houghArea = zeros(size(radii));
    for circlei =  1:houghCentersRowN
        houghArea(circlei) = pi*((radii(circlei))^2);%calculate the area by pi*r^2 formula
    end
else houghArea = 0;
end

%% Watershed Analysis
% This can be a seperate function.



wsbinarry = cellclusterwatershed(regionSinglezoomed); % applying Watershed algorithm
cc = bwconncomp(wsbinarry);
NumWatershedRegions = cc.NumObjects;
WatershedRegionsStats = regionprops(cc, 'Area');

%define empty containers
watershedAnalysisResults = struct(  'numObjects',0,...      any subregion
                                    'numRBCs',0,...         any subregion that is larger than 'rbcAreaThreshold'
                                    'numFragments',0,...    any sub-region (object) that is smaller than 'rbcAreaThreshold'
                                    'fragmentIDs',[],...    ID of fregment including the main region ID
                                    'region',struct('regionID',uint16([mainRegionID, 00]),...
                                                    'mask',cellMaskzoomed,... main region mask is used as defualt value
                                                    'cell',regionSinglezoomed,... main region masked image is used as default value
                                                    'isRBC',false));
                               % in this struct, "fagment" means any sub-region (object) that is smaller than 'rbcAreaThreshold' 
                                                %ID = 0 means that watershed algorithm did not recogonized any regions.

%watershedAnalysisResults.region = struct('id',0,'mask',cellMaskzoomed,'cell',regionSinglezoomed,'GLCMinput',false); %ID = 0 means that watershed algorithm did not recogonized any regions.
fragmentsTotalArea = 0;
% end define empty containers


%assessing watershed regions
if isequal(NumWatershedRegions, 0)
    watershedAnalysisResults.numObjects = 0;
    watershedAnalysisResults.numRBCs = 1; %Watershed algorithm did not recogonized any regions so there should be at least one RBC, because it was a region from final mask.
    watershedAnalysisResults.numFragments = 0;
    watershedAnalysisResults.region = struct(   'regionID',uint16([mainRegionID, 00]),...
                                                'mask',cellMaskzoomed,...
                                                'cell',regionSinglezoomed,...
                                                'isRBC',true);%ID = 0 means that watershed algorithm did not recogonized any regions.
else
    for wscelli = 1:NumWatershedRegions   %investigate each watershed region
        wscellMask = false(size(cellMaskzoomed)); % building a mask the same size as image
        wscellMask(cc.PixelIdxList{wscelli}) = true;% building watershed single cell mask
        wscellMask = imdilate(wscellMask,strel('disk',3)); % dilating the mask to preserve cell image data
        wsregionSingleZoomed = regionSinglezoomed;
        wsregionSingleZoomed(~wscellMask) = NaN; % extracting watershed single cell.
 
        watershedAnalysisResults.region(wscelli).regionID(2) = wscelli;
        watershedAnalysisResults.region(wscelli).mask = wscellMask;
        watershedAnalysisResults.region(wscelli).cell = wsregionSingleZoomed;
        watershedAnalysisResults.region(wscelli).isRBC = true;
        
        if WatershedRegionsStats(wscelli) < rbcAreaThreshold
            watershedAnalysisResults.numFragments = watershedAnalysisResults.numFragments + 1;
            watershedAnalysisResults.fragmentIDs = [watershedAnalysisResults.fragmentIDs,wscelli]; % fragment IDs are stored to be used in sum of fragment areas
            watershedAnalysisResults.region(wscelli).isRBC = false; %fragments are not suitable for GLCM calculation
        end
    end
    %calculating quantity of each type of object.
    watershedAnalysisResults.numObjects = NumWatershedRegions;
    watershedAnalysisResults.numRBCs = watershedAnalysisResults.numObjects - watershedAnalysisResults.numFragments;
    for fragmenti = 1: length(watershedAnalysisResults.fragmentIDs)
        fragmentsTotalArea = fragmentsTotalArea + WatershedRegionsStats(watershedAnalysisResults.fragmentIDs(fragmenti)); %calculate total fragments area.
    end
    
    % In line below integer division of total fragments areas are added
    % to rbc count. maybe it is better to add just number one.
    % !!!!!CHECK!!!!!
    watershedAnalysisResults.numRBCs = watershedAnalysisResults.numRBCs + idivide(int32(fragmentsTotalArea),int32(rbcAreaThreshold));
    %END OF calculating quantity of each type of object.
    
    
end

%% Using Hough and Watershed analysis results and "regionStats" to Decide on RBCs count and image data to use in GLCM calculation

% preparation
switch offsetType
    case 'offset0'
        glcmOffset = [zeros(offsetNumber,1) (1:offsetNumber)'];
    case 'offset45'
        glcmOffset = [(-1:-1:offsetNumber)' (1:offsetNumber)'];
    case 'offset90'
        glcmOffset = [(-1:-1:offsetNumber)' zeros(offsetNumber,1)];
    case 'offset135'
        glcmOffset = [(-1:-1:offsetNumber)' (-1:-1:offsetNumber)'];
    otherwise
        glcmOffset = [(-1:-1:offsetNumber)' (1:offsetNumber)']; % if the offset type is not defined correctly, offset45 is considered
end
        

[regionHoughAreaN, coln] = size(houghArea);
%regionforGLCM = size(houghArea); % Matrix to save GLCM data of each single region in it. ?!!
subAnalysisResults = struct('mainRegionID',mainRegionID,...
                            'numObjects',0,...
                            'numRBCs',0,...
                            'numFragments',0,...
                            'region',struct('rbcID',uint16([mainRegionID, 00]),...
                                            'mask',cellMaskzoomed,...
                                            'cell',regionSinglezoomed,...
                                            'GLCM',[])); %this struct does not include fragment data


%-----------------------
% Analysis
%-----------------------
%No. of Hough Area = 0                                        
if regionHoughAreaN == 0 % This means that the region is probobly a single cell that due to irregular shape or orientation is not a circlular rbc
    subAnalysisResults.numObjects = watershedAnalysisResults.numObjects; %This value can also be '0' and it's an indication of watershed algorithm inability to find any objects.
    subAnalysisResults.numRBCs = watershedAnalysisResults.numRBCs;
    subAnalysisResults.numFragments = watershedAnalysisResults.numFragments;
    if watershedAnalysisResults.numObjects == 0
        subAnalysisResults.region(1).rbcID(2) = 00;  %watershed method is unable to detect any region, so there is just one and it's ID is [mainRegionID, 0]
        subAnalysisResults.region(1).mask = watershedAnalysisResults.region(1).mask;
        subAnalysisResults.region(1).cell = watershedAnalysisResults.region(1).cell;
        subAnalysisResults.numRBCs = 1;
        
        %calculating the GLCM 
        glcms = graycomatrix(watershedAnalysisResults.Region(1).cell, 'offset', glcmOffset);
        glcmStats = graycoprops(glcms,'all');
        subAnalysisResults.region(1).GLCM = glcmStats;
        
        %just for test purpose 
        figure, plot([glcmStats.Correlation]);
        title('Texture Correlation as a function of offset');
        xlabel('Horizontal Offset')
        ylabel('Correlation')
        %end of test
        % END of calculating the GLCM : subAnalysisResults.region(1).GLCM = 
        
    else 
        for watershedObjecti = 1: watershedAnalysisResults.numObjects
            if watershedAnalysisResults.region(watershedObjecti).isRBC == true
                subAnalysisResults.region(watershedObjecti).rbcID = watershedAnalysisResults.region(watershedObjecti).regionID;
                subAnalysisResults.region(watershedObjecti).mask = watershedAnalysisResults.region(watershedObjecti).mask;
                subAnalysisResults.region(watershedObjecti).cell = watershedAnalysisResults.region(watershedObjecti).cell;
            end
        end
    end
%END OF No. of Hough Area = 0      

%No. of Hough Area = 1
elseif regionHoughAreaN == 1 % there at least one RBC
    
    subAnalysisResults.numObjects = watershedAnalysisResults.numObjects; %This value can also be '0' and it's an indication of watershed algorithm inability to find any objects.
    subAnalysisResults.numRBCs = watershedAnalysisResults.numRBCs;
    subAnalysisResults.numFragments = watershedAnalysisResults.numFragments;
    if watershedAnalysisResults.numObjects == 0
        subAnalysisResults.region(1).rbcID(2) = 00;  %watershed method is unable to detect any region, so there is just one and it's ID is [mainRegionID, 0]
        subAnalysisResults.region(1).mask = watershedAnalysisResults.region(1).mask;
        subAnalysisResults.region(1).cell = watershedAnalysisResults.region(1).cell;
        subAnalysisResults.numRBCs = 1;
        
        %calculating the GLCM 
        glcms = graycomatrix(watershedAnalysisResults.Region(1).cell, 'offset', glcmOffset);
        glcmStats = graycoprops(glcms,'all');
        subAnalysisResults.region(1).GLCM = glcmStats;
        
        %just for test purpose 
        figure, plot([glcmStats.Correlation]);
        title('Texture Correlation as a function of offset');
        xlabel('Horizontal Offset')
        ylabel('Correlation')
        %end of test
        % END of calculating the GLCM : subAnalysisResults.region(1).GLCM = 
        
    else 
        for watershedObjecti = 1: watershedAnalysisResults.numObjects
            if watershedAnalysisResults.region(watershedObjecti).isRBC == true
                subAnalysisResults.region(watershedObjecti).rbcID = watershedAnalysisResults.region(watershedObjecti).regionID;
                subAnalysisResults.region(watershedObjecti).mask = watershedAnalysisResults.region(watershedObjecti).mask;
                subAnalysisResults.region(watershedObjecti).cell = watershedAnalysisResults.region(watershedObjecti).cell;
            end
        end
    end
    
    subAnalysisResults.numRBCs = watershedAnalysisResults.numRBCs;
    watershedAnalysisResults.numRBCs = numRBCs + 1; %the region should be tested by watershed algorithm to verify the number of cells
    %next step is calculating the GLCM
%END OF No. of Hough Area = 1

elseif regionHoughAreaN == 2
    dist = sqrt(((centers(1,2) - centers(2,2))^2) + ((centers(1,1) - centers(2,1))^2));
    radiplus = radii(1) + radii(2);
    difference = dist - radiplus;
    distRatio = abs(dist/radiplus);
    isGoodforGLCM = 'yes';% default value
    
    %*****verifing hough transform accuracy
    if difference > 0
        isGoodforGLCM = 'yes'; %check
    elseif difference < 0
        if distRatio <= 0.3 %****important******* check if 0.1 is a good choice!
            watershedAnalysisResults.numRBCs = watershedAnalysisResults.numRBCs + 1; %next step is calculating the GLCM
            %             elseif
        end
    else isequal(difference, 0)
        if regionStats.MinorAxisLength <= (0.1*dist) %check if 0.1*dist is a good choice.
            watershedAnalysisResults.numRBCs = watershedAnalysisResults.numRBCs + 2;
            % define each cell BoundingBox
        else
            watershedAnalysisResults.numRBCs = watershedAnalysisResults.numRBCs + 1;%nest step is calculating the GLCM.
        end
    end
    
    %for houghCirclei = 1:regionHoughAreaN
    
    %compare region area with circle/circles area and decide on number
    %of cells. If there is one cell, accept the ROI of cell from the
    %mask. If there is more use ***OTHER*** method to segment cells.
    
    
    % ****************method 2*****************
    %use watershed to segment cells in ROI. compare it with hough
    %method result and decide on number of cells.
end


%% defineing cell IDs.
end



