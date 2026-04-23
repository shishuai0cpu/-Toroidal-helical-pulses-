function h = plot_skyrmion_sphere(U, V, W, varargin)
% PLOT_SKYRMINION_SPHERE
% 将三维矢量归一化，把终点投到单位球面上，用纬度着色（jet），并绘制半透明灰色球体。
%
% 用法：
%   plot_skyrmion_sphere(U,V,W)
%   plot_skyrmion_sphere(U,V,W,'SphereAlpha',0.25,'MarkerSize',12)
%
% 选项 (Name-Value)：
%   'SphereRes'   球面分辨率 (默认 64)
%   'SphereAlpha' 球面透明度 (默认 0.25)
%   'SphereColor' 球面颜色 (默认 [0.7 0.7 0.7] 灰)
%   'MarkerSize'  散点尺寸 (默认 12)
%   'CLim'        纬度色标范围 [min max]（弧度，默认 [-pi/2, pi/2]）
%
% 输出：
%   h: 结构体（轴、球体、散点、颜色条等句柄）

p = inputParser;
p.addParameter('SphereRes',   64,   @(x)isnumeric(x)&&isscalar(x)&&x>=8);
p.addParameter('SphereAlpha', 0.25, @(x)isnumeric(x)&&isscalar(x)&&x>=0&&x<=1);
p.addParameter('SphereColor', [0.7 0.7 0.7], @(x)isnumeric(x)&&isequal(size(x),[1,3]));
p.addParameter('MarkerSize',  12,   @(x)isnumeric(x)&&isscalar(x)&&x>0);
p.addParameter('CLim',        [],    @(x)isnumeric(x)&&numel(x)==2);
p.parse(varargin{:});
opt = p.Results;

% 向量整理与归一化
U = U(:); V = V(:); W = W(:);
mag = sqrt(U.^2 + V.^2 + W.^2);
ok  = isfinite(mag) & (mag > 0);
Ux = U(ok)./mag(ok);  Uy = V(ok)./mag(ok);  Uz = W(ok)./mag(ok);

% 纬度（弧度）：phi = asin(z) in [-pi/2, +pi/2]
phi = asin(max(-1,min(1, Uz)));   % 数值安全
if isempty(opt.CLim), clim = [-pi/2, +pi/2]; else, clim = opt.CLim; end

% 画布
fig = figure('Color','w');
ax  = axes(fig); hold(ax,'on'); grid(ax,'on'); axis(ax,'equal');
xlabel(ax,'x'); ylabel(ax,'y'); zlabel(ax,'z');
title(ax,'Skyrmion Sphere (points colored by latitude, jet)');

% 半透明灰色球体
[XS,YS,ZS] = sphere(opt.SphereRes);
surf(ax, XS, YS, ZS, ...
     'FaceColor', opt.SphereColor, ...
     'FaceAlpha', opt.SphereAlpha, ...
     'EdgeColor', 'none', ...
     'HandleVisibility','off');

% 在球面上标记归一化终点，颜色=纬度phi（用 jet）
cmap = jet(256); colormap(ax, cmap);
sc = scatter3(ax, Ux, Uy, Uz, opt.MarkerSize, phi, 'filled', 'MarkerEdgeColor','none');

% 颜色条（标注纬度）
cb = colorbar(ax);
cb.Label.String = 'Latitude \phi (rad)';
if ~isempty(clim), caxis(ax, clim); end

% 可选：辅佐网格（纬线/经线）
% [可按需添加]

% 输出句柄
h = struct('ax',ax,'sphere',gca,'scatter',sc,'colorbar',cb, ...
           'Ux',Ux,'Uy',Uy,'Uz',Uz,'phi',phi,'clim',clim);
end
