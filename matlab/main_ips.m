clear all; %#ok<*CLALL>
close all; %#ok<*CLALL>
clc; %#ok<*CLALL>
% Simple Indoor Positioning System with ThetaZ1 (SIPS)
% Hankun Li, 03/18/2021
% Github: https://github.com/Hanq416
%
%% Machine Value, be sure check these if scenario changed.%%
fov = 90; % specify Field of Vision for view-finder.
cam_h = 7; % camera height,in ft.
sc = 1; % specify compression ratio, optional
% ... END ... %
%% STEP 1 load two continously captured panoramic images
uiwait(msgbox('Load FIRST equalrectangular pano image','File Load'));
[fn,pn]=uigetfile('*.jpg','Select #1 equalrectangular panoramic image');
str=[pn,fn]; I1 = imread(str); clear pn fn str;
uiwait(msgbox('Load SECOND equalrectangular pano image','File Load'));
[fn,pn]=uigetfile('*.jpg','Select #2 equalrectangular panoramic image');
str=[pn,fn]; I2 = imread(str); clear pn fn str;

%% Image can be resized here for running efficiency, both I1 & I2
if ~ismember(sc, [0, 1])
    I1 = imresize(I1, 1/sc); I2 = imresize(I2, 1/sc);
end

%% preview images
figure(1); 
sb1 = subplot(2,1,1); image(I1); axis equal tight; grid on;
sb1.Position = sb1.Position.*[0.6 0.88 1.2 1.2];
sb2 = subplot(2,1,2);image(I2); axis equal tight; grid on;
sb2.Position = sb2.Position.*[0.6 0.5 1.2 1.2];
clear sb1 sb2;

%% Step 2 human find (finalized function) 
hmView = quickHumanDetect(I1,I2,4,1);
if hmView
    fprintf('View of object detected\nNotes: positive number, X: clock-wise, Y: looking down\n')
    for i = 1: size(hmView,1)
        fprintf('DP_%d, [X]: %d (deg), [Y]: %d (deg)\n',i, hmView(i,1), hmView(i,2));
    end
end
clear i;

%% STEP 3 Find view with specified angle
[IF,ang1,ang2] = findView(I2,fov,hmView); %Note: change input here, (panoIMG), I1 or I2.

%% STEP 4 (minor adjustment)
% manual or AI(automatic)
uiwait(msgbox('AI adjustment currently only support one person per view','Notice!','warn'));
yn2 = yn_dialog('[YES] AI ajustment, [NO] manual ajustment');
if ismember(yn2, ['Yes', 'yes']) 
    yn2 = yn_dialog('Save current view for AI detection?');
    if ismember(yn2, ['Yes', 'yes'])
        imgname = append('v_',num2str(ang1),'_h_',num2str(ang2),'.jpg');
        imwrite(IF,imgname); clear imgname;
    end
    uiwait(msgbox('AI detected image ready?','Notice!'));
    [fn,pn]=uigetfile('*.jpg','select an AI detected image');
    str=[pn,fn]; imgp = imread(str); clear pn fn str;
    [currX, currY,hmd] = AIminorAdjust(0.92,imgp,IF,ang1,ang2,fov,0);
else
    [currX, currY] = manualMinorAdj(IF,ang1,ang2,fov);
end

%% output result
if currY > 0
    fprintf('\nOK!');
else
    uiwait(msgbox('Standing point higher than the camera plane','Warning!','warn'));
end
fprintf('\nHuman location:\nDistance to camera: %.2f (ft)\nAngle: %d (deg,[+] is anti-clockwise) \n\n...End...\n',...
    cam_h*tand(90 - abs(currY)), currX);

%% optional 1 using the manual view finder to obtain final view.
[~] = findView(I2,90,0); % I1 or I2

%% optional 2 get height of human eye
eang = input('input the vertical angle of human eye\n');
fprintf('\n height of Human eye: %.2f (ft)\n',cam_h - tand(eang).*cam_h*tand(90 - abs(currY)));
clear eang;
