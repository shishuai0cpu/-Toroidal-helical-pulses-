
function [rho_fix, theta_fix, z_fix, report] = fix_axis_nan_rz(draw_rho, draw_theta, draw_z, r, opts)
% 修补 r=0 轴上 NaN：rho/theta=0，z 分量用偶函数拟合外推
% 输入:
%   draw_rho, draw_theta, draw_z : [Nr x Nz]，行=r，列=z
%   r : [Nr x 1] 或 [1 x Nr]，单调递增且 r(1)≈0
%   opts (可选)
%       .fit_k        用于拟合的最近半径圈数(默认 4；自动截断到有效点数)
%       .fit_deg      偶次多项式的最大幂次(默认 2 => 拟合 a + b r^2 + c r^4)
%       .interp_rest  是否对非轴上的 NaN 做径向插值(默认 true)
%       .smooth_z_win 轴上 z(0,·) 的轻度沿 z 平滑窗口(奇数；默认 1=不平滑)
%       .verbose      输出报告(默认 true)
%
% 输出:
%   rho_fix, theta_fix, z_fix : 修补后的数组（尺寸同输入）
%   report : 结构体，记录每个 z 列的拟合用点数、失败回退等信息

if nargin < 5, opts = struct(); end
if ~isfield(opts,'fit_k'),        opts.fit_k = 4; end
if ~isfield(opts,'fit_deg'),      opts.fit_deg = 2; end % 2=>最高到 r^4
if ~isfield(opts,'interp_rest'),  opts.interp_rest = true; end
if ~isfield(opts,'smooth_z_win'), opts.smooth_z_win = 1; end
if ~isfield(opts,'verbose'),      opts.verbose = true; end

[Nr, Nz] = size(draw_rho);
r = r(:);
assert(numel(r)==Nr, 'r 长度必须等于行数 Nr');
if any(diff(r)<=0), error('r 必须严格递增'); end
if abs(r(1)) > 1e-12 && opts.verbose
    warning('r(1) 不是 0（当前 %.3g）。若靠近 0 也可使用本法，但请确认网格。', r(1));
end

rho_fix   = draw_rho;
theta_fix = draw_theta;
z_fix     = draw_z;

% 1) 轴上 rho/theta 置 0（若为 NaN 或非零都强制满足边界条件）
rho_fix(1,:)   = 0;
theta_fix(1,:) = 0;

% 2) 先可选对每列其它 r 位置的 NaN 做径向插值（防止拟合时有效点不足）
if opts.interp_rest
    for jz = 1:Nz
        % rho/theta/z 各自单独插值
        rho_fix(:,jz)   = interp_nan_1d_r(r, rho_fix(:,jz));
        theta_fix(:,jz) = interp_nan_1d_r(r, theta_fix(:,jz));
        z_fix(:,jz)     = interp_nan_1d_r(r, z_fix(:,jz));
    end
end

% 3) 对 z 分量在 r=0 外推：对小半径点做偶函数拟合（r^2 多项式）
used_pts   = zeros(1, Nz);
fallbacks  = false(1, Nz);
z_axis_val = nan(1, Nz);

% 允许的最大次数：deg=2 表示到 r^4；deg=1 表示到 r^2；deg=0 表示常数
deg = max(0, round(opts.fit_deg));
powers = 0:deg;  % 对应 r^(2*power)

for jz = 1:Nz
    col = z_fix(:, jz);
    % 挑选靠近轴的、有限的非 NaN 点（不包括 r=0 本身）
    finite_mask = isfinite(col) & ( (1:Nr).' > 1 );  % r>0 的位置
    if ~any(finite_mask)
        % 整列都不可用，轴上值只能置 0
        z_axis_val(jz) = 0;
        fallbacks(jz)  = true;
        continue;
    end
    % 取前 k 个半径圈（最靠近轴）
    idx_pos = find(finite_mask, opts.fit_k, 'first');
    x = r(idx_pos).^2;         % 用 r^2 作为自变量，保证偶性
    y = col(idx_pos);
    used_pts(jz) = numel(idx_pos);

    % 构造设计矩阵： [1, x, x.^2, ...]
    X = ones(numel(x), deg+1);
    for p = 1:deg
        X(:,p+1) = x.^p;
    end

    % 稳健回归（如果有统计工具箱可用 robustfit，否则用最小二乘）
    % 这里使用普通最小二乘，通常已足够
    coeff = X \ y;
    z0 = coeff(1);   % 截距即 r=0 的外推值
    if ~isfinite(z0)
        % 回退：取最靠近轴的有限值
        z0 = y(1);
        fallbacks(jz) = true;
    end
    z_axis_val(jz) = z0;
end

% 4) 可选：沿 z 对 z(0,z) 做一个轻度平滑，避免微小震荡
w = max(1, round(opts.smooth_z_win));
if mod(w,2)==0, w = w+1; end % 必须奇数
if w > 1
    z_axis_val = movmean(z_axis_val, w, 'Endpoints','shrink');
end

% 5) 写回轴上值
z_fix(1, :) = z_axis_val;

% 报告
report = struct();
report.used_pts  = used_pts;
report.fallbacks = fallbacks;
report.fit_deg   = deg;
report.fit_k     = opts.fit_k;
report.smoothed  = (w>1);

if opts.verbose
    nfb = nnz(fallbacks);
    if nfb>0
        fprintf('[fix_axis_nan_rz] 有 %d 列使用了回退（最近点替代）。\n', nfb);
    end
end

end % function

% ====== 辅助函数：沿 r 对单列做 1D 插值，温和且稳健 ======
function vout = interp_nan_1d_r(r, vin)
% - 优先保留已有有限值
% - 对内部 NaN 用 'pchip' 插值
% - 边缘 NaN 用最近值外推
vout = vin;
mask = isfinite(vin);
if all(mask)
    return;
end
if ~any(mask)
    vout(:) = 0;
    return;
end
% 内部插值
vout(~mask) = interp1(r(mask), vin(mask), r(~mask), 'pchip', 'extrap');
% 再保护边缘：把最左/最右端拉回最近有限值，避免不稳外推
iL = find(mask, 1, 'first');
iR = find(mask, 1, 'last');
vout(1:iL) = vin(iL);
vout(iR:end) = vin(iR);
end

