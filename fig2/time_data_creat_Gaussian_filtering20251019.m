
clear 
clc
load('E:\工作\硕士阶段文章\文章\螺旋喇叭\内容提交\上传\fig2\测试数据—频域处理.mat')
load('E:\工作\硕士阶段文章\文章\螺旋喇叭\内容提交\上传\fig2\pu_xy.mat')

c=3e8;
w=1.7:0.05:8.2;
w=w*1e9;
dx=0.01;
dy=0.01;
x=-0.5:dx:0.5;
y=-0.5:dy:0.5;
t=(0.4-0.6):0.001:(0.4+0.6);
t=t/c;
tt=t;
dt=t(2)-t(1);
[xx,yy,tt]=meshgrid(x,y,tt);
[x,y]=meshgrid(x,y);

x_fudu=10.^(-abs(x_fushu)/20);
y_fudu=10.^(-abs(y_fushu)/20);


x_xiangwei=angle(x_fushu);
y_xiangwei=angle(y_fushu);


for i=1:size(y_fudu,3)
    A_x=squeeze(x_fudu(50:end,:,i));
    B_x=squeeze(x_xiangwei(50:end,:,i));
    % A_x=squeeze(x_fudu(:,:,i));
    % B_x=squeeze(x_xiangwei(:,:,i));
    
[maxValue_x, linearIndex_x] = max(A_x(:));  
  
   
% 将线性索引转换为行和列索引  
[row_x,col_x ] = ind2sub(size(A_x), linearIndex_x);
    y_fudu_guiyi(:,:,i)=y_fudu(:,:,i)/A_x(row_x,col_x);
    x_fudu_guiyi(:,:,i)=x_fudu(:,:,i)/A_x(row_x,col_x);

    y_xiangwei_guiyi(:,:,i)=y_xiangwei(:,:,i)-B_x(row_x,col_x);
    x_xiangwei_guiyi(:,:,i)=x_xiangwei(:,:,i)-B_x(row_x,col_x);

end




for i=1:size(y_fudu,3)
y_fudu_jiaquan(:,:,i)=y_fudu_guiyi(:,:,i)*abs(pu_y(i));
x_fudu_jiaquan(:,:,i)=x_fudu_guiyi(:,:,i)*abs(pu_y(i));

y_xiangwei_jiaquan(:,:,i)=y_xiangwei_guiyi(:,:,i)+angle(pu_y(i));
x_xiangwei_jiaquan(:,:,i)=x_xiangwei_guiyi(:,:,i)+angle(pu_y(i));
end


%%

x_f_dimension_jiaquan_weipingyi=x_fudu_jiaquan.*exp(1i*x_xiangwei_jiaquan);
y_f_dimension_jiaquan_weipingyi=y_fudu_jiaquan.*exp(1i*y_xiangwei_jiaquan);


% 只在中心 40%×40% 的区域内找极小值并对齐
opts = struct('ref_mode','grid_center', ...
              'search_frac', 0.1, ...
              'subpixel','parabolic', ...
              'detect_smooth', 1);

out = align_by_minimum_center(x_f_dimension_jiaquan_weipingyi, y_f_dimension_jiaquan_weipingyi, x, y, opts);


x_f_dimension_jiaquan=out.Ex_aligned;
y_f_dimension_jiaquan=out.Ey_aligned;


theta = atan2(y, x);   % Nx × Ny

cosT = cos(theta);
sinT = sin(theta);



clear fff
for i=1:length(w)
fff(i,:)=exp(1i*2*pi*w(i)*t);
end

for i=1:size(x_xiangwei_jiaquan,1)
x_time_dimension(i,:,:)=real(squeeze(x_f_dimension_jiaquan(i,:,:))*fff);
y_time_dimension(i,:,:)=real(squeeze(y_f_dimension_jiaquan(i,:,:))*fff);
end



diff_ex_x=diff(x_time_dimension,1,2)/dx;
diff_ex_x(:,end+1,:)=diff_ex_x(:,end,:);
diff_ey_y=diff(y_time_dimension,1,1)/dy;
diff_ey_y(end+1,:,:)=diff_ey_y(end,:,:);

for i=1:size(x_time_dimension,3)
z_time_dimension(:,:,i)=-sum(diff_ey_y(:,:,1:i)+diff_ex_x(:,:,1:i),3)*c*dt;
end


%%

% 1) 按带宽法（你的系统）
opts.use_band = struct('f1',1.7e9,'f2',8.2e9,'k_sigma',1.5);
out = gaussian_time_gate_locked_vec3(x_time_dimension, y_time_dimension, z_time_dimension, dt, opts);

% 2) 或按主瓣1.5周期
opts2 = struct('cycles_fwhm', 1.5, 'f0', (1.7e9+8.2e9)/2);
out2  = gaussian_time_gate_locked_vec3(x_time_dimension, y_time_dimension, z_time_dimension,dt, opts2);

% 对比：门控前/后 |E| 包络（取某像素）
i=25; j=50; t=out.t;
plot(t, squeeze(out.Env_before(i,j,:))); hold on;
plot(t, squeeze(out.Env_after(i,j,:)), 'LineWidth',1.2);
legend('|E| before','|E| after'); grid on; xlabel('Time (s)');



x_time_dimension_levo=out.Ex_gated;
y_time_dimension_levo=out.Ey_gated;
z_time_dimension_levo=out.Ez_gated;

theta = atan2(y, x);   % Nx × Ny

cosT = cos(theta);
sinT = sin(theta);

% 初始化
[Ny, Nx, Nf] = size(x_time_dimension_levo);

for i = 1:Nf
    Ex_f = x_time_dimension_levo(:,:,i); 
    Ey_f = y_time_dimension_levo(:,:,i);

    % 广播方式
    rho_time_dimension_levo(:,:,i)   = Ex_f .* cosT + Ey_f .* sinT;
    theta_time_dimension_levo(:,:,i) = -Ex_f .* sinT + Ey_f .* cosT;
end


%
draw_z=squeeze(z_time_dimension(:,51,:));
draw_rho=squeeze(y_time_dimension(:,51,:));
draw_theta=squeeze(x_time_dimension(:,51,:));






close all
draw3d(xx,yy,tt,real(rho_time_dimension_levo),1,0.4)
 view(-26.0240,43.8709)
draw3d(xx,yy,tt,real(theta_time_dimension_levo),2,0.35)
 view(-26.0240,43.8709)

draw3d(xx,yy,tt,real(z_time_dimension_levo),3,0.35)
 view(-26.0240,43.8709)




%%

function out = gaussian_time_gate_locked_vec3(Ex, Ey, Ez, dt, opts)
% GAUSSIAN_TIME_GATE_LOCKED_VEC3
% 用整体幅度 |E| = sqrt(Ex^2 + Ey^2 + Ez^2) 的峰值位置 t0(x,y) 做“逐像素时间高斯门控”，
% 同一个标量高斯窗同步乘到 Ex/Ey/Ez（极化保持、零相位、不改峰位）。
%
% 输入:
%   Ex,Ey,Ez : (Nx, Ny, Nt) 实值，时间为第3维
%   dt       : 采样间隔(秒)
%   opts     : 可选参数（留空用默认）
%       —— 高斯宽度的三种设定方式（三选一，按优先级）——
%       .sigma_t     : 直接给时间标准差σ (秒)
%       .fwhm_t      : 直接给时间FWHM (秒)；sigma_t = fwhm_t/2.355
%       .use_band    : 由带宽估计σ：结构体 fields: f1,f2(Hz), k_sigma(默认1.2)
%                      sigma_t = k_sigma * 0.44 / (f2 - f1)
%       .cycles_fwhm : 以FWHM包含的调制周期数估计；需配合 .f0(Hz)
%                      FWHM_t = cycles_fwhm/f0, sigma_t = FWHM_t/2.355
%       .f0          : 调制中心频率Hz（与 cycles_fwhm 搭配）
%       —— 其他 —— 
%       .spatial_smooth_t0 : 对 t0(x,y) 做 2D 轻平滑窗口(奇数；默认0=不平滑)
%
% 输出:
%   .t                 : 1xNt 时间轴
%   .t0_idx            : Nx x Ny 峰值索引（按 |E|）
%   .t0_map            : Nx x Ny 峰值时刻(秒)
%   .sigma_t           : 实际使用的σ(秒)
%   .gate              : Nx x Ny x Nt 的高斯门控
%   .Ex_gated,Ey_gated,Ez_gated : 门控后三分量
%   .Env_before        : |E| 的Hilbert包络（门控前）
%   .Env_after         : |E| 的Hilbert包络（门控后）

if nargin<5, opts = struct; end
assert(isequal(size(Ex), size(Ey)) && isequal(size(Ey), size(Ez)), ...
    'Ex/Ey/Ez 尺寸必须一致 (Nx,Ny,Nt)');
[Nx,Ny,Nt] = size(Ex);
t = (0:Nt-1)*dt;

% ---------- 1) 用整体 |E| 找峰（幅度主导，锁死） ----------
Env_before = vec_envelope3(Ex, Ey, Ez);       % Nx x Ny x Nt
[~, t0_idx] = max(Env_before, [], 3);         % Nx x Ny
t0_map = (t0_idx - 1) * dt;                   % 秒

% 可选：对 t0 做一点空间平滑，降低像素级抖动
if isfield(opts,'spatial_smooth_t0') && ~isempty(opts.spatial_smooth_t0) ...
        && opts.spatial_smooth_t0>=3 && mod(opts.spatial_smooth_t0,2)==1
    k = opts.spatial_smooth_t0;
    ker = ones(k,k)/(k*k);
    t0_map = conv2(t0_map, ker, 'same');
end

% ---------- 2) 决定高斯宽度 sigma_t ----------
sigma_t = [];
if isfield(opts,'sigma_t') && ~isempty(opts.sigma_t)
    sigma_t = opts.sigma_t;
elseif isfield(opts,'fwhm_t') && ~isempty(opts.fwhm_t)
    sigma_t = opts.fwhm_t / 2.355;
elseif isfield(opts,'use_band') && ~isempty(opts.use_band)
    ub = opts.use_band;
    f1 = ub.f1; f2 = ub.f2;
    if ~isfield(ub,'k_sigma') || isempty(ub.k_sigma), ub.k_sigma = 1.2; end
    B = max(1e-9, f2 - f1);
    sigma_t = ub.k_sigma * 0.44 / B;
elseif isfield(opts,'cycles_fwhm') && ~isempty(opts.cycles_fwhm) ...
        && isfield(opts,'f0') && ~isempty(opts.f0)
    FWHM_t = opts.cycles_fwhm / opts.f0;
    sigma_t = FWHM_t / 2.355;
else
    % 默认：按 1.7–8.2 GHz 粗估
    f1=1.7e9; f2=8.2e9; B=f2-f1; k_sigma=1.2;
    sigma_t = k_sigma * 0.44 / B;   % ~ O(80-130 ps)，视 k_sigma
end

% 安全提示
if sigma_t < 2*dt
    warning('sigma_t (%.3g s) 过小，相对采样间隔 dt=%.3g s，建议适当增大。', sigma_t, dt);
end

% ---------- 3) 构造逐像素时间高斯门控 g(x,y,t) ----------
t_arr = reshape(t, [1 1 Nt]);               % 1x1xNt
T0    = repmat(t0_map, [1 1 Nt]);           % Nx x Ny x Nt
Tau   = bsxfun(@minus, t_arr, T0);          % Nx x Ny x Nt
gate  = exp(-0.5 * (Tau./sigma_t).^2);      % Nx x Ny x Nt

% ---------- 4) 同步门控三分量（极化保持） ----------
Ex_gated = bsxfun(@times, Ex, gate);
Ey_gated = bsxfun(@times, Ey, gate);
Ez_gated = bsxfun(@times, Ez, gate);

% ---------- 5) 结果包络（仅用于可视化/验证） ----------
Env_after = vec_envelope3(Ex_gated, Ey_gated, Ez_gated);

% ---------- 输出 ----------
out.t          = t;
out.t0_idx     = t0_idx;
out.t0_map     = t0_map;
out.sigma_t    = sigma_t;
out.gate       = gate;
out.Ex_gated   = Ex_gated;
out.Ey_gated   = Ey_gated;
out.Ez_gated   = Ez_gated;
out.Env_before = Env_before;
out.Env_after  = Env_after;
end

% ====== 工具：|E| 的Hilbert包络（沿第3维），含三分量 ======
function Env = vec_envelope3(Ex, Ey, Ez)
Hx = hilbert_dim3(Ex);
Hy = hilbert_dim3(Ey);
Hz = hilbert_dim3(Ez);
Env = sqrt(abs(Hx).^2 + abs(Hy).^2 + abs(Hz).^2);
end

% ====== 工具：沿第3维 Hilbert，返回解析信号 ======
function Y = hilbert_dim3(X)
[~,~,Nt] = size(X);
F = fft(X, [], 3);
H = zeros(1,1,Nt);
if mod(Nt,2)==0
    H(1,1,1)=1; H(1,1,Nt/2+1)=1; H(1,1,2:Nt/2)=2;
else
    H(1,1,1)=1; H(1,1,2:(Nt+1)/2)=2;
end
Y = ifft(F .* H, [], 3);
end


%%

function draw3d(x,y,t,x_time_dimension,aaa,bbb)
figure(aaa)
f=real(x_time_dimension)/max(max(max(real(x_time_dimension))));

p1 = patch(isosurface(x,y,t,f,bbb));
isonormals(x,y,t,f,p1)
p1.EdgeColor = 'none';
p1.FaceColor =[256,32,46]/256;
view(3)

p1 = patch(isosurface(x,y,t,f,-bbb));
isonormals(x,y,t,f,p1)
p1.EdgeColor = 'none';
p1.FaceColor = [39,111,256]/256;
view(3)
camlight 
camproj perspective
lighting phong 

material dull  

for i=-1:2:1
for j=-1:2:1
for k=1
    l1 = light;
l1.Style = 'local ';
l1.Position = [i j k];
end
end
end
    daspect([1 1 2.5e-9])
xlim([-0.4,0.4])
ylim([-0.4,0.4])
zlim([1.2e-9,2e-9])

%     set(gca,'ZDir','reverse'); 
view(-37.5,30)
grid on

set(gca, 'ZTick', [1.2e-9,2e-9]);
set(gca, 'XTick', [-0.4,0,0.4]);
set(gca, 'YTick', [-0.4,0,0.4]);

set(gca, 'FontSize',30,'FontName','Times New Roman');%字体


end




function out = align_by_minimum_center(Ex_f, Ey_f, X, Y, opts)
% ALIGN_BY_MINIMUM_CENTER
% 仅通过“幅度极小值”定位并做二维平移对准；不做任何滤波/加窗/归一化。
% —— 输入 —— 
% Ex_f, Ey_f : [Nx,Ny,Nf] 复/实均可（每个频点一幅二维场）
% X, Y       : [Nx,Ny]    网格坐标（仅用于输出/可视化；对准在像素坐标完成）
% opts (可选):
%   .ref_mode        : 'grid_center' | 'ref_freq'  默认 'grid_center'
%   .ref_index       : 当 ref_mode='ref_freq' 时的参考频点索引（默认 ceil(Nf/2)）
%   .subpixel        : 'parabolic' | 'none'        默认 'parabolic'（3点二次拟合）
%   .detect_smooth   : 0/1 是否用3x3均值平滑后再找极小值（仅用于检测；默认 1）
%   .search_frac     : 中心搜索窗口占比（标量或 [sf_y sf_x]，0<s≤1；默认 []=全图）
%
% —— 输出 —— 
% out.Ex_aligned, out.Ey_aligned : [Nx,Ny,Nf] 仅平移对齐后的场（空白区=0）
% out.min_pos_px                 : [Nf,2] 每频点极小值的(行,列)像素坐标（亚像素）
% out.shifts_xy                  : [Nf,2] 每频点相对参考中心的 (dx,dy)（列向/行向，单位=像素）
% out.ref_center_px              : [row,col] 参考中心像素坐标（亚像素）
% out.ref_index                  : 实际使用的参考频点索引（若 ref_mode='grid_center'，则为空）
% out.search_win_rc              : [rmin rmax cmin cmax] 实际使用的搜索窗口（像素）
% out.X, out.Y                   : 原样回传

if nargin<5, opts = struct; end
[Nx,Ny,Nf] = size(Ex_f);
assert(isequal(size(Ey_f),[Nx,Ny,Nf]), 'Ey_f 尺寸需与 Ex_f 一致');
assert(isequal(size(X),[Nx,Ny]) && isequal(size(Y),[Nx,Ny]), 'X/Y 尺寸应为 [Nx,Ny]');

% -------- 选项 --------
ref_mode  = get_opt(opts,'ref_mode','grid_center'); ref_mode=lower(string(ref_mode));
ref_index = get_opt(opts,'ref_index', ceil(Nf/2));
subpixel  = get_opt(opts,'subpixel','parabolic');
do_smooth = logical(get_opt(opts,'detect_smooth',1));
search_frac = get_opt(opts,'search_frac', []);

% -------- 像素网格 --------
[col_grid, row_grid] = meshgrid(1:Ny, 1:Nx);   % 列= x，行= y（图像坐标）

% -------- 计算搜索窗口（像素）--------
if isempty(search_frac)
    rmin=1; rmax=Nx; cmin=1; cmax=Ny;     % 全图
else
    if isscalar(search_frac), sf_y = search_frac; sf_x = search_frac;
    else, sf_y = search_frac(1); sf_x = search_frac(2);
    end
    sf_y = min(max(sf_y,eps),1);  sf_x = min(max(sf_x,eps),1);
    h_y = round(Nx*sf_y/2);  h_x = round(Ny*sf_x/2);
    cy  = (Nx+1)/2;         cx  = (Ny+1)/2;     % 窗口中心取几何中心
    rmin = max(1, floor(cy - h_y));  rmax = min(Nx, ceil(cy + h_y));
    cmin = max(1, floor(cx - h_x));  cmax = min(Ny, ceil(cx + h_x));
end
search_win_rc = [rmin rmax cmin cmax];

% -------- 计算每个频点的幅度图，并在窗口内寻找极小值（可选平滑+亚像素）--------
min_pos_px = zeros(Nf,2);  % [row, col]
for k = 1:Nf
    A = sqrt( abs(Ex_f(:,:,k)).^2 + abs(Ey_f(:,:,k)).^2 );
    if do_smooth
        A = conv2(A, ones(3,3)/9, 'same');   % 仅用于检测，不影响输出数据
    end
    % 只在窗口内搜索：窗口外置为 +Inf
    Am = A;
    if ~(rmin==1 && rmax==Nx && cmin==1 && cmax==Ny)
        Am(:,1:cmin-1) = +Inf; Am(:,cmax+1:end) = +Inf;
        Am(1:rmin-1,:) = +Inf; Am(rmax+1:end,:) = +Inf;
    end

    % 整像素极小值
    [~, idx] = min(Am(:));
    [r0, c0] = ind2sub([Nx,Ny], idx);

    % 亚像素细化（在 A 上做，仍保证索引安全）
    if strcmpi(subpixel,'parabolic')
        rL = max(r0-1,1); rR = min(r0+1,Nx);
        a = A(rL,c0); b = A(r0,c0); c = A(rR,c0);
        den = (a - 2*b + c);
        if abs(den)>1e-12, dr = 0.5*(a - c)/den; else, dr = 0; end

        cL = max(c0-1,1); cR = min(c0+1,Ny);
        a = A(r0,cL); b = A(r0,c0); c = A(r0,cR);
        den = (a - 2*b + c);
        if abs(den)>1e-12, dc = 0.5*(a - c)/den; else, dc = 0; end

        r_hat = r0 + dr;  c_hat = c0 + dc;
        % 仍将亚像素结果限制在窗口内（防止外推）
        r_hat = min(max(r_hat, rmin), rmax);
        c_hat = min(max(c_hat, cmin), cmax);
    else
        r_hat = r0; c_hat = c0;
    end
    min_pos_px(k,:) = [r_hat, c_hat];
end

% -------- 确定参考中心（像素坐标）--------
ref_index_used = [];
switch ref_mode
    case "grid_center"
        ref_row = (Nx+1)/2; ref_col = (Ny+1)/2;   % 网格几何中心（亚像素）
    case "ref_freq"
        ref_index_used = max(1,min(Nf,ref_index));
        ref_row = min_pos_px(ref_index_used,1);
        ref_col = min_pos_px(ref_index_used,2);
    otherwise
        error('ref_mode 必须为 ''grid_center'' 或 ''ref_freq''');
end
ref_center_px = [ref_row, ref_col];

% -------- 计算每个频点的平移量（像素）并执行仅平移（外填 0）--------
Ex_al = zeros(Nx,Ny,Nf, class(Ex_f));
Ey_al = zeros(Nx,Ny,Nf, class(Ey_f));
shifts_xy = zeros(Nf,2);  % (dx,dy) = (列向右为正, 行向下为正)

for k = 1:Nf
    r_hat = min_pos_px(k,1); c_hat = min_pos_px(k,2);
    dy = ref_row - r_hat;      % 行方向：正为向下
    dx = ref_col - c_hat;      % 列方向：正为向右
    shifts_xy(k,:) = [dx, dy];

    % —— 仅平移（双线性插值，外填 0）——
    Ex_al(:,:,k) = interp2(col_grid, row_grid, Ex_f(:,:,k), ...
                           col_grid - dx,   row_grid - dy, 'linear', 0);
    Ey_al(:,:,k) = interp2(col_grid, row_grid, Ey_f(:,:,k), ...
                           col_grid - dx,   row_grid - dy, 'linear', 0);
end

% -------- 输出 --------
out.Ex_aligned     = Ex_al;
out.Ey_aligned     = Ey_al;
out.min_pos_px     = min_pos_px;        % 每频点极小值估计位置（像素）
out.shifts_xy      = shifts_xy;         % 对齐到参考中心的平移量（像素）
out.ref_center_px  = ref_center_px;     % 参考中心（像素）
out.ref_index      = ref_index_used;    % 若用 grid_center，此处为空
out.search_win_rc  = search_win_rc;     % 实际搜索窗口（像素）
out.X = X; out.Y = Y;

end

% ============== 小工具：读取选项 ==============
function v = get_opt(s, name, default)
if isfield(s,name) && ~isempty(s.(name)), v = s.(name); else, v = default; end
end
