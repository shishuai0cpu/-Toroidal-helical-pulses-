
function h = quiver3_color_angle(X, Y, Z, U, V, W, varargin)
% QUIVER3_COLOR_ANGLE  绘制颜色与仰角(与z轴夹角)映射的三维箭头
%
% 用法：
%   quiver3_color_angle(X,Y,Z,U,V,W)
%   quiver3_color_angle(..., 'Scale', s)
%   quiver3_color_angle(..., 'Colormap', cmap)
%
% 说明：
%   - 颜色由仰角 α = atan2(W, sqrt(U^2 + V^2)) 确定。
%   - 默认使用 jet(256) 色图，可通过 'Colormap' 参数自定义。
%   - 每个箭头都是单独对象，适合几百~几千个箭头。
%
% 参数（Name-Value）：
%   'Scale'       ：整体缩放比例（默认 1）
%   'LineWidth'   ：箭头线宽（默认 0.8）
%   'MaxHeadSize' ：箭头头部大小（默认 0.5）
%   'Colormap'    ：色图矩阵（默认 jet(256)）
%   'CLim'        ：颜色范围 [αmin αmax]（默认自动）
%
% 输出：
%   h ：quiver 对象句柄数组（每个箭头一个）
%
% 作者：ChatGPT (2025)
% -------------------------------------------------------------------------

% 参数解析
p = inputParser;
p.addParameter('Scale', 1, @(x)isnumeric(x)&&isscalar(x));
p.addParameter('LineWidth', 0.8, @(x)isnumeric(x)&&isscalar(x));
p.addParameter('MaxHeadSize', 0.5, @(x)isnumeric(x)&&isscalar(x));
p.addParameter('Colormap', jet(256), @(x)isnumeric(x)&&size(x,2)==3);
p.addParameter('CLim', [], @(x)isnumeric(x)&&numel(x)==2);
p.parse(varargin{:});
opt = p.Results;
cmap = opt.Colormap;
Nc = size(cmap,1);

% 转为列向量
X = X(:); Y = Y(:); Z = Z(:);
U = U(:); V = V(:); W = W(:);
N = numel(X);

% 仰角 α（弧度）
alpha = atan2(W, hypot(U,V));     % [-pi/2, +pi/2]

if isempty(opt.CLim)
    amin = min(alpha); amax = max(alpha);
else
    amin = opt.CLim(1); amax = opt.CLim(2);
end
alpha_norm = (alpha - amin) / max(amax - amin, eps);
alpha_norm = max(0, min(1, alpha_norm));

% 颜色索引
idx = round(1 + alpha_norm*(Nc-1));
colorList = cmap(idx,:);

% 绘制
hold on
h = gobjects(N,1);
for i = 1:N
    h(i) = quiver3(X(i), Y(i), Z(i), ...
                   U(i)*opt.Scale, V(i)*opt.Scale, W(i)*opt.Scale, ...
                   1, 'AutoScale', 'off', ...
                   'Color', colorList(i,:), ...
                   'LineWidth', opt.LineWidth, ...
                   'MaxHeadSize', opt.MaxHeadSize);
end

% 色条显示
colormap(cmap);
cb = colorbar;
cb.Label.String = 'Elevation angle α (rad)';
cb.Ticks = linspace(0,1,5);
cb.TickLabels = arrayfun(@(t)sprintf('%.2f', amin + t*(amax-amin)), cb.Ticks, 'uni',0);

axis equal
grid on
xlabel('X'); ylabel('Y'); zlabel('Z');
title('3D quiver colored by elevation angle');

end

