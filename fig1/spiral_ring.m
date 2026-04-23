clc; clear; close all;

R = 2;      % 甜甜圈大半径（圆心到管中心的距离）
r = 0.6;    % 管子的小半径

% 圆环面参数
nu = 80;    % u 方向网格数
nv = 40;    % v 方向网格数

[u, v] = meshgrid(linspace(0, 2*pi, nu), linspace(0, 2*pi, nv));

X = (R + r .* cos(v)) .* cos(u);
Y = (R + r .* cos(v)) .* sin(u);
Z =  r .* sin(v);

figure
surf(X, Y, Z, 'FaceColor', [0.1 0.9 0.1], 'EdgeColor', 'none');  % 灰色面
% shading interp;
alpha(0.5);               % 透明度
hold on;
axis equal;
axis off;
camlight headlight;
lighting gouraud;

% p：沿着环绕大圆方向的绕圈数
% q：沿着小圆截面方向的绕圈数
p = 1;    % 可以改成 2,3,4 等
q = 10;

t = linspace(0, 2*pi, 1000);   % 参数（完整一圈闭合）

u_line = p * t;
v_line = q * t;

x_line = (R + r .* cos(v_line)) .* cos(u_line);
y_line = (R + r .* cos(v_line)) .* sin(u_line);
z_line =  r .* sin(v_line);

plot3(x_line, y_line, z_line, 'k', 'LineWidth', 2);  % 黑色粗线

title('圆环面上的闭合螺旋曲线');
view(35, 25);  % 调整视角
