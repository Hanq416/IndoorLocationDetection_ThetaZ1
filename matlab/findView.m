% find a 180 FOV view with desired target.

function [IF,ang1,ang2] = findView(pano,fov,hmView)
if hmView
    yn2 = yn_dialog('Use the auto view finder?');
    if ismember(yn2, ['Yes', 'yes'])
        [IF,ang1,ang2,handle] = autoFind(pano,fov,hmView);
    else
        [IF,ang1,ang2,handle] = manualFind(pano,fov);
    end
else
    uiwait(msgbox('No moving object found, switch to manual mode','Warning','warn'));
    [IF,ang1,ang2,handle] = manualFind(pano,fov);
end
if ~handle
    uiwait(msgbox('No target confirmed, return and change the input Pano.','Warning','warn'));
    close all;
end
end

function [IF,ang1,ang2,handle] = autoFind(pano,fov,hmView)
ct = 1; handle=0;
for j = 1:size(hmView,1)
    ang1 = hmView(j,2); ang2 = hmView(j,1);
    IF = imequ2fish(pano,ang1,ang2,0,fov);
    figure (ct); imshow(IF); [ix,iy] = size(IF(:,:,1));
    c1 = drawcircle('Center',[iy/2,iy/2],'Radius',round(ix/100),'Color','Green');
    c2 = drawcircle('Center',[iy/2,iy/2],'Radius',round(ix/15),'Color','Yellow');
    yn = yn_dialog('Confirm target in this view? (should close to the image center)');
    if ismember(yn, ['Yes', 'yes'])
        handle = 1; return;
    end
    delete(c1); delete(c2); clear c1 c2; 
    ct = ct + 1;
end
    yn = yn_dialog('No target confirmed, try manual mode?');
    if ismember(yn, ['Yes', 'yes'])
        [IF,ang1,ang2,handle] = manualFind(pano,fov);
    end
end

function [IF,ang1,ang2,handle] = manualFind(pano,fov)
ct = 1; handle=0;
while true
    [ang1,ang2] = initial_dialog();
    IF = imequ2fish(pano,ang1,ang2,0,fov);
    figure (ct); imshow(IF); [ix,iy] = size(IF(:,:,1));
    c1 = drawcircle('Center',[iy/2,iy/2],'Radius',round(ix/100),'Color','Green');
    c2 = drawcircle('Center',[iy/2,iy/2],'Radius',round(ix/15),'Color','Yellow');
    yn = yn_dialog('Continue to next input?');
    if ~ismember(yn, ['Yes', 'yes'])
        break;
    end
    delete(c1); delete(c2); clear c1 c2; 
    ct = ct + 1;
end
yn = yn_dialog('Confirm target in this view?');
if ismember(yn, ['Yes', 'yes'])
    handle = 1;
end
end

% Equalrectangular to 180-degree fisheye, [JPEG image version]
% Modified by Hankun Li for KU LRL research use, University of Kansas Aug,18,2020
% Reference: 360-degree-image-processing (https://github.com/k-machida/360-degree-image-processing), GitHub. Retrieved August 18, 2020.
% Copyright of Original Function: Kazuya Machida (2020)

function imgF = imequ2fish(imgE,varargin)
p = inputParser;
addRequired(p,'imgE');
addOptional(p,'roll',  0); % defaul value of roll
addOptional(p,'tilt',  0); % defaul value of tilt
addOptional(p,'pan' ,  0); % defaul value of pan
addOptional(p,'fov' ,  90); % defaul value of fov
parse(p,imgE,varargin{:});
we = size(imgE,2); he = size(imgE,1); ch = size(imgE,3);
wf = round(we/2); hf = he;
roll = p.Results.roll; tilt = p.Results.tilt; 
pan  = p.Results.pan; fov = p.Results.fov;
[xf,yf] = meshgrid(1:wf,1:hf);
xf = 2*((xf-1)/(wf-1)-0.5); yf = 2*((yf-1)/(hf-1)-0.5); 
% Get index of valid fisyeye image area
idx = sqrt(xf.^2+yf.^2) <= 1; xf = xf(idx); yf = yf(idx);
[xe,ye] = fish2equ(xf,yf,roll,tilt,pan,fov);
Xe = round((xe+1)/2*(we-1)+1); % rescale to 1~we
Ye = round((ye+1)/2*(he-1)+1); % rescale to 1~he
Xf = round((xf+1)/2*(wf-1)+1); % rescale to 1~wf
Yf = round((yf+1)/2*(hf-1)+1); % rescale to 1~hf
Ie = reshape(imgE,[],ch); If = zeros(hf*wf,ch,'uint8');
idnf = sub2ind([hf,wf],Yf,Xf);idne = sub2ind([he,we],Ye,Xe);
If(idnf,:) = Ie(idne,:);imgF = reshape(If,hf,wf,3);
end

function [xe,ye] = fish2equ(xf,yf,roll,tilt,pan,fov)
thetaS = atan2d(yf,xf);
phiS = sqrt(yf.^2+xf.^2)*fov/2; sindphiS = sind(phiS);
xs = sindphiS.*cosd(thetaS); ys = sindphiS.*sind(thetaS); zs = cosd(phiS);
xyzsz = size(xs);
xyz = xyzrotate([xs(:),ys(:),zs(:)],[roll tilt pan]);
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