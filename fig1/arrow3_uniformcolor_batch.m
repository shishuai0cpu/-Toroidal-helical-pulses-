function [hshaft, hhead, hcap_shaft, hcap_head] = arrow3_uniformcolor_batch(X, Y, Z, U, V, W, varargin)
% ARROW3_UNIFORMCOLOR_BATCH
% 批量绘制三维箭头（圆柱+圆锥+端盖），统一尺度，**统一颜色**。
%
% 与 arrow3_hsvcolor_batch_uniform 的区别：
%   - 不再根据方向着色；
%   - 新增参数：'Color'，所有箭头用同一个颜色。
%
% 用法示例：
%   [hS, hH, hCapS, hCapH] = arrow3_uniformcolor_batch(X,Y,Z,U,V,W, ...
%       'Color', [1 0 0], ...               % 统一红色
%       'Length', Lbase, 'Scale', 1.0, ...
%       'Radius', [], 'HeadFrac', 0.25, ...
%       'HeadRadiusFactor', 2.2, 'Facets', 24, ...
%       'EdgeColor', 'none', 'CapEpsilon', 1e-6);
%
% 参数说明（与原函数一致）：
%   'Scale'            : 等比例整体缩放（默认 1.0）
%   'HeadFrac'         : 圆锥长度占比（0~1，默认 0.25）
%   'HeadRadiusFactor' : 圆锥底半径/圆柱半径 的比例（默认 2.2）
%   'Length'           : 基准总长度（默认取非零向量模的中位数）
%   'Radius'           : 基准圆柱半径（默认 0.03 * Length）
%   'Facets'           : 圆周分段（默认 24）
%   'EdgeColor'        : 边线颜色（默认 'none'）
%   'CapEpsilon'       : 端盖错层偏移比例（默认 1e-6）
%   'Color'            : 箭头统一颜色（MATLAB ColorSpec，默认 [0 0 1] 蓝色）
%
% 返回：
%   hshaft    : 圆柱侧壁 patch
%   hhead     : 圆锥侧壁 patch
%   hcap_shaft: 圆柱端盖（底盖+顶盖）patch
%   hcap_head : 圆锥基底盖 patch

% -------- 解析参数 --------
p = inputParser;
p.addParameter('Length', [], @(x)isnumeric(x)&&isscalar(x)&&x>0);                     % 基准总长
p.addParameter('Scale', 1.0, @(x)isnumeric(x)&&isscalar(x)&&x>0);                     % 等比例缩放
p.addParameter('Radius', [], @(x)(isempty(x) || (isnumeric(x)&&isscalar(x)&&x>0)));   % 基准半径
p.addParameter('HeadFrac', 0.25, @(x)isnumeric(x)&&isscalar(x)&&x>0&&x<1);
p.addParameter('HeadRadiusFactor', 2.2, @(x)isnumeric(x)&&isscalar(x)&&x>0);
p.addParameter('Facets', 24, @(x)isnumeric(x)&&isscalar(x)&&x>=6);
p.addParameter('EdgeColor', 'none');
p.addParameter('CapEpsilon', 1e-6, @(x)isnumeric(x)&&isscalar(x)&&x>=0);
p.addParameter('Color', [0 0 1], @(c)(ischar(c) || (isstring(c)) || ...
    (isnumeric(c) && numel(c)==3)));                                                   % 统一颜色

p.parse(varargin{:});
Lbase    = p.Results.Length;
scale    = p.Results.Scale;
Rbase    = p.Results.Radius;
headFrac = p.Results.HeadFrac;
hrf      = p.Results.HeadRadiusFactor;
nfac     = p.Results.Facets;
edgeCol  = p.Results.EdgeColor;
cap_eps  = p.Results.CapEpsilon;
col      = p.Results.Color;       % 统一颜色

% -------- 尺寸对齐 --------
[X,Y,Z,U,V,W] = compatSize(X,Y,Z,U,V,W);
P0  = [X(:) Y(:) Z(:)];
VEC = [U(:) V(:) W(:)];
Ln  = sqrt(sum(VEC.^2,2));
valid = isfinite(Ln) & (Ln>0);
if ~any(valid)
    warning('没有有效的非零向量。');
    hshaft = gobjects(0); hhead = gobjects(0); hcap_shaft=gobjects(0); hcap_head=gobjects(0);
    return;
end
IDX = find(valid);
Nv  = numel(IDX);

% 统一长度（基准）与半径（基准）
if isempty(Lbase), Lbase = median(Ln(valid)); end          % 基准总长
Leff = Lbase * scale;                                      % 有效总长（整体缩放后）
if isempty(Rbase), Rbase = 0.03 * Lbase; end               % 基准半径
Reff = Rbase * scale;                                      % 有效半径（随比例缩放）

% 长度拆分（均按 Leff）
L_shaft = (1 - headFrac) * Leff;
L_head  = headFrac * Leff;
r_shaft = Reff;
r_head  = hrf * r_shaft;                                   % 比例维持

% 方向单位向量
DIR = zeros(Nv,3);
for k = 1:Nv
    i = IDX(k);
    DIR(k,:) = VEC(i,:) / Ln(i);
end

% -------- 模板网格（单位半径、单位高度，z 轴对齐） --------
[csx, csy, csz] = cylinder(1, nfac);           % 圆柱侧壁：r=1, z∈[0,1]
[cnx, cny, cnz] = cylinder([1 0], nfac);       % 圆锥侧壁：底r=1→尖r=0, z∈[0,1]
[Fc, Vc] = surf2patch(csx, csy, csz, 'triangles');
[Fh, Vh] = surf2patch(cnx, cny, cnz, 'triangles');

% 端盖（单位圆盘 z=0 平面，nfac 辐扇三角）
[Fcirc, Vcirc] = unit_disc_fan(nfac);  % Vcirc: (nfac+1)×3, z=0；Fcirc：nfac×3

nVc = size(Vc,1);  nFc = size(Fc,1);
nVh = size(Vh,1);  nFh = size(Fh,1);
nVd = size(Vcirc,1); nFd = size(Fcirc,1);

% 预缩放到“有效尺寸”
S_shaft = diag([r_shaft, r_shaft, L_shaft]);
S_head  = diag([r_head , r_head , L_head ]);
Vc_s    = Vc * S_shaft.';             % 圆柱侧壁 顶点
Vh_s    = Vh * S_head.';              % 圆锥侧壁 顶点

% 端盖缩放：单位圆盘在 z=0
Vcap_shaft_bot_s = Vcirc * diag([r_shaft, r_shaft, 0]);  % 圆柱底盖
Vcap_shaft_top_s = Vcirc * diag([r_shaft, r_shaft, 0]);  % 圆柱顶盖（后移到 L_shaft）
Vcap_head_base_s = Vcirc * diag([r_head , r_head , 0]);  % 圆锥基底盖

% -------- 合并缓冲区（侧壁） --------
V_all_shaft = zeros(nVc*Nv, 3);
F_all_shaft = zeros(nFc*Nv, 3);

V_all_head  = zeros(nVh*Nv, 3);
F_all_head  = zeros(nFh*Nv, 3);

% -------- 合并缓冲区（端盖） --------
V_all_cap_shaft = zeros((2*nVd)*Nv, 3);
F_all_cap_shaft = zeros((2*nFd)*Nv, 3);

V_all_cap_head  = zeros(nVd*Nv, 3);
F_all_cap_head  = zeros(nFd*Nv, 3);

ofsVc = 0; ofsFc = 0;
ofsVh = 0; ofsFh = 0;
ofsVcs = 0; ofsFcs = 0;  % shaft caps
ofsVch = 0; ofsFch = 0;  % head cap

for t = 1:Nv
    i  = IDX(t);
    p0 = P0(i,:);
    d  = DIR(t,:);

    % 把 z 轴旋到方向 d
    R = rotz_to_vec(d);

    % ===== 圆柱侧壁 =====
    Vc_t = (Vc_s) * R.';      % 顶点右乘 R^T
    Vc_t = Vc_t + p0;

    V_all_shaft(ofsVc + (1:nVc), :) = Vc_t;
    F_all_shaft(ofsFc + (1:nFc), :) = Fc + ofsVc;
    ofsVc = ofsVc + nVc; ofsFc = ofsFc + nFc;

    % ===== 圆锥侧壁 =====
    Vh_t = (Vh_s) * R.';
    Vh_t = Vh_t + (p0 + L_shaft * d);

    V_all_head(ofsVh + (1:nVh), :) = Vh_t;
    F_all_head(ofsFh + (1:nFh), :) = Fh + ofsVh;
    ofsVh = ofsVh + nVh; ofsFh = ofsFh + nFh;

    % ===== 圆柱端盖（底、顶）=====
    Vbot = (Vcap_shaft_bot_s) * R.';         % z=0
    Vbot = Vbot + p0;

    Vtop = Vcap_shaft_top_s * R.' + (p0 + L_shaft * d);

    V_all_cap_shaft(ofsVcs + (1:nVd), :) = Vbot;
    F_all_cap_shaft(ofsFcs + (1:nFd), :) = Fcirc + ofsVcs;
    ofsVcs = ofsVcs + nVd; ofsFcs = ofsFcs + nFd;

    V_all_cap_shaft(ofsVcs + (1:nVd), :) = Vtop;
    F_all_cap_shaft(ofsFcs + (1:nFd), :) = Fcirc + ofsVcs;
    ofsVcs = ofsVcs + nVd; ofsFcs = ofsFcs + nFd;

    % ===== 圆锥基底盖（与顶盖错开一点避免闪烁）=====
    Vbase_local = Vcap_head_base_s;          % z=0
    Vbase_local(:,3) = Vbase_local(:,3) + (cap_eps * Leff);
    Vbase = Vbase_local * R.' + (p0 + L_shaft * d);

    V_all_cap_head(ofsVch + (1:nVd), :) = Vbase;
    F_all_cap_head(ofsFch + (1:nFd), :) = Fcirc + ofsVch;
    ofsVch = ofsVch + nVd; ofsFch = ofsFch + nFd;
end

% -------- 绘制（四个 patch，统一颜色） --------
hold_state = ishold; hold on;

hshaft = patch('Faces',F_all_shaft,'Vertices',V_all_shaft, ...
    'FaceColor',col,'EdgeColor',edgeCol, ...
    'SpecularStrength',0.3);

hhead  = patch('Faces',F_all_head ,'Vertices',V_all_head , ...
    'FaceColor',col,'EdgeColor',edgeCol, ...
    'SpecularStrength',0.35);

hcap_shaft = patch('Faces',F_all_cap_shaft,'Vertices',V_all_cap_shaft, ...
    'FaceColor',col,'EdgeColor',edgeCol, ...
    'SpecularStrength',0.3);

hcap_head  = patch('Faces',F_all_cap_head,'Vertices',V_all_cap_head, ...
    'FaceColor',col,'EdgeColor',edgeCol, ...
    'SpecularStrength',0.35);

axis equal
if ~hold_state, hold off; end
camlight headlight; lighting gouraud;

end

% ================= 工具函数 =================

function [Fc, Vc] = unit_disc_fan(nfac)
theta = linspace(0, 2*pi, nfac+1); theta(end) = [];
ring = [cos(theta(:)) sin(theta(:)) zeros(nfac,1)];
center = [0 0 0];
Vc = [center; ring];               % (nfac+1)×3
Fc = zeros(nfac,3);
for i=1:nfac
    i1 = 1 + i;
    i2 = 1 + mod(i,nfac) + 1;
    Fc(i,:) = [1, i1, i2];
end
end

function [X,Y,Z,U,V,W] = compatSize(X,Y,Z,U,V,W)
sz = size(X);
args = {Y,Z,U,V,W};
for k=1:numel(args)
    a = args{k};
    if isscalar(a)
        args{k} = repmat(a, sz);
    else
        assert(isequal(size(a), sz), '所有输入必须同尺寸或标量。');
    end
end
Y=args{1}; Z=args{2}; U=args{3}; V=args{4}; W=args{5};
end

function R = rotz_to_vec(d)
k = [0;0;1];
d = d(:)/norm(d);
v = cross(k, d); s = norm(v); c = dot(k, d);
if s < 1e-12
    if c > 0
        R = eye(3);
    else
        R = [1 0 0; 0 -1 0; 0 0 -1]; % 180°
    end
    return;
end
vx = [   0   -v(3)  v(2);
       v(3)    0   -v(1);
      -v(2)  v(1)    0 ];
R = eye(3) + vx + vx*vx*((1-c)/(s^2));
end
