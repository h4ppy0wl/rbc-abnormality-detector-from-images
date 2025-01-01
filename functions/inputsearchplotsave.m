function result = inputsearchplotsave(PLOTAXIS,imageDirectory,fileName,x,yt,yc,X,Y, axtitle)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

f = figure();
f.Visible = 'off';
f.WindowState = 'maximized';

plot(x,yt,'-b',x,yc,'-r',x,yt,'ob',x,yc,'*r',X,Y,'g')
lgd = legend({'Training Error', 'Checking Error'},'Location','best');
f.CurrentAxes.YLabel.String = PLOTAXIS.YLabel.String;
f.CurrentAxes.TickLength = [0 0];
f.CurrentAxes.YLabel.FontSize = PLOTAXIS.YLabel.FontSize;
f.CurrentAxes.XLabel.String = PLOTAXIS.XLabel.String;
f.CurrentAxes.XAxis.FontSize = 9;
f.CurrentAxes.Title.String = string(axtitle);
f.CurrentAxes.Title.FontSize = 9;
if max(x)==1
    XLlim = 0;
    XHlim = 2;
else
    XLlim = 1;
    XHlim = max(x);
end
f.CurrentAxes.XLim = [XLlim XHlim];
%f.CurrentAxes.YLim = [1 max(max(yt,yc))+1];


f.CurrentAxes.XTickLabelRotation = PLOTAXIS.XTickLabelRotation ;
f.CurrentAxes.TickDir = PLOTAXIS.TickDir ;
f.CurrentAxes.XTickMode = PLOTAXIS.XTickMode ;
f.CurrentAxes.XTickLabelMode = PLOTAXIS.XTickLabelMode;
f.CurrentAxes.XTick = 1:1:size(yt,1);
f.CurrentAxes.XTickLabel = (PLOTAXIS.XTickLabel)';
f.CurrentAxes.TitleFontSizeMultiplier = 0.75;
fullfileName = fullfile(imageDirectory,fileName);
saveas(f,fullfileName,'png');
delete(f);
result = true;            

%== plot file name
% imageFileName = [imageTempDirectory,fisLayer,inputRange,in_n];
% print imageFileName '-dpng';
end

