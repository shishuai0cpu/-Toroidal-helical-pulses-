


%% === 加载你保存的变量 ===
% x -> z坐标, y -> rho坐标
clear 
load('E:\工作\硕士阶段文章\文章\数据整理\涡旋斯格名子\画图与处理程序与数据\fig1\平面矢量追踪结果3.mat'); 

z_curve   = Xc;   % x轴对应z分量
rho_curve = Yc-0.5;   % y轴对应rho分量
%%
z_curve   =- Xc;   % x轴对应z分量
Etheta_c=-Etheta_c;
Ez_c=-Ez_c;


%% === 参数 ===
Nphi = 200;               
phi = linspace(0,2*pi,Nphi);

%% === 展开为网格 (s,phi) ===
[z_g,   phi_g] = ndgrid(z_curve, phi);
[rho_g, ~    ] = ndgrid(rho_curve, phi);

%% === 生成三维坐标 ===
X = rho_g .* cos(phi_g);
Y = rho_g .* sin(phi_g);
Z = z_g;

%% === 复制场分量 (轴对称) ===
erho_g   = repmat(Erho_c,   1, Nphi);
etheta_g = repmat(Etheta_c, 1, Nphi);
ez_g     = repmat(Ez_c,     1, Nphi);

em=sqrt(erho_g.^2+etheta_g.^2+ez_g.^2);
plot(etheta_g./em)


%% === 柱坐标 → 笛卡尔坐标 ===
cosphi = cos(phi_g);
sinphi = sin(phi_g);

Ex = erho_g .* cosphi + etheta_g .* (-sinphi);
Ey = erho_g .* sinphi + etheta_g .* ( cosphi);
Ez = ez_g;

%% === 可视化 ===


figure('Color','w');
surf(X, Y, Z, sqrt(Ex.^2 + Ey.^2 + Ez.^2),'EdgeColor','none');
axis equal; xlabel('x'); ylabel('y'); zlabel('z');
title('|E| on torus'); colorbar;
camlight; lighting gouraud;

hold on;
sk = 1;
quiver3(X(1:sk:end,1:sk:end),Y(1:sk:end,1:sk:end),Z(1:sk:end,1:sk:end), ...
        Ex(1:sk:end,1:sk:end),Ey(1:sk:end,1:sk:end),Ez(1:sk:end,1:sk:end),'k');
hold off;




%% === 保存 ===
% save('torus_field_corrected.mat','X','Y','Z','Ex','Ey','ez3');
% disp('✅ torus_field_corrected.mat 已生成');

%%

[Ns,Nphi] = size(X);

% 种子点（参数索引坐标）：s 方向均匀取几条，phi 随便几列
seeds = [
    linspace(3, Ns-10, 5).',  20*ones(5,1);
    linspace(3, Ns-10, 5).',  80*ones(5,1);
];

curves = trace_stream_on_surface(X,Y,Z,Ex,Ey,Ez, seeds, struct( ...
    'h', 0.003, 'max_steps', 6000, 'close_tol', 4, ...
    'ds_scale', 1.0, 'dphi_scale', 1.0, ...
    'allow_reverse', true));

%% 可视化
close all
figure('Color','w');
s1=surf(X,Y,Z, sqrt(Ex.^2+Ey.^2+Ez.^2), 'EdgeColor','none'); hold on;
s1.FaceAlpha=0.5;
 camlight headlight; lighting gouraud; colorbar;
title('Streamlines on torus surface');
abc=5877;
def=6001;


for k=10:10
    
    plot3(curves(k).xyz(abc:def,1), curves(k).xyz(abc:def,2), curves(k).xyz(abc:def,3), 'r', 'LineWidth',1.5);
end

%%


a = [curves(k).xyz(abc,1), curves(k).xyz(abc,2)];
b = [curves(k).xyz(def,1), curves(k).xyz(def,2)];

theta = acos( dot(a,b) / (norm(a)*norm(b)) );  % 结果为弧度
theta_deg = rad2deg(theta);                   % 转为角度
2*pi/theta

%%

P = curves(k).xyz(abc:def,:);                 % 这条流线的三维坐标

C = repeat_rotate_link_chain(P, 'Nrep', 15);


% % 或者：旋转中心不是(0,0)，比如中心在 (xc,yc)
% C = repeat_rotate_link_chain(P, 'Nrep', 8, 'Center', [xc, yc]);

% 可视化
figure('Color','w'); hold on; axis equal;
plot3(P(:,1),P(:,2),P(:,3),'k-','LineWidth',5);  % 原始曲线
plot3(C.xyz(:,1),C.xyz(:,2),C.xyz(:,3),'r-','LineWidth',1.6);
grid on;
s1=surf(X,Y,Z, sqrt(Ex.^2+Ey.^2+Ez.^2), 'EdgeColor','none'); hold on;
s1.FaceAlpha=0.5;
%%

% 原网格点 “打平”成散点
x0 = X(:);    y0 = Y(:);    z0 = Z(:);
ex0 = Ex(:);  ey0 = Ey(:);  ez0 = Ez(:);

% 使用三维散点插值器
FEx = scatteredInterpolant(x0, y0, z0, ex0, 'linear', 'nearest');
FEy = scatteredInterpolant(x0, y0, z0, ey0, 'linear', 'nearest');
FEz = scatteredInterpolant(x0, y0, z0, ez0, 'linear', 'nearest');

% 对C.xyz进行插值恢复矢量场
Cx = C.xyz(:,1);
Cy = C.xyz(:,2);
Cz = C.xyz(:,3);

Ex_c = FEx(Cx, Cy, Cz);
Ey_c = FEy(Cx, Cy, Cz);
Ez_c = FEz(Cx, Cy, Cz);

E_curve = [Ex_c Ey_c Ez_c];

figure; hold on; axis equal;
plot3(Cx,Cy,Cz,'r-','LineWidth',2);
quiver3(Cx,Cy,Cz, Ex_c,Ey_c,Ez_c, 0.8, 'c');
title('Field along reconstructed torus streamline');
grid on;
surf(X,Y,Z, 'EdgeColor','none'); camlight headlight; lighting gouraud;

save('E:\工作\硕士阶段文章\文章\螺旋喇叭\数据整理\fig1\未处理涡环-电场下半2.mat','Cx','Cy','Cz','Ex_c','Ey_c','Ez_c','X','Y','Z')

%%


%%
function curves = trace_stream_on_surface(X,Y,Z,Ex,Ey,Ez, seeds, opts)
% 在参数化曲面 r(s,phi) 上追踪流线。曲面与场都给为 Ns×Nphi 栅格。
% 输入：
%   X,Y,Z   : [Ns×Nphi] 曲面坐标网格（你的甜甜圈）
%   Ex,Ey,Ez: [Ns×Nphi] 同尺寸的笛卡尔场分量
%   seeds   : K×2 的种子点数组，每行 = [s_idx, phi_idx]（可为小数，表示在网格之间）
%   opts    : 可选配置（见默认）
%
% 输出：
%   curves(k).sphi : [N×2]  追踪到的参数轨迹（s_idx, phi_idx）
%   curves(k).xyz  : [N×3]  对应的三维坐标
%   curves(k).len  : 标称长度（参数步积累）
%
% 说明：
% - 我们在参数域 (s,phi) 中积分，但方向来自将 E 投影到切平面的最小二乘分解。
% - phi 会自动 wrap 到 [1, Nphi] 周期（等价 0..2π）。
% - 若你的 s 是等弧长重采样（推荐），追踪更稳定。

if nargin<8, opts = struct; end
P.h            = getfield_def(opts,'h', 0.05);      % 参数域步长（越小越精细）
P.max_steps    = getfield_def(opts,'max_steps', 4000);
P.min_speed    = getfield_def(opts,'min_speed', 1e-12);
P.close_tol    = getfield_def(opts,'close_tol', 3); % 端点回到起点的参数距离阈值
P.allow_reverse= getfield_def(opts,'allow_reverse', true); % 同时追正/反两个方向
P.clip_margin  = getfield_def(opts,'clip_margin', 1); % s 索引边缘保留的安全格
P.ds_scale     = getfield_def(opts,'ds_scale', 1.0); % 可微调 s/phi 的相对步幅
P.dphi_scale   = getfield_def(opts,'dphi_scale', 1.0);

[Ns,Nphi] = size(X);

% 构造插值器（参数域为索引坐标：s∈[1,Ns], phi∈[1,Nphi]）
FX = griddedInterpolant({1:Ns, 1:Nphi}, X,  'linear','nearest');
FY = griddedInterpolant({1:Ns, 1:Nphi}, Y,  'linear','nearest');
FZ = griddedInterpolant({1:Ns, 1:Nphi}, Z,  'linear','nearest');
FEx= griddedInterpolant({1:Ns, 1:Nphi}, Ex, 'linear','nearest');
FEy= griddedInterpolant({1:Ns, 1:Nphi}, Ey, 'linear','nearest');
FEz= griddedInterpolant({1:Ns, 1:Nphi}, Ez, 'linear','nearest');

% 基向量（在格点上先算好）
[Es, Ephi] = surface_basis(X,Y,Z);  % 每个格点的 e_s = ∂r/∂s, e_phi = ∂r/∂phi
Esx = griddedInterpolant({1:Ns,1:Nphi}, Es(:,:,1), 'linear','nearest');
Esy = griddedInterpolant({1:Ns,1:Nphi}, Es(:,:,2), 'linear','nearest');
Esz = griddedInterpolant({1:Ns,1:Nphi}, Es(:,:,3), 'linear','nearest');
Epx = griddedInterpolant({1:Ns,1:Nphi}, Ephi(:,:,1), 'linear','nearest');
Epy = griddedInterpolant({1:Ns,1:Nphi}, Ephi(:,:,2), 'linear','nearest');
Epz = griddedInterpolant({1:Ns,1:Nphi}, Ephi(:,:,3), 'linear','nearest');

curves = struct('sphi',{},'xyz',{},'len',{});

for k = 1:size(seeds,1)
    s0 = seeds(k,1); p0 = seeds(k,2);

    if P.allow_reverse
        path1 = integrate_dir([s0,p0], +1);
        path2 = integrate_dir([s0,p0], -1);
        sphi  = [flipud(path2(1:end-1,:)); path1];
    else
        sphi  = integrate_dir([s0,p0], +1);
    end

    % 生成 xyz 与长度
    xyz = [ FX(sphi(:,1), sphi(:,2)), ...
            FY(sphi(:,1), sphi(:,2)), ...
            FZ(sphi(:,1), sphi(:,2)) ];
    Lpar = sum(hypot(diff(sphi(:,1)), diff(sphi(:,2)))); % 参数域长度（可作为指标）

    curves(k).sphi = sphi;
    curves(k).xyz  = xyz;
    curves(k).len  = Lpar;
end

% ===== 内嵌：单向积分（RK4） =====
    function path = integrate_dir(sp, sgn)
        path = sp;
        for it = 1:P.max_steps
            spn = rk4(@(q) param_velocity(q, sgn), path(end,:), P.h);
            % s 边界裁剪，phi 周期
            spn(1) = max(1+P.clip_margin, min(Ns-P.clip_margin, spn(1)));
            % 周期 wrap: 把 phi 限制在 [1,Nphi]
            spn(2) = wrap_phi(spn(2), Nphi);

            path = [path; spn]; %#ok<AGROW>

            % 闭合判据：回到起点附近且步数足够
            if size(path,1) > 40
                d0 = hypot(path(end,1)-sp(1), wrap_diff(path(end,2), sp(2), Nphi));
                if d0 <= P.close_tol
                    break;
                end
            end
        end
    end

% ===== 内嵌：由 E 与切基求参数域速度 =====
    function v = param_velocity(q, sgn)
        si = q(1); ph = q(2);
        % 取场与基向量
        e_s  = [Esx(si,ph), Esy(si,ph), Esz(si,ph)];
        e_ph = [Epx(si,ph), Epy(si,ph), Epz(si,ph)];
        E3   = [FEx(si,ph), FEy(si,ph), FEz(si,ph)];

        % 单位法向
        n = cross(e_s, e_ph);
        nn = norm(n); if nn>0, n = n/nn; end

        % 投影到切平面
        E_tan = E3 - dot(E3,n)*n;
        spd   = norm(E_tan);
        if spd < P.min_speed
            v = [0,0]; return;
        end
        dir3 = (E_tan / spd) * sgn;

        % 用最小二乘求参数速度 v_s, v_phi 使 v_s*e_s + v_phi*e_ph ≈ dir3
        M = [e_s(:), e_ph(:)];           % 3×2
        v2 = (M.'*M) \ (M.'*dir3(:));    % 2×1
        v = [P.ds_scale*v2(1), P.dphi_scale*v2(2)]; % 可调比例
    end
end

% ====== 工具函数 ======

function [Es, Ephi] = surface_basis(X,Y,Z)
% 计算离散基向量：Es = ∂r/∂s_idx, Ephi = ∂r/∂phi_idx  （索引方向的差分）
[Ns,Np] = size(X);
Es   = zeros(Ns,Np,3);
Ephi = zeros(Ns,Np,3);

% s 方向中心差分
dXs = centerdiff(X,1); dYs = centerdiff(Y,1); dZs = centerdiff(Z,1);
Es(:,:,1)=dXs; Es(:,:,2)=dYs; Es(:,:,3)=dZs;

% phi 方向中心差分
dXp = centerdiff(X,2); dYp = centerdiff(Y,2); dZp = centerdiff(Z,2);
Ephi(:,:,1)=dXp; Ephi(:,:,2)=dYp; Ephi(:,:,3)=dZp;
end

function D = centerdiff(A,dim)
% 周期差分（仅 phi 方向需要周期；s 方向用边界复制）
if dim==1
    D = zeros(size(A));
    D(2:end-1,:) = 0.5*(A(3:end,:)-A(1:end-2,:));
    D(1,:)       = A(2,:) - A(1,:);
    D(end,:)     = A(end,:) - A(end-1,:);
else
    % phi 方向视为周期
    D = 0.5*(circshift(A,[0 -1]) - circshift(A,[0 1]));
end
end

function x = wrap_phi(x, Nphi)
while x<1,    x = x+Nphi; end
while x>Nphi, x = x-Nphi; end
end

function d = wrap_diff(a,b,Nphi)
% 周期差
d = a-b;
d = mod(d + Nphi/2, Nphi) - Nphi/2;
end

function v = rk4(f, y0, h)
k1 = f(y0);
k2 = f(y0 + 0.5*h*k1);
k3 = f(y0 + 0.5*h*k2);
k4 = f(y0 + h*k3);
v  = y0 + (h/6)*(k1 + 2*k2 + 2*k3 + k4);
end

function val = getfield_def(S, name, def)
if isfield(S,name), val = S.(name); else, val = def; end
end
%%
function C = repeat_rotate_link_chain(P, varargin)
% REPEAT_ROTATE_LINK_CHAIN (enhanced, global nearest linking)
% 将开口3D曲线 P=[x y z] 围绕 z 轴旋转并复制多个周期，使各段在
% “旋转生成之后”，按“最近端点”顺序首尾相接，并尽量闭合整圈。
%
% 用法：
%   C = repeat_rotate_link_chain(P);
%   C = repeat_rotate_link_chain(P, 'Nrep', 6);
%   C = repeat_rotate_link_chain(P, 'Center', [cx cy]);
%   C = repeat_rotate_link_chain(P, 'AllowFlip', true, 'BridgeMode','linear','BridgeN',5);
%
% 关键点：
% - 先生成所有旋转后的段 parts{k}
% - 从第1段开始，每次在“尚未使用的段”中找与当前末端点最近的端点，
%   若终点更近且允许翻转，则对那一整段 flipud 再拼接
% - 若两段首尾仍有小缝隙，可插入线性桥段
%
% 输出 C 结构体：
%   C.xyz      : [M×3] 拼接后的多周期闭合曲线（末点=首点，如需会加桥段）
%   C.parts    : {Nrep} 每个周期的一段 [Nk×3]（可能因 AllowFlip 而发生反向）
%   C.dphi     : 每周期旋转角（弧度）
%   C.Nrep     : 周期数
%   C.report   : 诊断信息（端点半径差、z差、连接误差、桥段统计等）
%
% 参数：
%   'Nrep'        ([])      指定周期数；缺省时从两端方位差估计并四舍五入
%   'Center'      ([0 0])   旋转中心（xy 平面投影）
%   'AllowFlip'   (true)    允许按“最近端”对下一段做整段反向以便更近拼接
%   'LinkNearest' (true)    是否考虑“尾端”也参与比较（配合 AllowFlip）
%   'BridgeMode'  ('linear') 'none' 或 'linear'（插入线性桥段）
%   'BridgeN'     (5)       桥段等分点数（含终点，不含起点），<=1 时仅直接接上终点
%   'Tol'         (1e-9)    判断“点是否重合”的距离公差
%
% 说明与限制：
% - P 需为开口曲线（N×3，N≥2），且首尾半径和 z 尽量接近会更容易闭合。
% - 本函数会在所有周期段生成后，再按“全局最近端点”顺序依次选段拼接。
% - 若最后一段与第一段之间仍有小缝隙，也会按相同规则桥接以实现闭合。

% ---------- 参数 ----------
p = inputParser;
p.addParameter('Nrep', []);
p.addParameter('Center', [0,0]);
p.addParameter('AllowFlip', true);
p.addParameter('LinkNearest', true);
p.addParameter('BridgeMode', 'linear'); % 'none' | 'linear'
p.addParameter('BridgeN', 5);
p.addParameter('Tol', 1e-9);
p.parse(varargin{:});

Nrep        = p.Results.Nrep;
center      = p.Results.Center(:).';
AllowFlip   = logical(p.Results.AllowFlip);
LinkNearest = logical(p.Results.LinkNearest);
BridgeMode  = validatestring(p.Results.BridgeMode, {'none','linear'});
BridgeN     = p.Results.BridgeN;
Tol         = p.Results.Tol;

P = P(:,:);
assert(size(P,2)==3 && size(P,1)>=2, 'P 必须是 N×3，N≥2');

% 去重：若首尾已相同，去掉末尾重复点
if all(abs(P(end,:)-P(1,:)) < Tol)
    P = P(1:end-1,:);
end

% 平移到旋转中心
Q = P;
Q(:,1) = Q(:,1) - center(1);
Q(:,2) = Q(:,2) - center(2);

% 端点信息（仅用于报告）
P0 = Q(1,:);    % 起点
P1 = Q(end,:);  % 终点
r0 = hypot(P0(1),P0(2));
r1 = hypot(P1(1),P1(2));
z0 = P0(3); z1 = P1(3);
phi0 = atan2(P0(2), P0(1));
phi1 = atan2(P1(2), P1(1));

% 角度估计：让 Rz(dphi)*终点 与 起点在方位上对齐
dphi_est = wrapTo2Pi(phi0 - phi1);

% 若未指定 Nrep，则从估计角度得到一个整数周期数
if isempty(Nrep)
    if dphi_est < 1e-6
        Nrep = 1;
    else
        Nrep = max(1, round(2*pi / dphi_est));
    end
end

% 为保证整圈闭合，固定 dphi = 2π/Nrep
dphi = 2*pi / Nrep;
R = Rz(dphi); %#ok<NASGU>

% 计算第一对的“连接误差”（报告用）
end_to_next_start = (Rz(dphi) * P1.').';
conn_err = norm(end_to_next_start - P0);

% 先生成各段（未做方向调整）
parts = cell(Nrep,1);
for k = 0:Nrep-1
    Rk = Rz(k*dphi);
    seg = (Rk * Q.').';
    % 移回中心
    seg(:,1) = seg(:,1) + center(1);
    seg(:,2) = seg(:,2) + center(2);
    parts{k+1} = seg;
end

% ===================== 修改点：全局最近端点拼接 =====================
XYZ = parts{1};                 % 起点：先用第1段
flip_flags = false(Nrep,1);     % 记录各段是否被翻转
bridge_lengths = zeros(Nrep,1); % 每段前面的桥长
used = false(Nrep,1);           % 记录是否已用该段
used(1) = true;

% 依次选择“尚未使用的段”中与当前末端点最近的一段
for step = 2:Nrep
    prev_end = XYZ(end,:);  % 当前组合曲线末端
    
    best_idx  = [];
    best_flip = false;
    best_dist = inf;
    
    % 在所有未使用的段中搜索
    for j = 1:Nrep
        if used(j), continue; end
        
        seg_j = parts{j};
        d_start = norm(prev_end - seg_j(1,:));
        d_end   = norm(prev_end - seg_j(end,:));
        
        % 决定该候选段是否翻转
        flip_candidate = false;
        d_candidate = d_start;
        if LinkNearest && AllowFlip && (d_end + Tol < d_start)
            d_candidate = d_end;
            flip_candidate = true;
        end
        
        % 更新当前最优
        if d_candidate < best_dist
            best_dist = d_candidate;
            best_idx  = j;
            best_flip = flip_candidate;
        end
    end
    
    % 取出最佳候选段并按需要翻转
    seg = parts{best_idx};
    if best_flip
        seg = flipud(seg);
    end
    flip_flags(best_idx) = best_flip;
    used(best_idx) = true;
    
    % 与当前末端点连接（可能插桥）
    d_start = norm(prev_end - seg(1,:));
    
    if d_start <= Tol
        % 起点几乎重合：去掉重复点直接接上
        seg = seg(2:end,:);
        XYZ = [XYZ; seg]; %#ok<AGROW>
    else
        switch BridgeMode
            case 'none'
                % 不插桥，只避免重复点
                if all(abs(prev_end - seg(1,:)) < Tol)
                    seg = seg(2:end,:);
                end
                XYZ = [XYZ; seg]; %#ok<AGROW>
            case 'linear'
                % 在线性桥段 prev_end -> seg(1,:) 之间插值
                if BridgeN <= 1
                    bridge = seg(1,:); % 只插入目标点
                else
                    t = linspace(0,1,BridgeN+1); % 含0和1
                    bridge = prev_end + (seg(1,:)-prev_end).*t(2:end).';
                end
                bridge_lengths(best_idx) = norm(seg(1,:)-prev_end);
                
                % 去重：若第一桥点仍与 prev_end 重合，剔除
                if ~isempty(bridge) && all(abs(bridge(1,:) - prev_end) < Tol)
                    bridge = bridge(2:end,:);
                end
                XYZ = [XYZ; bridge; seg]; %#ok<AGROW>
        end
    end
end
% =================== 全局最近端点拼接结束 ===================

% 闭合：最后一段末点 -> 第一段起点
first_start = XYZ(1,:);
last_end    = XYZ(end,:);

if norm(last_end - first_start) > Tol
    switch BridgeMode
        case 'none'
            % 直接补上首点闭合
            XYZ(end+1,:) = first_start;
        case 'linear'
            if BridgeN <= 1
                bridge = first_start; % 直接补首点
            else
                t = linspace(0,1,BridgeN+1);
                bridge = last_end + (first_start-last_end).*t(2:end).';
            end
            % 去重
            if ~isempty(bridge) && all(abs(bridge(1,:) - last_end) < Tol)
                bridge = bridge(2:end,:);
            end
            XYZ = [XYZ; bridge]; %#ok<AGROW>
    end
elseif norm(last_end - first_start) <= Tol && ~all(abs(XYZ(end,:) - first_start) < Tol)
    % 已几乎重合但未显式闭合，则补一个首点以显式闭环
    XYZ(end+1,:) = first_start;
end

% 输出报告
report = struct();
report.r0 = r0; report.r1 = r1; report.dr = r1 - r0;
report.z0 = z0; report.z1 = z1; report.dz = z1 - z0;
report.dphi_est = dphi_est; report.dphi_used = dphi;
report.conn_err_firstpair = conn_err;
report.AllowFlip = AllowFlip;
report.LinkNearest = LinkNearest;
report.flip_flags = flip_flags;
report.bridge_mode = BridgeMode;
report.bridge_N = BridgeN;
report.bridge_lengths = bridge_lengths;
report.bridge_total = sum(bridge_lengths);

% 输出
C = struct();
C.xyz    = XYZ;
C.parts  = parts;
C.dphi   = dphi;
C.Nrep   = Nrep;
C.report = report;

% ------- 内部函数 -------
function R = Rz(th)
R = [cos(th) -sin(th) 0;
     sin(th)  cos(th) 0;
        0        0    1];
end

end

% ------- wrapTo2Pi -------
function a = wrapTo2Pi(a)
a = mod(a, 2*pi);
end
