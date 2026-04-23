clc
clear 
load('E:\工作\硕士阶段文章\文章\数据整理\涡旋斯格名子\画图与处理程序与数据\fig1\matlab2.mat')

draw_theta_2=real(draw_theta);
draw_z_2=real(draw_z);
draw_rho_2=real(draw_rho);

draw_rho=draw_rho_2;
draw_theta=draw_theta_2;
draw_z=draw_z_2;

draw_rho(1:50,:)=-draw_rho_2(1:50,:);
draw_theta(1:50,:)=-draw_theta_2(1:50,:);
draw_z(1:50,:)=draw_z_2(1:50,:);


x=1:1:301;
x=x*0.002;
y=1:101;
y=y*0.01;

[X,Y] = meshgrid(x,y);

% ----- 旋转衰减场 -----
Ex = draw_z;
Ey = draw_rho;

% ----- 起点 -----
% seeds = [0.386 0.78];
% seeds = [0.3312 0.59];
seeds = [0.33 0.65];
% seeds = [186.3 29;189 29];

% ----- 参数 -----
opts = struct('Step',(x(2)-x(1))/5,'BiDir',true,'MinSpeed',1e-14,'MaxSteps',12000);

% ----- 追踪 -----
FL = trace_fieldlines2D_meshgrid(X,Y,Ex,Ey,seeds,opts);

%%
figure
s1=surf(Ex);
s1.EdgeColor='none';
view(2)


%% ----- 可视化 -----
figure; hold on; axis equal;
skip=1;
quiver(X(1:skip:end,1:skip:end),Y(1:skip:end,1:skip:end), ...
       Ex(1:skip:end,1:skip:end),Ey(1:skip:end,1:skip:end), ...
       0.7,'Color',[.4 .4 .4]);

for k=1:numel(FL)
    plot(FL(k).xy(:,1),FL(k).xy(:,2),'LineWidth',1.5);
end

plot(seeds(:,1),seeds(:,2),'ko','MarkerFaceColor','y');
title('meshgrid 2D 场线追踪');
%%
clc
p = [0.33 0.65];
[idx, iNearest, dist] = find_curve_by_point(FL, p, 5);  % 容差0.5（你可按尺度改）
%%
figure
hold on
aaa=11400;
bbb=6950;
plot(FL(idx).xy(bbb:aaa,1),FL(idx).xy(bbb:aaa,2))
%%

info = fit_close_curve(FL(idx).xy(bbb:aaa,:), ...
    'Win',         12, ...     % 端点邻域：估计切向 & 裁掉两端
    'BridgePts',   100, ...    % 桥接段采样点数
    'TangentScale',0.55, ...   % 端点切向强度（相对端点弦长）
    'ResampleN',   400 );      % 最终按弧长等距重采样（点数=400, 首尾同点）

figure('Color','w'); hold on; axis equal; box on;
plot(FL(idx).xy(bbb:aaa,1),          FL(idx).xy(bbb:aaa,2),          'k--', 'LineWidth', 1.0);  % 原开口
plot(info.xy_open(:,1),  info.xy_open(:,2),  'b-',  'LineWidth', 1.6);  % 主体(去端点)
plot(info.bridge(:,1),   info.bridge(:,2),   'r-',  'LineWidth', 2.2);  % Hermite 桥接
plot(info.xy(:,1),       info.xy(:,2),       'g-',  'LineWidth', 1.6);  % 闭合(重采样)
legend('原始开口','主体(去端点)','Hermite桥接','闭合(最终)','Location','best');
title('开口曲线 → 基于端点邻域的平滑闭合');

% ---------- 4) 一些诊断信息 ----------
disp('--- report ---');
disp(info.report);
fprintf('闭合曲线总点数(含首尾同点): %d\n', size(info.xy,1));
fprintf('桥接段点数: %d\n', size(info.bridge,1));




%%
Xc=info.xy(:,1);
Yc=info.xy(:,2);


Erho_c   = interp2(X, Y, draw_rho,   Xc, Yc, 'linear');
Etheta_c = interp2(X, Y, draw_theta, Xc, Yc, 'linear');
Ez_c     = interp2(X, Y, draw_z,     Xc, Yc, 'linear');

quiver(Xc, Yc,Ez_c,Erho_c)
% axis equal
% save(Xc, Yc,Ez_c,Etheta_c,Erho_c)

%%


figure
s1=surf(x(:,500:850),y(:,500:850),draw_rho(:,500:850));
s1.EdgeColor='none';
view(2)
hold on

Erho_c   = interp2(x, y, draw_rho,   Xc, Yc, 'linear');
Etheta_c = interp2(x, y, draw_theta, Xc, Yc, 'linear');
Ez_c     = interp2(x, y, draw_z,     Xc, Yc, 'linear');

quiver(Xc, Yc,Ez_c,Erho_c)




function FL = trace_fieldlines2D_meshgrid(X, Y, Ex, Ey, seeds, opts)
% 2D 场线追踪 (RK4) —— 全部基于 meshgrid + interp2
% X,Y,Ex,Ey: 来自 meshgrid(x,y)
% seeds: [Ns×2] 起点，格式 [x y]
% opts: 结构体（可省略），支持字段:
%   .Step      .MaxSteps   .MaxLength
%   .MinSpeed  .Normalize  .BiDir
%   .CloseTol

% ---- 默认参数 ----
if nargin < 6, opts = struct(); end
opts = set_default(opts,'MaxSteps',  8000);
opts = set_default(opts,'MaxLength', inf);
opts = set_default(opts,'MinSpeed',  1e-14);
opts = set_default(opts,'Normalize', false);
opts = set_default(opts,'BiDir',     true);

dx = median(diff(X(1,:))); dy = median(diff(Y(:,1)));
opts = set_default(opts,'Step', min(dx,dy)/4);
opts = set_default(opts,'CloseTol', 2*opts.Step);

% ---- 主循环 ----
Ns = size(seeds,1);
FL = repmat(struct('id',[], 'seed',[], 'xy',[], 'arclen',[], 'closed',false,'report',''), Ns,1);

for s = 1:Ns
    p0 = seeds(s,:);
    rep = {};

    [xy_fwd, rep_f] = onedir(p0, +opts.Step);
    rep = [rep; rep_f];

    if opts.BiDir
        [xy_bwd, rep_b] = onedir(p0, -opts.Step);
        rep = [rep; rep_b];
        xy = [flipud(xy_bwd(1:end-1,:)); xy_fwd];
    else
        xy = xy_fwd;
    end

    closed = is_closed(xy, opts.CloseTol);
    FL(s) = pack(s, p0, xy, closed, strjoin(rep,newline));
end

% ---- 内核：单方向追踪 ----
function [xy, rep] = onedir(p_start, h)
    rep = {};
    xy = zeros(opts.MaxSteps+1, 2);
    xy(1,:) = p_start;
    Lsum = 0; k = 1;

    while k <= opts.MaxSteps
        v = VEC(xy(k,:));
        if any(isnan(v))
            rep{end+1} = '出界/无插值'; break;
        end
        spd = hypot(v(1),v(2));
        if spd < opts.MinSpeed
            rep{end+1} = sprintf('速度过小 %.2e', spd); break;
        end

        pnext = rk4_step(xy(k,:), h);
        if ~in_bounds(pnext)
            rep{end+1} = '越界'; xy(k+1,:)=pnext; k=k+1; break;
        end

        xy(k+1,:) = pnext;
        Lsum = Lsum + hypot(pnext(1)-xy(k,1), pnext(2)-xy(k,2));
        if Lsum > opts.MaxLength
            rep{end+1} = '达到长度上限'; k=k+1; break;
        end
        k=k+1;
    end
    xy = xy(1:k,:);
end

% ---- 取样函数 (meshgrid + interp2) ----
function v = VEC(p)
    vx = interp2(X, Y, Ex, p(1), p(2), 'linear', NaN);
    vy = interp2(X, Y, Ey, p(1), p(2), 'linear', NaN);
    v = [vx, vy];
end

% ---- RK4 ----
function p_next = rk4_step(p, h)
    k1 = normdir(VEC(p));
    k2 = normdir(VEC(p + 0.5*h*k1));
    k3 = normdir(VEC(p + 0.5*h*k2));
    k4 = normdir(VEC(p + h*k3));
    p_next = p + (h/6)*(k1+2*k2+2*k3+k4);
end

function v = normdir(v)
    if opts.Normalize
        n = hypot(v(1),v(2)); if n<eps, return; end
        v = v / n;
    end
end

% ---- 辅助函数 ----
function tf = in_bounds(p)
    tf = (p(1)>=min(X(:))) && (p(1)<=max(X(:))) && ...
         (p(2)>=min(Y(:))) && (p(2)<=max(Y(:)));
end

function tf = is_closed(p,tol)
    tf = size(p,1)>=3 && hypot(p(1,1)-p(end,1), p(1,2)-p(end,2)) <= tol;
end

function S = pack(id,seed,xy,closed,report)
    S.id=id; S.seed=seed; S.xy=xy;
    S.arclen=sum(hypot(diff(xy(:,1)),diff(xy(:,2))));
    S.closed=closed; S.report=report;
end

function S=set_default(S,n,v)
    if ~isfield(S,n)||isempty(S.(n)), S.(n)=v; end
end
end

% ================= 通过一点找曲线 =================
function [idx, iNearest, dist] = find_curve_by_point(FL, p, tol)
% FIND_CURVE_BY_POINT  通过空间中一点坐标查找最邻近的曲线
%   [idx, iNearest, dist] = find_curve_by_point(FL, [xp yp], tol)

    if nargin < 2, error('需要 FL 和 p'); end
    if nargin < 3 || isempty(tol), tol = inf; end

    best.idx = 0; best.dist = inf; best.iNearest = [];
    for i = 1:numel(FL)
        xy = FL(i).xy;
        [dmin, ~, iNear] = point_polyline_distance(p, xy);
        if dmin < best.dist
            best.idx = i; best.dist = dmin; best.iNearest = iNear;
        end
    end
    idx = best.idx; iNearest = best.iNearest; dist = best.dist;
end

% ================ 导出：通过一点坐标锁定曲线后写 CSV ================
function export_curve_by_point(FL, p, outCsvFile, tol)
% EXPORT_CURVE_BY_POINT  给定空间一点，找到其对应曲线并导出 CSV
%   export_curve_by_point(FL, [xp yp], 'path\curve.csv', tol)  % tol 可省略

    if nargin < 3
        error('需要输入 FL, p, outCsvFile（第 3 个参数）。');
    end
    if nargin < 4 || isempty(tol), tol = inf; end

    [idx, ~, dist] = find_curve_by_point(FL, p, tol);
    if idx == 0
        error('未找到任何曲线（即使放宽容差也没有候选）。');
    end
    if isfinite(tol) && dist > tol
        warning('最近曲线距离=%.3g 超过给定容差 %.3g，仍导出该最近曲线。', dist, tol);
    end
    writematrix(FL(idx).xy, outCsvFile);
end

% ================== 几何工具：点到折线距离 ==================
function [dmin, proj, iNearest] = point_polyline_distance(p, poly)
% 返回点 p 到折线 poly 的最小距离 dmin，
% 以及最近点的坐标 proj（在线段内的正交投影或端点），
% 以及距离最近的“顶点”索引 iNearest

    if isempty(poly)
        dmin = inf; proj = [NaN,NaN]; iNearest = 1; return;
    end
    if size(poly,1) < 2
        d = hypot(p(1)-poly(1,1), p(2)-poly(1,2));
        dmin = d; proj = poly(1,:); iNearest = 1; return;
    end

    dmin = inf; proj = [NaN,NaN]; iNearest = 1;
    for k = 1:size(poly,1)-1
        a = poly(k,:); b = poly(k+1,:);
        ab = b - a;
        denom = dot(ab,ab);
        if denom < eps
            q = a; t = 0;
        else
            t = dot(p-a, ab) / denom;
            t = max(0, min(1, t));
            q = a + t * ab;  % 投影点
        end
        d = hypot(p(1)-q(1), p(2)-q(2));
        if d < dmin
            dmin = d; proj = q;
            if t <= 0.5, iNearest = k; else, iNearest = k+1; end
        end
    end
end

% ================== 小工具：设默认值 ==================
function S = set_default(S, name, val)
    if ~isfield(S, name) || isempty(S.(name))
        S.(name) = val;
    end
end





function [xc,yc,info] = close_curve_local_quintic(x,y,varargin)
% CLOSE_CURVE_LOCAL_QUINTIC
% 仅在首尾各一小段窗口内，用五次 Hermite（C² 连续）搭一段平滑桥，
% 其余曲线点完全保留；适合“原曲线由场追踪得到，需要高保真，仅封口”的情形。
%
% [xc,yc,info] = close_curve_local_quintic(x,y, ...
%      'Frac',0.05,'BridgePts',120,'TanWin',9,'CurvWin',11,'Alpha',0.8,'Beta',0.4)
%
% 输入:
%   x,y          : 开口曲线坐标（按行走顺序；首尾未接）
%
% 可选参数:
%   'Frac'       : 首尾各占总弧长的窗口比例（默认 0.05，建议 0.03~0.12）
%   'BridgePts'  : 桥段采样点数（默认 120）
%   'TanWin'     : 估计切向的 S-G 窗口(奇数)，默认 9
%   'CurvWin'    : 估计曲率的 S-G 窗口(奇数)，默认 11
%   'Alpha'      : 切向尺度系数，控制桥段“拉伸”力度（默认 0.8；小→更圆润）
%   'Beta'       : 曲率尺度系数，控制二阶导大小（默认 0.4；小→更保守）
%
% 输出:
%   xc,yc        : 闭合曲线（末点重复首点）；窗口外的点与原始数据完全一致
%   info         : 结构体，含窗口、端点切向/曲率等诊断

% ---------- 解析参数 ----------
p = inputParser;
p.addParameter('Frac',0.05);
p.addParameter('BridgePts',120);
p.addParameter('TanWin',9);
p.addParameter('CurvWin',11);
p.addParameter('Alpha',0.8);
p.addParameter('Beta',0.4);
p.parse(varargin{:});
Frac      = p.Results.Frac;
B         = p.Results.BridgePts;
TanWin    = p.Results.TanWin;
CurvWin   = p.Results.CurvWin;
Alpha     = p.Results.Alpha;
Beta      = p.Results.Beta;

x=x(:); y=y(:);
assert(numel(x)==numel(y) && numel(x)>=5, 'x,y长度需一致且≥5');

% ---------- 弧长及窗口 ----------
s = [0; cumsum(hypot(diff(x),diff(y)))];
L = s(end);  assert(L>0,'曲线长度为0');
Lw = max(Frac*L, eps);
iL = find(s <= Lw,       1, 'last');   % 前端窗口终点索引
jL = find(s >= L - Lw,   1, 'first');  % 末端窗口起点索引
iL = max(2, min(iL, numel(x)-3));
jL = max(iL+3, min(jL, numel(x)-1));

% 需要保留的中段
x_mid = x(iL+1:jL-1);
y_mid = y(iL+1:jL-1);

% 桥两端锚点（位于保留段的两侧）
p0 = [x(iL+1), y(iL+1)];
p1 = [x(jL-1), y(jL-1)];

% ---------- 估计切向与曲率（Savitzky–Golay） ----------
% 对原序列做 S-G 一阶、二阶导（按索引均匀近似——对高采样数据足够）
[T1x,T1y] = sg_derivative(x,y,TanWin,1);
[T2x,T2y] = sg_derivative(x,y,CurvWin,2);

% 取两端的单位切向；二阶导向法向分量
t0 = unit([T1x(iL+1), T1y(iL+1)]);
t1 = unit([T1x(jL-1), T1y(jL-1)]);

% 局部曲率向量（未归一化）：a ≈ κ * n * |v|^2，这里用二阶导估计方向
n0 = unit([ -t0(2), t0(1) ]);  % 左法向
n1 = unit([ -t1(2), t1(1) ]);

% ---------- 五次 Hermite（C²）桥的端条件 ----------
D   = norm(p1 - p0);         % 两端距离，用作尺度
v0  = t0 * (Alpha * D);      % 一阶导（速度）尺度
v1  = t1 * (Alpha * D);
a0  = n0 * (Beta  * D);      % 二阶导（加速度）尺度（只取法向方向，避免拐向）
a1  = n1 * (Beta  * D);

% 生成桥段
tau = linspace(0,1,B).';
[H0,H1,H2,H3,H4,H5] = hermite5(tau);

bridge = H0.*p0 + H1.*v0 + H2.*a0 + H3.*p1 + H4.*v1 + H5.*a1;

% ---------- 拼接（只替换窗口内，窗口外精确保留） ----------
xc = [x(1:iL); bridge(:,1); x(jL:end)];
yc = [y(1:iL); bridge(:,2); y(jL:end)];
xc(end+1)=xc(1); yc(end+1)=yc(1);

% ---------- 信息 ----------
info = struct('L',L,'Lw',Lw,'iL',iL,'jL',jL,'p0',p0,'p1',p1, ...
              't0',t0,'t1',t1,'alpha',Alpha,'beta',Beta,'bridge_pts',B);
end

% ====== 工具函数 ======

function v = unit(v)
n = norm(v); if n==0, return; end; v = v / n;
end

function [dx,dy] = sg_derivative(x,y,win,order)
% 简易 Savitzky-Golay 导数（在索引均匀假设下）
if mod(win,2)==0, win=win+1; end
half = (win-1)/2;
% 设计 S-G 系数（对等间距，步长 h=1）
A = zeros(win, order+1);
idx = (-half:half).';
for k=0:order
    A(:,k+1) = idx.^k;
end
C = (A' * A) \ A';
coef = C(order+1,:);  % 对应 k=order 的导数系数（未除以 h^order）
dx = conv(x, coef, 'same');
dy = conv(y, coef, 'same');
end

function [H0,H1,H2,H3,H4,H5] = hermite5(t)
% 五次 Hermite 基函数（C²）：给定 p0,v0,a0,p1,v1,a1
H0 =  1 - 10*t.^3 + 15*t.^4 - 6*t.^5;
H1 =      t -  6*t.^3 +  8*t.^4 - 3*t.^5;
H2 = 0.5*(t.^2 - 3*t.^3 + 3*t.^4 - t.^5);
H3 =  10*t.^3 - 15*t.^4 + 6*t.^5;
H4 = -4*t.^3 +  7*t.^4 - 3*t.^5;
H5 = 0.5*(t.^3 - 2*t.^4 + t.^5);
end

function C = fit_close_curve(P, varargin)
% FIT_CLOSE_CURVE  将一条二维开口曲线平滑拟合为闭合曲线
% 输入:
%   P : [N×2] 开口曲线点集，按顺序排列 (x,y)
% 选项 (Name-Value):
%   'Win'         : 端点邻域窗口点数，用于估计切向与裁剪 (默认 max(5,round(0.03N)))
%   'BridgePts'   : 桥接曲线上采样点数 (默认 max(50, round(0.1N)))
%   'TangentScale': 端点切向量尺度系数，相对端点间弦长 L 的比例 (默认 0.4)
%   'ResampleN'   : 最终闭合曲线重采样点数；[] 表示不重采样 (默认 [] → 不重采样)
%   'CloseTol'    : 若起终点距离 < CloseTol，视为已闭合，仅做可选重采样 (默认 1e-6)
%
% 输出:
%   C: 结构体
%      .xy        [M×2] 闭合曲线（首尾同点）
%      .xy_open   [K×2] 被保留的原曲线主体（去掉两端 Win 个点）
%      .bridge    [B×2] Hermite 桥接段（不含端点重复）
%      .report    结构体：gap、win、bridgePts、tangentScale 等
%
% 说明:
%  - 本函数仅用起点/终点附近的局部几何来确定闭合段，从而“尊重”原曲线主体。
%  - 无需任何工具箱。

% ---------------- 参数与检查 ----------------
P = double(P);
assert(ndims(P)==2 && size(P,2)==2, 'P 必须是 [N×2] 实数矩阵');
N = size(P,1);
ip = inputParser;
ip.addParameter('Win', max(5, round(0.03*N)), @(x)isnumeric(x)&&isscalar(x)&&x>=2);
ip.addParameter('BridgePts', max(50, round(0.1*N)), @(x)isnumeric(x)&&isscalar(x)&&x>=10);
ip.addParameter('TangentScale', 0.4, @(x)isnumeric(x)&&isscalar(x)&&x>0);
ip.addParameter('ResampleN', [], @(x) isempty(x) || (isscalar(x)&&x>=8));
ip.addParameter('CloseTol', 1e-6, @(x)isnumeric(x)&&isscalar(x)&&x>=0);
ip.parse(varargin{:});
opt = ip.Results;

% 清理重复/NaN
P = P(~any(isnan(P),2),:);
P = remove_consecutive_duplicates(P);
N = size(P,1);
assert(N>= max(10, 2*opt.Win+5), '点数太少，无法进行稳定闭合');

% 起终点及间距
P0 = P(1,:);    P1 = P(end,:);
gap = norm(P0 - P1);

% 若已闭合
if gap < opt.CloseTol
    xy_closed = ensure_closed(P);
    if ~isempty(opt.ResampleN)
        xy_closed = resample_closed_by_arclen(xy_closed, opt.ResampleN);
    end
    C.xy      = xy_closed;
    C.xy_open = P;
    C.bridge  = zeros(0,2);
    C.report  = struct('gap',gap,'win',opt.Win,'bridgePts',0, ...
        'tangentScale',opt.TangentScale,'resampleN',opt.ResampleN,'note','already closed');
    return;
end

% ---------------- 估计端点切向 ----------------
w  = min(opt.Win, floor((N-3)/2));
% 起点切向: 用 P(1 → 1+w)
t0 = P(1+w,:) - P(1,:);
% 终点切向: 用 P(end-w → end)
t1 = P(end,:) - P(end-w,:);
if norm(t0)==0, t0 = P(2,:) - P(1,:); end
if norm(t1)==0, t1 = P(end,:) - P(end-1,:); end
t0 = t0 / norm(t0);
t1 = t1 / norm(t1);

% ---------------- 构造 Hermite 桥接段 ----------------
L = gap;  % 端点弦长
m0 =  opt.TangentScale * L * t1;   % 注意：桥接从终点→起点，首端用终点切向
m1 =  opt.TangentScale * L * t0;

B = hermite_bridge(P1, P0, m0, m1, opt.BridgePts); % 包含两端点

% ---------------- 裁剪原曲线两端并拼接 ----------------
body = P(1+w : end-w, :);   % 去掉两端 w 个点
% 去掉桥接的首末点，避免重复连接
bridge_inner = B(2:end-1,:);

xy_closed = [body; bridge_inner; body(1,:)]; % 闭合（首尾同点）

% ---------------- 可选重采样 ----------------
if ~isempty(opt.ResampleN)
    xy_closed = resample_closed_by_arclen(xy_closed, opt.ResampleN);
end

% ---------------- 输出 ----------------
C.xy      = xy_closed;
C.xy_open = body;
C.bridge  = bridge_inner;
C.report  = struct('gap',gap,'win',w,'bridgePts',size(bridge_inner,1), ...
    'tangentScale',opt.TangentScale,'resampleN',opt.ResampleN,'note','hermite close');

end

% ====== 子函数 ======

function Q = remove_consecutive_duplicates(Q)
    keep = [true; vecnorm(diff(Q),2,2) > eps];
    Q = Q(keep,:);
end

function B = hermite_bridge(Pa, Pb, Ma, Mb, K)
% 从点 Pa 到点 Pb 的三次 Hermite 曲线，端点切向分别为 Ma, Mb
    u = linspace(0,1,K).';
    h00 =  2*u.^3 - 3*u.^2 + 1;
    h10 =      u.^3 - 2*u.^2 + u;
    h01 = -2*u.^3 + 3*u.^2;
    h11 =      u.^3 -   u.^2;
    B = h00.*Pa + h10.*Ma + h01.*Pb + h11.*Mb;
end

function C = ensure_closed(C)
% 若首尾不等则补上首点
    if norm(C(1,:)-C(end,:))>0
        C = [C; C(1,:)];
    end
end
function Q = resample_closed_by_arclen(P, M)
% 按弧长等距重采样闭合曲线（首尾同点）
    % 确保闭合
    if norm(P(1,:)-P(end,:))>0, P = [P; P(1,:)]; end

    % 原始弧长
    d = vecnorm(diff(P),2,2);
    s = [0; cumsum(d)];
    L = s(end);

    % 去掉最后一个重复点，得到单周期数据
    P1 = P(1:end-1,:);
    s1 = s(1:end-1);

    % —— 关键修改：做周期扩展，避免尾段查询越界 ——
    s_ext = [s1; s1 + L];
    x_ext = [P1(:,1); P1(:,1)];
    y_ext = [P1(:,2); P1(:,2)];

    % 目标等距弧长（不包含终点 L）
    s_new = linspace(0, L, M+1).';
    s_new(end) = [];                      % [0, L)

    % 插值（不需 'extrap'）
    xq = interp1(s_ext, x_ext, s_new, 'pchip');  % 或 'linear'
    yq = interp1(s_ext, y_ext, s_new, 'pchip');

    Q = [xq,yq];
    Q = [Q; Q(1,:)];                      % 补首点，确保闭合
end

% ================= 示例 =================
%{
% 生成一条开口的“椭圆+噪声”曲线（缺一小段）
t = linspace(0.15*pi, 1.85*pi, 300).';
a = 3; b = 2;
x = a*cos(t) + 0.02*randn(size(t));
y = b*sin(t) + 0.02*randn(size(t));
P = [x,y];

% 执行闭合拟合
C = fit_close_curve(P, 'Win', 12, 'BridgePts', 80, 'TangentScale', 0.5, 'ResampleN', 400);

% 可视化
figure; hold on; axis equal; box on;
plot(P(:,1), P(:,2), 'k--', 'LineWidth', 1);                 % 原开口曲线
plot(C.xy_open(:,1), C.xy_open(:,2), 'b', 'LineWidth', 1.5); % 保留主体
plot(C.bridge(:,1), C.bridge(:,2), 'r', 'LineWidth', 2);     % 桥接段
plot(C.xy(:,1), C.xy(:,2), 'g', 'LineWidth', 1.5);           % 闭合后(重采样)
legend('原始开口','主体(去端点)','Hermite桥接','闭合(最终)');
title('开口曲线 → 基于端点邻域的平滑闭合');
%}

