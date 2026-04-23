function S = sample_axisym_from_radial_line(r, erho, etheta, ez, varargin)
% 从一条半径线 (r, erho, etheta, ez) 生成旋转对称圆盘上的随机采样
% —— 仅返回数据，不做绘图 ——
%
% 新增(可选)：
%   'AlphaCounts'  [1x9]  每个仰角段的目标采样数（9段合计即最终样本数）
%   'AlphaEdges'   [1x10] 仰角段边界（弧度），默认 linspace(-pi/2,pi/2,10)
%   'RGridN'       r 轴细分点数用于分段映射（默认 4000）
%
% 其余参数（与旧版一致）：
%   'NumSamples'  (默认 1500)   当未给 AlphaCounts 时使用（普通均匀采样）
%   'RRange'      (默认 [0,max(r)])
%   'Seed'        (默认 [])
%   'Z0'          (默认 0)
%   'Interp'      (默认 'pchip')
%
% 输出 S:
%   X,Y,Z, Ex,Ey,Ez, rr,phi, alpha, r_used, method

% -------- 参数 --------
p = inputParser;
p.addParameter('NumSamples', 1500, @(x)isnumeric(x)&&isscalar(x)&&x>0);
p.addParameter('RRange',     [],    @(x)isnumeric(x)&&~isempty(x));
p.addParameter('Seed',       [],    @(x)isempty(x)||(isnumeric(x)&&isscalar(x)));
p.addParameter('Z0',         0,     @(x)isnumeric(x)&&isscalar(x));
p.addParameter('Interp',     'pchip', @(x)ischar(x)||isstring(x));
% 新增
p.addParameter('AlphaCounts', [], @(x)isnumeric(x)&&isvector(x)&&numel(x)==9);
p.addParameter('AlphaEdges',  [], @(x)isnumeric(x)&&isvector(x)&&numel(x)==10);
p.addParameter('RGridN',      4000, @(x)isnumeric(x)&&isscalar(x)&&x>=200);
p.parse(varargin{:});
opt = p.Results;
opt.Interp = char(opt.Interp);

% -------- 输入整理 --------
r      = r(:); erho = erho(:); etheta = etheta(:); ez = ez(:);
Nr = numel(r);
assert(all([numel(erho),numel(etheta),numel(ez)]==Nr, 'all'), 'r/分量尺寸不一致');
if any(diff(r)<=0), error('r 必须严格递增'); end
if r(1)==0
    if ~isfinite(erho(1)),   erho(1)=0;   end
    if ~isfinite(etheta(1)), etheta(1)=0; end
end

% 沿 r 去 NaN
erho   = local_interp_nan1d_axisym(r, erho,   opt.Interp);
etheta = local_interp_nan1d_axisym(r, etheta, opt.Interp);
ez     = local_interp_nan1d_axisym(r, ez,     opt.Interp);

% 插值器
FER = @(rq) interp1(r, erho,   rq, opt.Interp, 'extrap');
FET = @(rq) interp1(r, etheta, rq, opt.Interp, 'extrap');
FEZ = @(rq) interp1(r, ez,     rq, opt.Interp, 'extrap');

% 半径范围
if ~isempty(opt.Seed), rng(opt.Seed); end
if isempty(opt.RRange)
    rmin = max(0, min(r)); rmax = max(r);
elseif numel(opt.RRange)==1
    rmin = max(0, min(r)); rmax = min(opt.RRange, max(r));
else
    rmin = max(0, min(opt.RRange)); rmax = min(max(opt.RRange), max(r));
end
if rmax <= rmin, error('RRange 无效：需要 rmax>rmin'); end

% -------- 情况 A：未指定 AlphaCounts → 原来均匀采样 --------
if isempty(opt.AlphaCounts)
    N   = opt.NumSamples;
    U   = rand(N,1);
    phi = 2*pi*rand(N,1);
    rr  = sqrt(U) * (rmax - rmin) + rmin;

    Er = FER(rr); Et = FET(rr); Ezv = FEZ(rr);
    Ex = Er.*cos(phi) - Et.*sin(phi);
    Ey = Er.*sin(phi) + Et.*cos(phi);

    X = rr.*cos(phi); Y = rr.*sin(phi); Z = opt.Z0*ones(N,1);
    alpha = atan2(Ezv, hypot(Ex,Ey));

    S = struct('X',X,'Y',Y,'Z',Z, ...
               'Ex',Ex,'Ey',Ey,'Ez',Ezv, ...
               'rr',rr,'phi',phi,'alpha',alpha, ...
               'r_used',[rmin; rmax], ...
               'method',opt.Interp);
    return;
end

% -------- 情况 B：按仰角9段定向采样（基于 r→alpha 映射）--------
alpha_edges = opt.AlphaEdges;
if isempty(alpha_edges), alpha_edges = linspace(-pi/2, +pi/2, 10); end
counts = double(opt.AlphaCounts(:).');
assert(numel(counts)==9 && all(counts>=0), 'AlphaCounts 需为长度9且非负');

% 在 r 轴上构建高分辨率网格并计算 alpha(r)
rgrid = linspace(rmin, rmax, opt.RGridN).';
Erg = FER(rgrid); Etg = FET(rgrid); Ezg = FEZ(rgrid);
alpha_r = atan2(Ezg, hypot(Erg, Etg));   % ★ 仅依赖 r

% 每一段：只在 alpha_r 落入该段的 rgrid 子集中抽样 r
X_all=[]; Y_all=[]; Z_all=[]; Ex_all=[]; Ey_all=[]; Ez_all=[];
rr_all=[]; phi_all=[]; alpha_all=[];

for k = 1:9
    nk = counts(k);
    if nk==0, continue; end
    mask = (alpha_r >= alpha_edges(k)) & (alpha_r < alpha_edges(k+1));
    idxk = find(mask);
    if isempty(idxk)
        warning('Alpha bin %d 无可用 r 覆盖（[%g,%g]）。该段返回 0 点。', ...
            k, alpha_edges(k), alpha_edges(k+1));
        continue;
    end
    % 面积权重：w ∝ r
    rk = rgrid(idxk);
    wk = rk;
    wk = wk / sum(wk);

    % 以权重 wk 抽 nk 个 r（有放回，保证配额）
    rk_pick = rk( weighted_rand_idx(wk, nk) );

    % 为该段生成 phi 并计算向量/坐标
    phik = 2*pi*rand(nk,1);
    Erk = FER(rk_pick); Etk = FET(rk_pick); Ezk = FEZ(rk_pick);
    Exk = Erk.*cos(phik) - Etk.*sin(phik);
    Eyk = Erk.*sin(phik) + Etk.*cos(phik);

    Xk = rk_pick.*cos(phik); Yk = rk_pick.*sin(phik); Zk = opt.Z0*ones(nk,1);
    alphak = atan2(Ezk, hypot(Exk,Eyk));

    % 累加
    X_all   = [X_all;   Xk]; %#ok<AGROW>
    Y_all   = [Y_all;   Yk]; %#ok<AGROW>
    Z_all   = [Z_all;   Zk]; %#ok<AGROW>
    Ex_all  = [Ex_all;  Exk]; %#ok<AGROW>
    Ey_all  = [Ey_all;  Eyk]; %#ok<AGROW>
    Ez_all  = [Ez_all;  Ezk]; %#ok<AGROW>
    rr_all  = [rr_all;  rk_pick]; %#ok<AGROW>
    phi_all = [phi_all; phik]; %#ok<AGROW>
    alpha_all = [alpha_all; alphak]; %#ok<AGROW>
end

S = struct('X',X_all,'Y',Y_all,'Z',Z_all, ...
           'Ex',Ex_all,'Ey',Ey_all,'Ez',Ez_all, ...
           'rr',rr_all,'phi',phi_all,'alpha',alpha_all, ...
           'r_used',[rmin; rmax], ...
           'method',opt.Interp);
end

% ====== 权重抽样（有放回）返回索引 ======
function I = weighted_rand_idx(w, n)
% w >=0, sum(w)=1
cw = cumsum(w(:));
u  = rand(n,1);
I  = arrayfun(@(x) find(cw>=x,1,'first'), u);
end

% ===== 本地子函数：沿 r 插 NaN，边缘就近（独特命名避免冲突） =====
function vout = local_interp_nan1d_axisym(r, vin, method)
vout = vin;
mask = isfinite(vin);
if all(mask), return; end
if ~any(mask), vout(:) = 0; return; end
vout(~mask) = interp1(r(mask), vin(mask), r(~mask), method, 'extrap');
iL = find(mask, 1, 'first');
iR = find(mask, 1, 'last');
vout(1:iL)   = vin(iL);
vout(iR:end) = vin(iR);
end
