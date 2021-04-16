% manual select, and get human stand point
function [currX, currY] = manualMinorAdj(imgp,ang1,ang2,fov)
cx = size(imgp,1); roi_flg = 1;
yn1 = yn_dialog('[YES] use ROI selection, [NO] input pixel coordinate(not common)');
if ~ismember(yn1, ['Yes', 'yes'])
    roi_flg = 0;
end
if roi_flg
    [x_p, y_p] = roi_select(imgp);
else
    x_p = input('X: location of stand point?\n');
    y_p = input('Y: location of stand point?\n');
end
xf = 2*((x_p-1)/(cx-1)-0.5); yf = 2*((y_p-1)/(cx-1)-0.5); 
[xe,ye] = fish2equ(xf,yf,ang1,ang2,0,fov);
Xe = round((xe+1)/2*(2*cx-1)+1); Ye = round((ye+1)/2*(cx-1)+1);
currX = -round((Xe-cx)/cx*180); currY = round((Ye-cx/2)/cx*180,2);
fprintf('\nCurrent view:\n Horizontal: %d\n Vertical: %d \n', ang2, ang1);
fprintf('Angle offset:\n Angle_offset_H: %d\n Angle_offset_V: %.2f \n',...
    round(currX-ang2), round(currY-ang1));
fprintf('New view:\n Horizontal: %d\n Vertical: %d \n', currX, round(currY));
end

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

function [xe,ye] = fish2equ(xf,yf,roll,tilt,pan,fov)
thetaS=atan2d(yf,xf);phiS=sqrt(yf.^2+xf.^2)*fov/2;sindphiS=sind(phiS);
xs = sindphiS.*cosd(thetaS); ys = sindphiS.*sind(thetaS); zs = cosd(phiS);
xyzsz = size(xs);xyz = xyzrotate([xs(:),ys(:),zs(:)],[roll tilt pan]);
xs = reshape(xyz(:,1),xyzsz(1),[]); ys = reshape(xyz(:,2),xyzsz(1),[]);
zs = reshape(xyz(:,3),xyzsz(1),[]);
thetaE = atan2d(xs,zs); phiE   = atan2d(ys,sqrt(xs.^2+zs.^2));
xe = thetaE/180; ye = 2*phiE/180;
end

function [xyznew] = xyzrotate(xyz,thetaXYZ)
tX =  thetaXYZ(1); tY =  thetaXYZ(2); tZ =  thetaXYZ(3);
T = [ cosd(tY)*cosd(tZ),- cosd(tY)*sind(tZ), sind(tY); ...
      cosd(tX)*sind(tZ) + cosd(tZ)*sind(tX)*sind(tY), cosd(tX)*cosd(tZ) - sind(tX)*sind(tY)*sind(tZ), -cosd(tY)*sind(tX); ...
      sind(tX)*sind(tZ) - cosd(tX)*cosd(tZ)*sind(tY), cosd(tZ)*sind(tX) + cosd(tX)*sind(tY)*sind(tZ),  cosd(tX)*cosd(tY)];
xyznew = xyz*T;
end