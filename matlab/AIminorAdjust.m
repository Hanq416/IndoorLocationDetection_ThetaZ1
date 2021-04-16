% get human stand-point from AI scanned view
% for minor adjustment
% hgf is human ground point factor, 0.9 to 0.95.
function [currX, currY, HmD] = AIminorAdjust(hgf,imgp,origV,ang1,ang2,fov,eye_estkey)
HmD = imgaussfilt(rgb2gray(imabsdiff(imgp,origV)),4); %4
HmD = uint8(double(HmD).^(2)); HmD(HmD < 150) = 0; % 140,2
HmD = imbinarize(HmD,0); [deRec(:,1), deRec(:,2)] = find(HmD == 1);
xmaxlim = prctile(deRec(:,2),98); xminlim = prctile(deRec(:,2),2);
ymaxlim = prctile(deRec(:,1),98); yminlim = prctile(deRec(:,1),2);
hpx = round((xmaxlim + xminlim)/2);hpy = round(yminlim+(ymaxlim - yminlim).*hgf);
fprintf('\npixel location of deteted person stand-point:\n X: %d\n Y: %d \n', hpx, hpy);
imshow(HmD); cx = size(imgp,1); 
xf = 2*((hpx-1)/(cx-1)-0.5); yf = 2*((hpy-1)/(cx-1)-0.5); 
[xe,ye] = fish2equ(xf,yf,ang1,ang2,0,fov);
Xe = round((xe+1)/2*(2*cx-1)+1); Ye = round((ye+1)/2*(cx-1)+1);
currX = -round((Xe-cx)/cx*180); currY = round((Ye-cx/2)/cx*180,2);
fprintf('\nCurrent view:\n Horizontal: %d\n Vertical: %d \n', ang2, ang1);
fprintf('Angle offset:\n Angle_offset_H: %d\n Angle_offset_V: %.2f \n',...
    round(currX-ang2), round(currY-ang1));
fprintf('New view:\n Horizontal: %d\n Vertical: %d \n', currX, round(currY));
%% optional function to estimate human eye loacation
if eye_estkey
    eyeY = eyeLocation(cx,0.05,ang1,ang2,fov,xminlim,xmaxlim,yminlim,ymaxlim);
    fprintf('[optional]\nVeritcal angle of human eye (deg): %d\n',round(eyeY));
end
end

function [xe,ye] = fish2equ(xf,yf,roll,tilt,pan,fov)
thetaS=atan2d(yf,xf);phiS=sqrt(yf.^2+xf.^2)*fov/2;sindphiS=sind(phiS);
xs=sindphiS.*cosd(thetaS); ys = sindphiS.*sind(thetaS); zs = cosd(phiS);
xyzsz=size(xs);xyz = xyzrotate([xs(:),ys(:),zs(:)],[roll tilt pan]);
xs=reshape(xyz(:,1),xyzsz(1),[]); ys = reshape(xyz(:,2),xyzsz(1),[]);
zs=reshape(xyz(:,3),xyzsz(1),[]);
thetaE = atan2d(xs,zs); phiE=atan2d(ys,sqrt(xs.^2+zs.^2));
xe = thetaE/180; ye = 2*phiE/180;
end

function [xyznew] = xyzrotate(xyz,thetaXYZ)
tX =  thetaXYZ(1); tY =  thetaXYZ(2); tZ =  thetaXYZ(3);
T = [ cosd(tY)*cosd(tZ),- cosd(tY)*sind(tZ), sind(tY); ...
      cosd(tX)*sind(tZ) + cosd(tZ)*sind(tX)*sind(tY), cosd(tX)*cosd(tZ) - sind(tX)*sind(tY)*sind(tZ), -cosd(tY)*sind(tX); ...
      sind(tX)*sind(tZ) - cosd(tX)*cosd(tZ)*sind(tY), cosd(tZ)*sind(tX) + cosd(tX)*sind(tY)*sind(tZ),  cosd(tX)*cosd(tY)];
xyznew = xyz*T;
end

function [eyeY] = eyeLocation(cx,ehf,ang1,ang2,fov,xmin,xmax,ymin,ymax)
epx = round((xmax + xmin)/2); epy = round(ymin+(ymax-ymin).*ehf);
xf = 2*((epx-1)/(cx-1)-0.5); yf = 2*((epy-1)/(cx-1)-0.5);
[~,ye] = fish2equ(xf,yf,ang1,ang2,0,fov);Ye = round((ye+1)/2*(cx-1)+1);
eyeY = round((Ye-cx/2)/cx*180,2);
end