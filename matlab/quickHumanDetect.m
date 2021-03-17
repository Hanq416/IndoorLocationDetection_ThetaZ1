
function humanView = quickHumanDetect(I1,I2, hm_num)
%% quick find
dif3 = imabsdiff(I1,I2);J3 = single(rgb2gray(dif3));
gm = 2; J3 = uint8(J3.^gm); Ib3 = imgaussfilt(J3,10); Ib3(Ib3<230) = 0;
bw3 = imbinarize(Ib3); hm_filt = bwareafilt(bw3,hm_num); 
hm_de = regionprops('table',hm_filt,'Centroid',...
    'MajorAxisLength','MinorAxisLength');
hm_display(hm_de,dif3);
%% get human view
cen = round(hm_de.Centroid); [by,bx] = size(Ib3);
xp = round(bx/2); yp = round(by/2);
humanView(:,1) = round(abs(cen(:,1)-xp)./bx.*360.*(-(cen(:,1)-xp)./abs(cen(:,1)-xp)));
humanView(:,2) = round(abs(cen(:,2)-yp)./by.*180.*((cen(:,2)-yp)./abs(cen(:,2)-yp)));
end

function hm_display(stats,dif3)
figure(3); imshow(dif3);
for j = 1:size(stats,1)
    drawcircle('Center',[round(stats.Centroid(j,1)),round(stats.Centroid(j,2))],...
        'Radius',round(stats.MinorAxisLength(j)),'Color','Yellow');
    drawcircle('Center',[round(stats.Centroid(j,1)),round(stats.Centroid(j,2))],...
        'Radius',round(stats.MinorAxisLength(j)./20),'Color','Red');
end
end