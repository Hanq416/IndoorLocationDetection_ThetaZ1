clear all; %#ok<*CLALL>
close all; %#ok<*CLALL>
clc; %#ok<*CLALL>
% Simple Indoor Positioning System with Theta (SIPS)
% Hankun Li, 03/18/2021
% Github: https://github.com/Hanq416
% 
%% STEP 1
[fn,pn]=uigetfile('*.jpg','select a equalrectangular panoramic image');
str=[pn,fn]; I1 = imread(str);
[fn,pn]=uigetfile('*.jpg','select a equalrectangular panoramic image');
str=[pn,fn]; I2 = imread(str);
%%
figure(1); imshow(I1);
figure(2); imshow(I2);
%% human find (finalized function)
hmView = quickHumanDetect(I1,I2, 2);
%%
fprintf('View of object detected, notes of positive number,\nX: clock-wise, Y: looking down\n')
for i = 1: size(hmView,1)
    fprintf('DP_%d, [X]: %d (deg), [Y]: %d (deg)\n',i, hmView(i,1), hmView(i,2));
end

%% STEP 2
[fn,pn]=uigetfile('*.jpg','select a equalrectangular panoramic image');
str=[pn,fn]; pano = imread(str); fprintf('PANO loaded!\n\n');
%% FIND VIEW
ct = 1;
while true
    [ang1,ang2] = initial_dialog();
    IF = imequ2fish(pano,ang1,ang2,0);
    figure (ct); imshow(IF); [ix,iy] = size(IF(:,:,1));
    c1 = drawcircle('Center',[iy/2,iy/2],'Radius',round(ix/100),'Color','Green');
    c2 = drawcircle('Center',[iy/2,iy/2],'Radius',round(ix/15),'Color','Yellow');
    yn = yn_dialog('Continue to your next selection?');
    if ~ismember(yn, ['Yes', 'yes'])
        delete(c1); delete(c2); clear c1 c2; 
        break;
    end
    delete(c1); delete(c2); clear c1 c2; 
    ct = ct + 1;
end
%% export view for AI recognition, optional
imgname = append('h_',num2str(ang1),'_v_',num2str(ang2),'.jpg');
imwrite(IF,imgname);

%% STEP 3
% offset aiming point to people postion (minor adjustment)
%% load AI detected image
[fn,pn]=uigetfile('*.jpg','select a detected image');
str=[pn,fn]; imgp = imread(str);
%%
%debug usage
imgp = IF;
%%
cx = size(imgp(:,:,1),1); roi_flg = 1;
icy = round(cx/2); icx = icy; 
yn1 = yn_dialog('[YES] use ROI selection, [NO] input pixel coordinate');
if ~ismember(yn1, ['Yes', 'yes'])
    roi_flg = 0;
end
if roi_flg
    [x_p, y_p] = roi_select(imgp);
else
    x_p = input('X: location of stand point?\n');
    y_p = input('Y: location of stand point?\n');
end
x_off = x_p - icx; y_off = y_p - icy;
xa_off = -round((x_off./abs(x_off)).*abs(x_off)/ix*180);
ya_off = round((y_off./abs(y_off)).*abs(y_off)/ix*180);
fprintf('\nCurrent view:\n Horizontal: %d\n Vertical: %d \n', ang2, ang1);
fprintf('Angle offset:\n Angle_offset_H: %d\n Angle_offset_V: %d \n', xa_off, ya_off);

%% STEP 4
cam_h = 7; %camera height,in ft
%
if ang1 + ya_off > 0
    fprintf('\nOK!\n');
else
    msgbox('Standing point higher than camera plane!','Error','error'); close(gcf);
    error('Error_001: check original image!');
end
c2o_d = cam_h*tand(90 - abs(ang1+ya_off));
fprintf('\nStanding point:\nDistance to camera: %.2f (ft)\nAngle: %d (anti-clock-wise) \nEnd\n', c2o_d, (ang2+xa_off));