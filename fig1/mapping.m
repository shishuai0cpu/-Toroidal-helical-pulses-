
clear 
close all
clc
addpath 'E:\工作\硕士阶段文章\文章\数据整理\涡旋斯格名子\画图与处理程序与数据\fig1'
load('E:\工作\硕士阶段文章\文章\数据整理\涡旋斯格名子\画图与处理程序与数据\fig1\未处理涡环-电场上半2.mat')
Cz=Cz-0.3;
Z=Z-0.3;

out = map_torus_by_slice_basis(X,Y,Z, struct('R0',2, 'a0',0.6), ...
                                   Cx,Cy,Cz, Ex_c,Ey_c,Ez_c);


title('Field along reconstructed torus streamline');
grid on;
s1=surf(X,Y,2*Z, 'EdgeColor','none');
s1.FaceColor=[64/256,64/256,64/256];
s1.FaceAlpha=0.3;

aaa=4;
arrow3_uniformcolor_batch(Cx(1:aaa:end),Cy(1:aaa:end),2*Cz(1:aaa:end), Ex_c(1:aaa:end),Ey_c(1:aaa:end),2*Ez_c(1:aaa:end), ...
    'Length',0.08, ...
    'HeadFrac',0.50, ...          % 圆锥更长
    'HeadRadiusFactor',2.5, ...   % 圆锥更粗
    'Facets',32, ...
    'EdgeColor','none', ...
    'CapEpsilon',1e-6, ...
    'Radius', 0.01 ...
    , 'Scale', 0.13, ...
    'Color', [135/256, 206/256, 235/256]);           % 盖子轻微抬起，避免闪烁
axis tight; grid on; view(42,26);
xlabel x; ylabel y; zlabel z;
hold on
% camlight right%加灯光
% lighting gouraud  
daspect([1 1 1])%改坐标比例

clear 
clc
addpath 'E:\工作\硕士阶段文章\文章\数据整理\涡旋斯格名子\画图与处理程序与数据\fig1'
load('E:\工作\硕士阶段文章\文章\数据整理\涡旋斯格名子\画图与处理程序与数据\fig1\未处理涡环-电场下半2.mat')
Cz=Cz+0.3;
Z=Z+0.3;


title('Field along reconstructed torus streamline');
grid on;
s1=surf(X,Y,2*Z, 'EdgeColor','none'); 
s1.FaceColor=[64/256,64/256,64/256];
s1.FaceAlpha=0.3;


aaa=5;
arrow3_uniformcolor_batch(Cx(1:aaa:end),Cy(1:aaa:end),2*Cz(1:aaa:end), Ex_c(1:aaa:end),Ey_c(1:aaa:end),2*Ez_c(1:aaa:end), ...
    'Length',0.08, ...
    'HeadFrac',0.50, ...          % 圆锥更长
    'HeadRadiusFactor',2.5, ...   % 圆锥更粗
    'Facets',32, ...
    'EdgeColor','none', ...
    'CapEpsilon',1e-6, ...
    'Radius', 0.01 ...
    , 'Scale', 0.13, ...
    'Color', [135/256, 206/256, 235/256]);           % 盖子轻微抬起，避免闪烁
axis tight; grid on; view(42,26);
xlabel x; ylabel y; zlabel z;
hold on


% 开光照
% camlight headlight
camlight right
lighting gouraud   % 或者 lighting phong

% 设置金属性材质（简单方式）
material metal     % MATLAB 内置的“metal”材质

% 

for i=-1:2:1
for j=-1:2:1
for k=0:2:1
    l1 = light;
l1.Style = 'infinite';
l1.Position = [i j k];
end
end
end
% 
view(58,31)


exportgraphics(gcf, ['E:\工作\硕士阶段文章\文章\数据整理\涡旋斯格名子\画图与处理程序与数据\fig1\output1.png'], 'Resolution', 600);

%%

clear 
close all
clc
addpath 'E:\工作\硕士阶段文章\文章\数据整理\涡旋斯格名子\画图与处理程序与数据\fig1'
load('E:\工作\硕士阶段文章\文章\数据整理\涡旋斯格名子\画图与处理程序与数据\fig1\未处理涡环-电场上半2.mat')
Cz=Cz-0.3;
Z=Z-0.3;
Z=-Z;
Cz=-Cz;
Ez_c=-Ez_c;
title('Field along reconstructed torus streamline');
grid on;
s1=surf(X,Y,2*Z, 'EdgeColor','none');
s1.FaceColor=[64/256,64/256,64/256];
s1.FaceAlpha=0.3;

aaa=4;
arrow3_uniformcolor_batch(Cx(1:aaa:end),Cy(1:aaa:end),2*Cz(1:aaa:end), Ex_c(1:aaa:end),Ey_c(1:aaa:end),2*Ez_c(1:aaa:end), ...
    'Length',0.08, ...
    'HeadFrac',0.50, ...          % 圆锥更长
    'HeadRadiusFactor',2.5, ...   % 圆锥更粗
    'Facets',32, ...
    'EdgeColor','none', ...
    'CapEpsilon',1e-6, ...
    'Radius', 0.01 ...
    , 'Scale', 0.13, ...
    'Color', [255/256, 192/256, 203/256]);           % 盖子轻微抬起，避免闪烁
axis tight; grid on; view(42,26);
xlabel x; ylabel y; zlabel z;
hold on
% camlight right%加灯光
% lighting gouraud  
daspect([1 1 1])%改坐标比例

clear 
clc
addpath 'E:\工作\硕士阶段文章\文章\数据整理\涡旋斯格名子\画图与处理程序与数据\fig1'
load('E:\工作\硕士阶段文章\文章\数据整理\涡旋斯格名子\画图与处理程序与数据\fig1\未处理涡环-电场下半2.mat')
Cz=Cz+0.3;
Z=Z+0.3;
Z=-Z;
Cz=-Cz;
Ez_c=-Ez_c;

title('Field along reconstructed torus streamline');
grid on;
s1=surf(X,Y,2*Z, 'EdgeColor','none'); 
s1.FaceColor=[64/256,64/256,64/256];
s1.FaceAlpha=0.3;


aaa=5;
arrow3_uniformcolor_batch(Cx(1:aaa:end),Cy(1:aaa:end),2*Cz(1:aaa:end), Ex_c(1:aaa:end),Ey_c(1:aaa:end),2*Ez_c(1:aaa:end), ...
    'Length',0.08, ...
    'HeadFrac',0.50, ...          % 圆锥更长
    'HeadRadiusFactor',2.5, ...   % 圆锥更粗
    'Facets',32, ...
    'EdgeColor','none', ...
    'CapEpsilon',1e-6, ...
    'Radius', 0.01 ...
    , 'Scale', 0.13, ...
    'Color', [255/256, 192/256, 203/256]);           % 盖子轻微抬起，避免闪烁
axis tight; grid on; view(42,26);
xlabel x; ylabel y; zlabel z;
hold on


% 开光照
% camlight headlight
camlight right
lighting gouraud   % 或者 lighting phong

% 设置金属性材质（简单方式）
material metal     % MATLAB 内置的“metal”材质

% 

for i=-1:2:1
for j=-1:2:1
for k=0:2:1
    l1 = light;
l1.Style = 'infinite';
l1.Position = [i j k];
end
end
end
% 
view(58,31)


exportgraphics(gcf, ['E:\工作\硕士阶段文章\文章\数据整理\涡旋斯格名子\画图与处理程序与数据\fig1\output2.png'], 'Resolution', 600);

%%

function out = map_torus_by_slice_basis(X,Y,Z, opts, Cx,Cy,Cz, Ex,Ey,Ez)
% 按 θ 截面独立处理：
% 1) 估计每个 θ 的截面中心 rc(θ), zc(θ)
% 2) 在原面构造正交基 {e_theta, e_s}，将曲线上矢量投影到该基
% 3) 位置映射：保持 θ，不改相对关系角 psi=atan2(z-zc, rho-rc)，放到理想甜甜圈 (R0,a0,Z0)
% 4) 把同一正交基“平移”到理想甜甜圈，按可选尺度因子(s_theta,s_s)重组矢量
%
% 用法：
%   out = map_torus_by_slice_basis(X,Y,Z);                       % 仅输出面
%   out = map_torus_by_slice_basis(X,Y,Z,opts,Cx,Cy,Cz,Ex,Ey,Ez) % 面+曲线+矢量
%
% opts:
%   nTheta       (默认 241)    环向分箱数
%   smooth_win   (默认 21)     环向平滑窗口（奇数）
%   R0           (默认 mean rc(θ))  目标大半径
%   a0           (默认 mean 半径)    目标小半径
%   Z0           (默认 0)      目标环中心 z
%   preserve_scale (默认 true) 分量尺度补偿：s_theta=ρ'/ρ，s_s=a0/|v_rz|
%   enforce_continuity (默认 true) 让曲线上的 e_s 连续（避免±符号跳变）

if nargin<4 || isempty(opts), opts=struct(); end
want_curve = (nargin>=7 && ~isempty(Cx));
want_field = (nargin>=10 && ~isempty(Ex));

Kth         = gfs(opts,'nTheta',241);
smooth_win  = gfs(opts,'smooth_win',21); if mod(smooth_win,2)==0, smooth_win=smooth_win+1; end
R0_in       = gfs(opts,'R0',[]);
a0_in       = gfs(opts,'a0',[]);
Z0          = gfs(opts,'Z0',0);
pres_scale  = gfs(opts,'preserve_scale',true);
enf_cont    = gfs(opts,'enforce_continuity',true);

% ---------- 基本量 ----------
rho   = hypot(X,Y);
theta = atan2(Y,X);                % (-pi,pi]
theta2= mod(theta,2*pi);
edges = linspace(0,2*pi,Kth+1);
cent  = 0.5*(edges(1:end-1)+edges(2:end));

% ---------- (1) 每个 θ 估计截面中心 ----------
[r_c, z_c] = estimate_centers(theta2, rho, Z, edges, cent, smooth_win);
R0_est = mean(r_c(isfinite(r_c)));
% a0 用各点到中心的平均半径估计
a0_est = mean( sqrt(max(((rho - interp1(cent,r_c,theta2,'linear','extrap')).^2 + ...
                         (Z   - interp1(cent,z_c,theta2,'linear','extrap')).^2), 0) ), 'all', 'omitnan');

R0 = R0_est; if ~isempty(R0_in), R0 = R0_in; end
a0 = max(a0_est, eps); if ~isempty(a0_in), a0 = a0_in; end

% ---------- (2) 映射“面”位置（可选，很多人需要） ----------
r_c_g = interp1(cent, r_c, theta2, 'linear','extrap');
z_c_g = interp1(cent, z_c, theta2, 'linear','extrap');

vr = rho - r_c_g;    vz = Z - z_c_g;                  % 相对中心向量 (ρ-rc, z-zc)
psi_grid = atan2(vz, vr);                             % 与 z 轴的相对位置角
rho_p = R0 + a0.*cos(psi_grid);
Zp    = Z0 + a0.*sin(psi_grid);
Xp    = rho_p.*cos(theta);
Yp    = rho_p.*sin(theta);

% ---------- (3) 曲线与矢量 ----------
if want_curve
    % 曲线的 θ, ρ
    Cx = Cx(:); Cy = Cy(:); Cz = Cz(:);
    rho_c = hypot(Cx,Cy);
    th_c  = atan2(Cy,Cx);
    th2c  = mod(th_c,2*pi);

    rc_c = interp1(cent, r_c, th2c, 'linear','extrap');
    zc_c = interp1(cent, z_c, th2c, 'linear','extrap');

    vr_c  = rho_c - rc_c;     vz_c = Cz - zc_c;
    psi_c = atan2(vz_c, vr_c);
    % 目标位置
    rho_cp = R0 + a0.*cos(psi_c);
    Czp    = Z0 + a0.*sin(psi_c);
    cost   = cos(th_c);  sint = sin(th_c);
    Cxp    = rho_cp.*cost;   Cyp = rho_cp.*sint;

    if want_field
        Ex = Ex(:); Ey = Ey(:); Ez = Ez(:);
        P  = numel(Ex);

        % --- 原面上的正交基 ---
        e_theta = [-sint, cost, zeros(P,1)];           % 单位
        e_r     = [ cost, sint, zeros(P,1)];
        zhat    = repmat([0 0 1], P, 1);

        rad = sqrt(vr_c.^2 + vz_c.^2);
        rad_safe = max(rad, eps);

        % 截面切向：围绕中心沿 ψ 增大的方向（相当于在(ρ,z)平面将 v_rz 旋转+90°）
        % e_s_orig ∝ (-vz)*e_r + (vr)*zhat
        e_s_num = (-vz_c).*e_r + (vr_c).*zhat;
        e_s_den = max( sqrt(sum(e_s_num.^2,2)), eps );
        e_s     = e_s_num ./ e_s_den;

        % 可选：沿曲线强制连续（避免 ± 符号跳）
        if enf_cont
            for i=2:P
                if dot(e_s(i,:), e_s(i-1,:)) < 0
                    e_s(i,:) = -e_s(i,:);
                end
            end
        end

        % 投影到切平面并分解（去任何法向泄漏）
        V  = [Ex Ey Ez];
        Vt = V - dot(V, cross(e_theta,e_s,2), 2).*cross(e_theta,e_s,2);
        v_theta = dot(Vt, e_theta, 2);
        v_s     = dot(Vt, e_s,     2);

        % --- 目标面上的正交基（“平移”同一基） ---
        e_r_tar   = [cost, sint, zeros(P,1)];
        e_theta_t = e_theta;                                    % θ 基不变
        e_s_tar   = -sin(psi_c).*e_r_tar + cos(psi_c).*zhat;    % 理想圆截面的切向

        % 可选尺度：s_theta=ρ'/ρ，s_s=a0/|v_rz|
        if pres_scale
            s_theta = rho_cp ./ max(rho_c, eps);
            s_s     = a0     ./ rad_safe;
        else
            s_theta = 1; s_s = 1;
        end

        v_theta_p = v_theta .* s_theta;
        v_s_p     = v_s     .* s_s;

        Vp = v_theta_p.*e_theta_t + v_s_p.*e_s_tar;
        Exp = Vp(:,1); Eyp = Vp(:,2); Ezp = Vp(:,3);
    end
end

% ---------- 输出 ----------
out = struct();
out.Xp=Xp; out.Yp=Yp; out.Zp=Zp;
out.params = struct('centers',cent, 'r_c',r_c, 'z_c',z_c, ...
                    'R0',R0,'a0',a0,'Z0',Z0, ...
                    'notes','per-θ slice basis; es = +90° rot of (rho-rc, z-zc)');

if want_curve
    out.Cxp=Cxp; out.Cyp=Cyp; out.Czp=Czp;
end
if want_curve && want_field
    out.Exp=Exp; out.Eyp=Eyp; out.Ezp=Ezp;
end
end

% =============== 辅助函数 ===============
function [r_c, z_c] = estimate_centers(theta2, rho, Z, edges, cent, smooth_win)
K = numel(cent);
r_c=nan(K,1); z_c=nan(K,1);
for k=1:K
    inb = (theta2>=edges(k) & theta2<edges(k+1));
    rr = rho(inb); zz = Z(inb);
    if isempty(rr), continue; end
    r_c(k) = median(rr(isfinite(rr)));
    z_c(k) = median(zz(isfinite(zz)));
end
r_c = circ_smooth(fill_circ(cent,r_c), smooth_win);
z_c = circ_smooth(fill_circ(cent,z_c), smooth_win);
end

function y = circ_smooth(y, w)
if w<=1, y(~isfinite(y))=0; return; end
n=numel(y);
y2=[y(:); y(:); y(:)];
w2=ones(size(y2)); w2(~isfinite(y2))=0; y2(~isfinite(y2))=0;
s=conv(y2,ones(w,1),'same'); c=conv(w2,ones(w,1),'same'); m=s./max(c,eps);
y=m(n+1:2*n); y(~isfinite(y))=0;
end

function y = fill_circ(x,y)
idx=find(isfinite(y));
if isempty(idx), y=zeros(size(y)); return; end
x2=[x(1)-2*pi; x(:); x(end)+2*pi];
y2=[y(end);    y(:); y(1)];
mask=isfinite(y2);
y2i=interp1(x2(mask),y2(mask),x2,'linear','extrap');
y=y2i(2:end-1); y(~isfinite(y))=0;
end

function v=gfs(s,f,def)
if isfield(s,f), v=s.(f); else, v=def; end
end




%%

function out = resample_closed_curve_3d_safe(Cx,Cy,Cz, Ex,Ey,Ez, opts)
% 闭合三维曲线按弧长均匀重采样（超稳健版，带日志与兜底）
% - 自动清洗: NaN/Inf、零长度段
% - 强制自变量严格递增: 对重复/近重复弧长点注入极小抖动，并分组均值去重
% - 插值失败自动回退 pchip -> linear
% - 始终返回: out.status, out.msg, out.diag 便于排查
%
% 调用示例:
% r = resample_closed_curve_3d_safe(Cxp, Cyp, Czp, Exp, Eyp, Ezp, ...
%       struct('N',400,'method','pchip','verbose',true,'jitter_eps',1e-9));

tStart = tic;
if nargin < 7 || isempty(Ex), Ex = []; Ey = []; Ez = []; end
if nargin < 8, opts = struct(); end
if ~isfield(opts,'method'),     opts.method = 'pchip'; end   % 'pchip' | 'linear'
if ~isfield(opts,'N'),          opts.N = []; end
if ~isfield(opts,'ds'),         opts.ds = []; end
if ~isfield(opts,'verbose'),    opts.verbose = true; end
if ~isfield(opts,'jitter_eps'), opts.jitter_eps = 1e-12; end % 相对弧长的抖动比例

logmsg = @(varargin) (opts.verbose && fprintf(varargin{:}));

out = struct('Cx_u',[],'Cy_u',[],'Cz_u',[], ...
             'Ex_u',[],'Ey_u',[],'Ez_u',[], ...
             's_u',[],'L',[],'status',false,'msg','', ...
             'diag',struct());

try
    % ---------- 1) 基础检查 ----------
    Cx = Cx(:); Cy = Cy(:); Cz = Cz(:);
    P  = numel(Cx);
    if ~(numel(Cy)==P && numel(Cz)==P), error('Cx,Cy,Cz 长度不一致'); end
    hasE = ~isempty(Ex);
    if hasE
        Ex=Ex(:); Ey=Ey(:); Ez=Ez(:);
        if ~(numel(Ex)==P && numel(Ey)==P && numel(Ez)==P)
            error('Ex,Ey,Ez 长度必须与曲线点数一致');
        end
    end
    logmsg('[1] 输入点数 P=%d\n', P);

    % ---------- 2) 清理 NaN/Inf ----------
    ok = isfinite(Cx)&isfinite(Cy)&isfinite(Cz);
    if hasE, ok = ok & isfinite(Ex)&isfinite(Ey)&isfinite(Ez); end
    Cx=Cx(ok); Cy=Cy(ok); Cz=Cz(ok);
    if hasE, Ex=Ex(ok); Ey=Ey(ok); Ez=Ez(ok); end
    P=numel(Cx);
    if P<3, error('有效点数 < 3（清理后）'); end
    logmsg('[2] 清理后点数 P=%d\n', P);

    % ---------- 3) 删除零长度段 ----------
    CxC=[Cx;Cx(1)]; CyC=[Cy;Cy(1)]; CzC=[Cz;Cz(1)];
    seg = sqrt(diff(CxC).^2 + diff(CyC).^2 + diff(CzC).^2);
    keep = [true; seg(1:end-1) > 0];
    Cx=Cx(keep); Cy=Cy(keep); Cz=Cz(keep);
    if hasE, Ex=Ex(keep); Ey=Ey(keep); Ez=Ez(keep); end
    P=numel(Cx);
    if P<3, error('去重后有效点数 < 3'); end
    logmsg('[3] 去零段后点数 P=%d\n', P);

    % ---------- 4) 弧长参数 s∈[0,L) ----------
    CxC=[Cx;Cx(1)]; CyC=[Cy;Cy(1)]; CzC=[Cz;Cz(1)];
    seg = sqrt(diff(CxC).^2 + diff(CyC).^2 + diff(CzC).^2);
    sC  = [0; cumsum(seg)];
    L   = sC(end);
    if L<=0, error('曲线周长 L<=0'); end
    s   = sC(1:end-1);         % 与 Cx/Cy/Cz 对齐
    out.L = L;
    logmsg('[4] 周长 L=%.6g\n', L);

    % ---------- 5) 使自变量严格递增（抖动 + 分组均值去重） ----------
    [s_sorted, idx] = sort(s, 'ascend');    % 稳定排序
    Cx = Cx(idx); Cy = Cy(idx); Cz = Cz(idx);
    if hasE, Ex=Ex(idx); Ey=Ey(idx); Ez=Ez(idx); end

    ds_min = diff(s_sorted);
    nz = ds_min(ds_min>0);
    base = ~isempty(nz) * min(nz);
    if isempty(nz) || base==0
        base = L / max(P,10);  % 极端兜底
    end
    jitter = opts.jitter_eps * base;

    % 相邻重复 s 注入微小抖动，使严格递增
    for i=2:numel(s_sorted)
        if s_sorted(i) - s_sorted(i-1) <= 0
            s_sorted(i) = s_sorted(i-1) + jitter;
        end
    end

    % 分组均值去重（基于相对弧长）
    sn = s_sorted / L;
    tol_merge = max(opts.jitter_eps, 1e-12);
    groups = ones(size(sn));
    g = 1;
    for i=2:numel(sn)
        if sn(i) - sn(i-1) > tol_merge
            g = g + 1;
        end
        groups(i) = g;
    end
    G = g;
    Cxg = accumarray(groups, Cx, [G,1], @mean);
    Cyg = accumarray(groups, Cy, [G,1], @mean);
    Czg = accumarray(groups, Cz, [G,1], @mean);
    sg  = accumarray(groups, s_sorted, [G,1], @mean);
    if hasE
        Exg = accumarray(groups, Ex, [G,1], @mean);
        Eyg = accumarray(groups, Ey, [G,1], @mean);
        Ezg = accumarray(groups, Ez, [G,1], @mean);
    else
        Exg=[]; Eyg=[]; Ezg=[];
    end
    s_unique = sg;
    if numel(s_unique)<3, error('去重后自变量点数 < 3'); end
    logmsg('[5] 去重后唯一弧长点数 = %d，min Δs=%.3g\n', numel(s_unique), min(diff(s_unique)));

    % ====== [补丁] 强制 s_unique ∈ [0, L) 且严格唯一 ======
    tiny = max(1e-12*L, 1e-12);      % 数值安全边界
    s_unique(s_unique >= L) = L - tiny;   % 把任何 >=L 的点拉回
    s_unique(s_unique < 0)  = 0;          % 负值抬到 0
    [s_unique, iu] = unique(s_unique, 'stable'); % 再做一次严格去重
    Cxg = Cxg(iu); Cyg = Cyg(iu); Czg = Czg(iu);
    if hasE
        Exg = Exg(iu); Eyg = Eyg(iu); Ezg = Ezg(iu);
    end
    % 若仍有非递增，再次轻微抖动
    dup = find(diff(s_unique) <= 0);
    for kk = 1:numel(dup)
        s_unique(dup(kk)+1) = s_unique(dup(kk)) + tiny;
    end
    if L - s_unique(end) <= tiny
        s_unique(end) = L - tiny;   % 确保最后一个 < L
    end
    % ===============================================

    % ---------- 6) 目标均匀弧长参数 ----------
    if ~isempty(opts.ds) && opts.ds>0
        N = max(3, floor(L/opts.ds));
    elseif ~isempty(opts.N)
        N = max(3, round(opts.N));
    else
        N = numel(s_unique);
    end
    s_u = linspace(0, L, N+1).';
    s_u = s_u(1:end-1);   % 去掉 L，得到 [0,L) 上 N 个等间距点
    out.s_u = s_u;
    logmsg('[6] 目标点数 N=%d\n', N);

    % ---------- 7) 周期性插值（附首点到 L） ----------
    s_ext  = [s_unique; L];
    Cx_ext = [Cxg; Cxg(1)];
    Cy_ext = [Cyg; Cyg(1)];
    Cz_ext = [Czg; Czg(1)];
    if hasE
        Ex_ext = [Exg; Exg(1)];
        Ey_ext = [Eyg; Eyg(1)];
        Ez_ext = [Ezg; Ezg(1)];
    end

    % 先试 pchip，失败则退回 linear
    method_try = {opts.method, 'linear'};
    ok_interp = false; lastErr = '';
    for k=1:numel(method_try)
        try
            mtd = method_try{k};
            Cx_u = interp1(s_ext, Cx_ext, s_u, mtd);
            Cy_u = interp1(s_ext, Cy_ext, s_u, mtd);
            Cz_u = interp1(s_ext, Cz_ext, s_u, mtd);
            if hasE
                Ex_u = interp1(s_ext, Ex_ext, s_u, mtd);
                Ey_u = interp1(s_ext, Ey_ext, s_u, mtd);
                Ez_u = interp1(s_ext, Ez_ext, s_u, mtd);
            else
                Ex_u=[]; Ey_u=[]; Ez_u=[];
            end
            ok_interp = true;
            logmsg('[7] 插值方法: %s\n', mtd);
            break
        catch ME
            lastErr = ME.message;
            logmsg('[7] 方法 %s 失败: %s\n', method_try{k}, lastErr);
        end
    end
    if ~ok_interp
        error('所有插值方法均失败: %s', lastErr);
    end

    % ---------- 8) 输出 ----------
    out.Cx_u = Cx_u; out.Cy_u = Cy_u; out.Cz_u = Cz_u;
    out.Ex_u = Ex_u; out.Ey_u = Ey_u; out.Ez_u = Ez_u;
    out.status = true;
    out.msg = 'ok';
    out.diag = struct('P_in',P, ...
                      'N_out',N, ...
                      'L',L, ...
                      'min_ds_unique',min(diff(s_unique)), ...
                      'time_s',toc(tStart));
catch ME
    out.status = false;
    out.msg = ME.message;
    out.diag.time_s = toc(tStart);
end
end
