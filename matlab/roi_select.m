%get the offset of the standing point with ROI selection
function [cx, cy] = roi_select(img_p)
img_p = rgb2gray(img_p);
figure(1);ROI = roipoly(img_p);close(gcf);lookup = []; 
if isempty(ROI)
    msgbox('No ROI selected!','Error','error'); close(gcf);
    error('Error_003: no ROI selected, try again!'); return; %#ok<*UNRCH>
end
[lookup(:,2),lookup(:,1)] = find(ROI);
cy = round(mean(lookup(:,2))); cx = round(mean(lookup(:,1)));
end