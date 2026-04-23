function S = sample_axisym_from_radial_line_biased(r, erho, etheta, ez, varargin)
% 旋转对称：从径向线 (r,erho,etheta,ez) 生成随机采样
% —— 提供“北极增采样”与“中心半径偏置”以增加北极附近的点数 —— 
%
% Name-Value 主要参数：
%   'NumSamples'  最终需要的样本数 (默认 1500)
%   'RRange'      采样半径范围，标量 rmax 或 [rmin rmax]（默认 [0,max(r)]）
%   'Seed'        随机种子
%   'Z0'          本截面 z 坐标（所有点的 z）
%   'Interp'      'pchip' | 'linear'（默认 'pchip'）
%   'CenterBias'  半径中心偏置指数 a（默认 0.5 = 等面积；>0.5 更靠近中心；=1 线性半径）
%   'NorthBoost'  是否启用北极增权（默认 true）
%   'BoostPower'  增权幂次 p（默认 2，越大越更偏向 Uz≈1）
%   'Oversample'  候选过采样倍率（默认 3；北极增权启用时推荐 ≥2）
%   'UzMin'       可选阈值，仅保留 Uz ≥ UzMin 的候选（默认 [] 不启用）
%
% 输出字段：
%   X,Y,Z, Ex,Ey,Ez, rr,phi, alpha（仰角）, Uz, r_used, method

p = inputParser;
p.addParameter('NumSamples', 1500, @(x)isnumeric(x)&&isscalar(x)&&x>0);
p.addParameter('RRange',     [],    @(x)isnumeric(x)&&~isempty(x));
p.addParameter('Seed',       [],    @(x)isempty(x)||(isnumeric(x)&&isscalar(x)));
p.addParameter('Z0',         0,     @(x)isnumeric(x)&&isscalar(x));
p.addParameter('Interp',     'pchip', @(x)ischar(x)||isstring(x));
p.addParameter('CenterBias', 0.5,   @(x)isnumeric(x)&&isscalar(x)&&x>0);
p.addParameter('NorthBoost', true,   @(x)islogical(x)||ismember(x,[0 1]));
p.addParameter('BoostPower', 2,      @(x)isnumeric(x)&&isscalar(x)&&x>=0);
p.addParameter('Oversample', 3,      @(x)isnumeric(x)&&isscalar(x)&&x>=1);
p.addParameter('UzMin',      [],     @(x)isempty(x)||(isnumeric(x)&&isscalar(x)&&x<=1&&x>=-1));
p.parse(varargin{:});
opt = p.Results;
opt.Interp = char(opt.Interp);

% ---- 输入与清洗 ----
r = r(:); erho = erho(:); etheta = etheta(:); ez = ez(:);
Nr = numel(r);
assert(all([numel(erho),numel(etheta),numel(ez)]==Nr), 'r/分量尺寸不一致');
if any(diff(r)<=0), error('r 必须严格递增'); end
if r(1)==0
    if ~isfinite(erho(1)),   erho(1)=0;   end
    if ~isfinite(etheta(1)), etheta(1)=0; end
end
erho   = local_interp_nan1d_axisym(r, erho,   opt.Interp);
etheta = local_interp_nan1d_axisym(r, etheta, opt.Interp);
ez     = local_interp_nan1d_axisym(r, ez,     opt.Interp);

FER = @(rq) interp1(r, erho,   rq, opt.Interp, 'extrap');
FET = @(rq) interp1(r, etheta, rq, opt.Interp, 'extrap');
FEZ = @(rq) interp1(r, ez,     rq, opt.Interp, 'extrap');

% ---- 半径范围 ----
if ~isempty(opt.Seed), rng(opt.Seed); end
if isempty(opt.RRange)
    rmin = max(0, min(r)); rmax = max(r);
elseif numel(opt.RRange)==1
    rmin = max(0, min(r)); rmax = min(opt.RRange, max(r));
else
    rmin = max(0, min(opt.RRange)); rmax = min(max(opt.RRange), max(r));
end
if rmax <= rmin, error('RRange 无效：需要 rmax>rmin'); end

% ---- 生成候选样本（过采样）----
Nfinal = opt.NumSamples;
Ncand  = max(Nfinal, ceil(opt.Oversample * Nfinal));

% 半径中心偏置：rr = rmin + (rmax-rmin) * U^a
% a=0.5 等面积；a>0.5 更靠中心；a=1 线性半径（更强中心偏置）
U = rand(Ncand,1);
a = opt.CenterBias;
rr  = rmin + (rmax - rmin) * U.^a;
phi = 2*pi*rand(Ncand,1);

% 柱 -> 直角
Er = FER(rr);  Et = FET(rr);  Ez0 = FEZ(rr);
Ex = Er.*cos(phi) - Et.*sin(phi);
Ey = Er.*sin(phi) + Et.*cos(phi);
Ezv = Ez0;

% 方向归一化，得到 Uz（用于北极判定）
mag = sqrt(Ex.^2 + Ey.^2 + Ezv.^2); mag(mag==0)=1;
Ux = Ex./mag; Uy = Ey./mag; Uz = Ezv./mag;

% ---- 北极增权抽样（可选）----
if ~isempty(opt.UzMin)
    keep = Uz >= opt.UzMin;
else
    keep = true(size(Uz));
end

if opt.NorthBoost
    w = max(Uz, 0).^opt.BoostPower;   % Uz 越大越容易被采样
    if all(w==0)
        w(:) = 1;  % 防止退化
    else
        w = w / max(w);
    end
    pick = (rand(Ncand,1) <= w) & keep;
else
    pick = keep;
end

idx = find(pick);
if numel(idx) < Nfinal
    % 候选不足：补齐（随机从剩余里补）
    rest = setdiff(1:Ncand, idx);
    need = Nfinal - numel(idx);
    need = min(need, numel(rest));
    idx = [idx; rest(randperm(numel(rest), need))']; %#ok<AGROW>
elseif numel(idx) > Nfinal
    idx = idx(randperm(numel(idx), Nfinal));
else
    % 恰好 Nfinal
end

% 取最终样本
idx = idx(:);
rr  = rr(idx); phi = phi(idx);
Ex  = Ex(idx); Ey = Ey(idx); Ezv = Ezv(idx);
Ux  = Ux(idx); Uy = Uy(idx); Uz = Uz(idx);

% 输出
X = rr.*cos(phi); Y = rr.*sin(phi); Z = opt.Z0*ones(numel(idx),1);
alpha = atan2(Uz, hypot(Ux,Uy));   % 可用于上色

S = struct('X',X,'Y',Y,'Z',Z, ...
           'Ex',Ex,'Ey',Ey,'Ez',Ezv, ...
           'Ux',Ux,'Uy',Uy,'Uz',Uz, ...
           'rr',rr,'phi',phi,'alpha',alpha, ...
           'r_used',[rmin; rmax], ...
           'method',opt.Interp, ...
           'center_bias',a, ...
           'north_boost',opt.NorthBoost, ...
           'boost_power',opt.BoostPower, ...
           'oversample',opt.Oversample, ...
           'UzMin',opt.UzMin);
end

% ===== 本地子函数（避免命名冲突）=====
function vout = local_interp_nan1d_axisym(r, vin, method)
vout = vin;
mask = isfinite(vin);
if all(mask), return; end
if ~any(mask), vout(:)=0; return; end
vout(~mask) = interp1(r(mask), vin(mask), r(~mask), method, 'extrap');
iL = find(mask,1,'first'); iR = find(mask,1,'last');
vout(1:iL)   = vin(iL);
vout(iR:end) = vin(iR);
end
