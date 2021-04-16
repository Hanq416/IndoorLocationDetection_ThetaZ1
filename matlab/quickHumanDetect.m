% quick object detection
function objView = quickHumanDetect(I1,I2,hmf,dkey)
dif3 = imabsdiff(I1,I2); J3 = single(rgb2gray(dif3));
Ib3 = imgaussfilt(uint8(J3.^2),6);Ib3(Ib3<210) = 0;
bw3 = imbinarize(Ib3); hm_filt = bwareafilt(bw3,hmf); 
hm_de = regionprops('table',hm_filt,'Centroid',...
    'MajorAxisLength','MinorAxisLength'); cen = round(hm_de.Centroid);
if size(cen,1) < 1
    uiwait(msgbox('No moving pattern detected!','Warning','warn'));
    objView = 0; return;
end
[by,bx] = size(Ib3); xp = round(bx/2); yp = round(by/2);
objView(:,1) = round(abs(cen(:,1)-xp)./bx.*360.*(-(cen(:,1)-xp)./abs(cen(:,1)-xp)));
objView(:,2) = round(abs(cen(:,2)-yp)./by.*180.*((cen(:,2)-yp)./abs(cen(:,2)-yp)));
if dkey
    hm_display(hm_de,dif3);
end
end

function hm_display(stats,dif3)
figure(3); imshow(dif3);axis on;
for j = 1:size(stats,1)
    rectangle('Position',[round(stats.Centroid(j,1)-stats.MinorAxisLength(j)./2),...
        round(stats.Centroid(j,2)-stats.MajorAxisLength(j)./5.*3),...
        round(stats.MinorAxisLength(j)),round(stats.MajorAxisLength(j))],...
        'edgeColor','Green','LineWidth',1.75,'LineStyle','--');
    drawcircle('Center',[round(stats.Centroid(j,1)),round(stats.Centroid(j,2))],...
        'Radius',round(stats.MinorAxisLength(j)),'Color',rand(1,3));
    drawcircle('Center',[round(stats.Centroid(j,1)),round(stats.Centroid(j,2))],...
        'Radius',round(stats.MinorAxisLength(j)./20),'Color','Red');
end
end