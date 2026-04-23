clc
clear 
close all
load(['E:\工作\硕士阶段文章\文章\螺旋喇叭\内容提交\上传\fig3\45度斯格名子\45度斯格名子.mat'])
aee=0;


i=45;



x=0.1:0.1:120.1-0.1*aee;
x=x*0.01;
% y=0:50;
y=0:-1:-50;
y=y*0.01;

[X,Y] = meshgrid(x,y);

xx=0.1:0.01:120.1-0.1*aee;
xx=xx*0.01;
yy=0:-0.1:-50;
yy=yy*0.01;

[XX,YY] = meshgrid(xx,yy);

draw_rho_fix=draw_rho;
draw_theta_fix=draw_theta;
draw_z_fix=draw_z;


draw_rho_fix=interp2(X,Y,draw_rho_fix,XX,YY);
draw_theta_fix=interp2(X,Y,draw_theta_fix,XX,YY);
draw_z_fix=interp2(X,Y,draw_z_fix,XX,YY);


em=sqrt(draw_rho_fix.^2+draw_theta_fix.^2+draw_z_fix.^2);



%%
clc
close all
def=5500+523;
ez_x=draw_z_fix(500:-1:1,def)./em(500:-1:1,def);
[~,aaa]=min(ez_x);

erho=draw_rho_fix(500:-1:500-aaa,def)./em(500:-1:500-aaa,def);
etheta=draw_theta_fix(500:-1:500-aaa,def)./em(500:-1:500-aaa,def);
ez=draw_z_fix(500:-1:500-aaa,def)./em(500:-1:500-aaa,def);
r=-yy(1:aaa+1);

plot(r,ez)



%%


S = sample_axisym_from_radial_line(r, erho, etheta, ez, ...
    'Seed', 1, ...
    'RRange', [0, max(r)], ...
    'Interp', 'pchip', ...
    'AlphaCounts', [100 200 200 600 600 20 5 3 1], ...
    'AlphaEdges', linspace(-pi/2, pi/2, 10), ...
    'RGridN', 4000);

% %% 
figure
set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);
quiver3_color_angle(S.X, S.Y, S.Z, S.Ex, S.Ey, S.Ez, ...
    'Scale', 0.015, ...
    'LineWidth', 2, ...
    'MaxHeadSize', 10, ...
    'Colormap', jet(256));


view(-18,34)

xlim([-0.18 0.18]);
ylim([-0.18 0.18]);

% 设置 x、y 刻度
xticks([-0.15 0 0.15]);
yticks([-0.15 0 0.15]);

% 隐藏 z 轴
set(gca, 'ZTick', []);     % 不显示刻度
set(gca, 'ZColor', 'none'); % 不显示轴线和标签

hX =xlabel('\it{x}\rm{/m}', 'FontName', 'Times New Roman', 'FontSize', 84);
hY =ylabel('\it{y}\rm{/m}', 'FontName', 'Times New Roman', 'FontSize', 84);

% 轴刻度字体也改成 Times New Roman 和大字号
set(gca, 'FontName', 'Times New Roman', 'FontSize', 84);
colorbar off;

% ---- 删除 title（若之前添加过）----
title('');

pos = get(hY, 'Position');  % pos = [x y z]
pos(2) = -0.1;  
pos(3) = 0.0;  
pos(1) =-0.26;% 把标签的 y 位置设为 0
set(hY, 'Position', pos);
set(hX, 'Rotation', 10);
set(hY, 'Rotation', -63);


% 
pos = get(hX, 'Position');  % pos = [x y z]
pos(2) = -0.28;  
pos(3) =0;  
pos(1) = -0.015;  
set(hX, 'Position', pos);
set(hX, 'Rotation', 10);

%% 


S = sample_axisym_from_radial_line(r, erho, etheta, ez, ...
    'Seed', 1, ...
    'RRange', [0, max(r)], ...
    'Interp', 'pchip', ...
    'AlphaCounts', [10 30 100 200 500 200 100 30 10], ...
    'AlphaEdges', linspace(-pi/2, pi/2, 10), ...
    'RGridN', 4000);


% 假设 S 是你“旋转+随机采样”的结果，包含 S.Ex, S.Ey, S.Ez
figure
plot_skyrmion_sphere(S.Ex, S.Ey, S.Ez, ...
    'SphereAlpha', 0.3, ...
    'MarkerSize', 60);
set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);


demo_axis_arrows

view(48,33)
% ==== 光照（写在外面）====
ax = gca;

% 选择光照算法（推荐 gouraud）
lighting(ax, 'gouraud');

% 球体材质
material(ax, 'dull');    % 可选 shiny / metal / dull

% 添加两盏灯
camlight(ax, 'headlight');      % 跟随相机的主灯
camlight(ax, -48, 33);          % 一个侧向补光
set(gca,'Visible','off')
% 可选：调节反射强度（如果版本支持）
try
    ax.AmbientLightColor = [1 1 1]*0.3;
    ax.Children(1).AmbientStrength  = 0.3;
    ax.Children(1).DiffuseStrength  = 0.7;
    ax.Children(1).SpecularStrength = 0.2;
    ax.Children(1).SpecularExponent = 20;
catch
end
colorbar off;

% end