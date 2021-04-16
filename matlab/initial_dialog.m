% get viewing direction
function [ans1,ans2] = initial_dialog()
prompt = {'Your selection of vertical angle ?     [-90 to 90 degree]',...
    'Your selection of horizontal angle ? [-180 to 180 degree]'};
dlgtitle = 'User Input'; dims = [1 50];definput = {'0','0'};
answer = str2double(inputdlg(prompt,dlgtitle,dims,definput));
if isempty(answer)
    ans1 = 0; ans2 = 0;
else
    ans1 = answer(1); ans2 = answer(2);
end
end