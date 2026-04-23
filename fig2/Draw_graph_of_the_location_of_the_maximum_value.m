clear all, close all; clc

load('E:\工作\硕士阶段文章\文章\螺旋喇叭\内容提交\上传\fig2\扩散速度.mat')
ccc=[116,169,197;194,229,207;237,221,171;221,115,137];
ccc=ccc/256;


re1=nihe(a1,ccc(1,:),1,5,1);
re2=nihe(a2,ccc(2,:),1,5,1);
re3=nihe(a3,ccc(3,:),1,3,1);
re4=nihe(a4,ccc(4,:),1,5,1);

ri1=nihe(b1,ccc(1,:),1,15,2);
ri2=nihe(b2,ccc(2,:),1,5,2);
ri3=nihe(b3,ccc(3,:),1,5,2);
ri4=nihe(b4,ccc(4,:),1,5,2);

meas_theta(:,1)=re1;
meas_theta(:,2)=re2;
meas_theta(:,3)=re3;
meas_theta(:,4)=re4;

meas_rho(:,1)=ri1;
meas_rho(:,2)=ri2;
meas_rho(:,3)=ri3;
meas_rho(:,4)=ri4;
draw(meas_rho(:,1),meas_rho(:,2),meas_rho(:,3),meas_rho(:,4),meas_theta(:,1),meas_theta(:,2),meas_theta(:,3),meas_theta(:,4))



%%
close all
% 如果是 R2020b 及以后版本，直接有 turbo
% 原始 turbo（蓝→青→黄→红）
n = 256;
cmap = turbo(n);

% 将 RGB 转为 HSV
hsv_map = rgb2hsv(cmap);

% 降低饱和度（S 通道）
% ------------- 调整这里 0.6 可改成 0.7 / 0.5 等 -------------
hsv_map(:,2) = hsv_map(:,2) * 0.6;

% 确保饱和度不越界
hsv_map(:,2) = min(max(hsv_map(:,2), 0), 1);

% 转回 RGB
cmap_soft = hsv2rgb(hsv_map);

% 画 colorbar
figure;
imagesc(linspace(0,1,n));
colormap(cmap_soft);

ax = gca;
ax.YTick = [];
ax.XTick = [];



xlim([15,241])

%%
function draw(ri1,ri2,ri3,ri4,re1,re2,re3,re4)
mx=1;TMf=zeros(4);
count=0;
for iii=1:2:length(re1)-2
    count=count+1;
% ri=[ri1(iii) ri2(iii) ri3(iii) ri4(iii)];
% re=[re1(iii) re2(iii) re3(iii) re4(iii)];


% 
ri=[ri1(iii) ri2(iii) ri3(iii) ri4(iii) ];
re=[ri1(iii+3) ri2(iii+3) ri3(iii+3) ri4(iii+3)];

% 
% ri=[re1(iii) re2(iii) re3(iii) re4(iii) ];
% re=[re1(iii+3) re2(iii+3) re3(iii+3) re4(iii+3)];
[F(count),C_theta(count),E_theta(count),TMe,DMe,TMi]=Fidelity(ri,re);
TMf=TMf+TMe;
end

Ffinal=mean(F(2:end-1))

figure;imagesc(TMf);axis equal;axis tight;
title('Experimental state tomography')
set(gcf,'Position',[500 500 300 300])


C_1=[77,154,199]/256;
C_2=[214,96,77]/256;

figure
plot(E_theta,'Color',C_1,"LineWidth",5)
hold on
plot(C_theta,'Color',C_2,"LineWidth",5)
hold on
% plot(E_fit,'Color','r')
% h                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            old on
% plot(C_fit,'Color','b')
% hold on
ylim([0,1])


clear E C  E_fit C_fit
mx=1;TMf=zeros(4);
count=0;
for iii=1:2:length(re1)-2
    count=count+1;
% ri=[ri1(iii) ri2(iii) ri3(iii) ri4(iii)];
% re=[re1(iii) re2(iii) re3(iii) re4(iii)];


% 
% ri=[ri1(iii) ri2(iii) ri3(iii) ri4(iii) ];
% re=[ri1(iii+3) ri2(iii+3) ri3(iii+3) ri4(iii+3)];


ri=[re1(iii) re2(iii) re3(iii) re4(iii) ];
re=[re1(iii+3) re2(iii+3) re3(iii+3) re4(iii+3)];
[F(count),C_rho(count),E_rho(count),TMe,DMe,TMi]=Fidelity(ri,re);
TMf=TMf+TMe;
end

Ffinal=mean(F(2:end-1))

figure;imagesc(TMf);axis equal;axis tight;
title('Experimental state tomography')
set(gcf,'Position',[500 500 300 300])


figure(3)
plot(E_rho,'Color',C_1,'LineStyle','--',"LineWidth",5)
hold on
plot(C_rho,'Color',C_2,'LineStyle','--',"LineWidth",5)
hold on
ylim([0,1])
%  plot(E_fit,'Color','r')
% hold on
% plot(C_fit,'Color','b')
% hold on
end

function re1=nihe(a1,ccc,ddd,windowSize,eee)

% plot(10:110,a1,'ob','linewidth',3)
% x=11:80;
% x=x';
% y=a1;
% p=fittype('a*x+b')  
% 
% f=fit(x,y,p)  
% % figure, plot(f,x,y);
% xi=11:80 ;
% re1=f(xi);
re1 = movmean(a1, windowSize);
 

figure(ddd)
if  eee==1
plot(11:80,re1,"Color",ccc,"LineWidth",5);
else 
plot(11:80,re1,"Color",ccc,"LineStyle","--","LineWidth",5);
    
end

hold on
ylim([0,35])



end

function re1=nihe2(a1,ccc,ddd,eee)

% plot(10:110,a1,'ob','linewidth',3)
x=11:80;
x=x';
y=a1;
p=fittype('a*sqrt(1+((x-b)/c)^2)')  
% p=fittype('a*x+b')  

f=fit(x,y,p)  
% figure, plot(f,x,y);
xi=11:80;
re1=f(xi);
figure(ddd)
if eee==1
plot(xi,f(xi),"Color",ccc,"LineWidth",5);
else
plot(xi,f(xi),"Color",ccc,"LineStyle","--","LineWidth",5);
    
end
% plot(x,y,"Color",ccc,"Marker","*");
hold on
ylim([0,35])


end

function re1=nihe_c(y)
p=fittype('a*exp(b*x+c)+d;') ; 
x=linspace(1,34,length(y));
x=x';
y=y';
f=fit(x,y,p, 'StartPoint', [-1, -1,1,1]) 
xi=1:34;
re1=f(xi);

end


