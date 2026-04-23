%% 演示：原环面 & 映射后的规则环面 + 矢量场可视化

clear; clc; close all;
%%

draw(30,0.09,0.9,0.10,12,0,20,25,5,5,10000)

draw(45,0.09,0.9,0.10,12,0,20,25,5,5,10000)

draw(60,0.09,0.9,0.11,15 ...
    ,0,20,25,3,3,10000)

%%


function draw(iiiii,Length1,Scale1,Length2,Scale2,phi_target,ccc,bbb,aaaa1,aaaa2,N_new)

addpath 'E:\工作\硕士阶段文章\文章\螺旋喇叭\内容提交\上传\fig3\手性涡旋环'
name=['E:\工作\硕士阶段文章\文章\螺旋喇叭\内容提交\上传\fig3\手性涡旋环\',num2str(iiiii)];

load([name,'\未处理涡环.mat'])



[Cx_u, Cy_u, Cz_u, Ex_u, Ey_u, Ez_u] = ...
    resample_vectors_uniform_on_line(Cx, Cy, Cz, Ex_c, Ey_c, Ez_c, N_new);

R1=2;
a1=0.5;
align_feature = 'minZ';


[X_reg, Y_reg, Z_reg, ...
 Cx_reg, Cy_reg, Cz_reg, ...
 Ex_p, Ey_p, Ez_p] = map_irreg_axisym_torus_to_regular_arc( ...
                        X, Y, Z, ...
                        Cx, Cy, Cz, ...
                        Ex_c, Ey_c, Ez_c, ...
                        R1, a1, ...
                        align_feature, phi_target);
[Cx_f, Cy_f, Cz_f, Ex_f, Ey_f, Ez_f] = ...
    resample_vectors_uniform_on_line(Cx_reg, Cy_reg, Cz_reg, ...
          Ex_p, Ey_p, Ez_p, N_new);

%========================
% 5. 画图：原环面 + 映射后环面
%========================

figure
s1=surf(X_reg, Y_reg, Z_reg, ...
    'EdgeColor', 'none');
s1.FaceColor=[128/256, 128/256, 128/256];
s1.FaceAlpha=0.5;
hold on;

arrow3_hsvcolor_batch_uniform(Cx_f(1:aaaa1:end), Cy_f(1:aaaa1:end), Cz_f(1:aaaa1:end), Ex_f(1:aaaa1:end), Ey_f(1:aaaa1:end), Ez_f(1:aaaa1:end), ...
    'Length',Length1, ...
    'HeadFrac',0.50, ...          % 圆锥更长
    'HeadRadiusFactor',2.5, ...   % 圆锥更粗
    'Facets',32, ...
    'EdgeColor','none', ...
    'CapEpsilon',1e-6, ...
    'Radius', 0.01 ...
    , 'Scale', Scale1);           % 盖子轻微抬起，避免闪烁
axis tight; grid on; view(42,26);
xlabel x; ylabel y; zlabel z;
title('统一尺度箭头（带端盖）：长锥短杆、方向着色');
axis equal; camlight; lighting gouraud; hold on
set(gca,'Visible','off')
set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);

exportgraphics(gcf, [name,'\output2.png'], 'Resolution', 600);



figure
s1=surf(X,Y,-3*Z,'EdgeColor','none');
s1.FaceColor=[128/256, 128/256, 128/256];
s1.FaceAlpha=0.5;
axis equal; camlight; lighting gouraud; hold on


arrow3_hsvcolor_batch_uniform(Cx_u(1:aaaa2:end), Cy_u(1:aaaa2:end), -3*Cz_u(1:aaaa2:end), Ex_u(1:aaaa2:end), Ey_u(1:aaaa2:end), -3*Ez_u(1:aaaa2:end), ...
    'Length',Length2, ...
    'HeadFrac',0.50, ...          % 圆锥更长
    'HeadRadiusFactor',2.5, ...   % 圆锥更粗
    'Facets',32, ...
    'EdgeColor','none', ...
    'CapEpsilon',1e-6, ...
    'Radius', 0.01 ...
    , 'Scale',Scale2);           % 盖子轻微抬起，避免闪烁
axis tight; grid on; view(42,26);
xlabel x; ylabel y; zlabel z;
title('统一尺度箭头（带端盖）：长锥短杆、方向着色');


if(iiiii==15)
zticks([-194 -184]);

elseif (iiiii==30)
zticks([-194 -182]);

elseif (iiiii==45)
zticks([-202 -186]);

elseif (iiiii==60)
zticks([-210 -185]);

elseif (iiiii==75)
zticks([-200 -185]);

end


xlim([-bbb bbb]);
ylim([-bbb bbb]);

% 设置 x、y 刻度
xticks([-ccc 0 ccc]);
yticks([-ccc 0 ccc]);

% 隐藏 z 轴
% set(gca, 'ZTick', []);     % 不显示刻度
% set(gca, 'ZColor', 'none'); % 不显示轴线和标签
axis equal; camlight; lighting gouraud; hold on
set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);

exportgraphics(gcf, [name,'\output.png'], 'Resolution', 600);


end
%%

function [X_reg, Y_reg, Z_reg, ...
          Cx_reg, Cy_reg, Cz_reg, ...
          Ex_p, Ey_p, Ez_p] = ...
    map_irreg_axisym_torus_to_regular_arc( ...
        X, Y, Z, ...              % 不规则轴对称甜甜圈曲面，大小 [Nu x Nv]
        Cx, Cy, Cz, ...           % 矢量位置，1D 向量 (Nvec x 1)
        Ex_c, Ey_c, Ez_c, ...     % 矢量分量，1D 向量 (Nvec x 1)
        R1, a1, ...               % 目标规则甜甜圈参数：大半径 R1，小半径 a1
        align_feature, ...        % 对齐特征: 'minZ','maxZ','minR','maxR','none'
        phi_target)               % 目标截面角度(弧度)，例如 0, pi/2, pi 等
%MAP_IRREG_AXISYM_TORUS_TO_REGULAR_ARC
% 将一个“不规则轴对称环面”上的切向矢量映射到规则甜甜圈 (R1,a1)，
% 映射过程中：
%   - 截面用“弧长 s”做参数，s∈[0,L)；
%   - 规则圆截面角 φ = 2π * (s/L) + phi0；
%   - 保证矢量在新甜甜圈上仍然严格切向。
%
% 输入：
%   X,Y,Z       : 2D 网格，[Nu x Nv]，表示不规则环面
%   Cx,Cy,Cz    : 矢量位置，1D 列向量 (Nvec x 1)
%   Ex_c,Ey_c,Ez_c : 矢量分量，1D 列向量
%   R1,a1       : 目标规则甜甜圈的大半径、小半径
%   align_feature: 用哪个截面特征做对齐：
%                  'minZ' : 原截面上 z 最小的点
%                  'maxZ' : 原截面上 z 最大的点
%                  'minR' : 原截面上 r 最小的点
%                  'maxR' : 原截面上 r 最大的点
%                  'none' : 不对齐特征，只用 phi_target 做整体旋转
%   phi_target : 该特征在规则圆截面上的目标角度（弧度）
%
% 输出：
%   X_reg,Y_reg,Z_reg   : 规则甜甜圈的网格，[Nu x Nv]
%   Cx_reg,Cy_reg,Cz_reg: 映射后矢量的位置 (Nvec x 1)
%   Ex_p,Ey_p,Ez_p      : 映射后矢量，在新甜甜圈上严格切向

    %% --- 0. 参数检查 ---
    if nargin < 11
        error('至少需要前 11 个参数：X,Y,Z,Cx,Cy,Cz,Ex_c,Ey_c,Ez_c,R1,a1。');
    end
    if nargin < 12 || isempty(align_feature)
        align_feature = 'none';
    end
    if nargin < 13 || isempty(phi_target)
        phi_target = 0;    % 默认对齐到 φ=0（截面外侧）
    end
    align_feature = lower(char(align_feature));

    % 整理输入
    [Nu, Nv] = size(X);

    Cx   = Cx(:);   Cy   = Cy(:);   Cz   = Cz(:);
    Ex_c = Ex_c(:); Ey_c = Ey_c(:); Ez_c = Ez_c(:);
    Nvec = numel(Cx);

    if any([numel(Cy), numel(Cz), numel(Ex_c), numel(Ey_c), numel(Ez_c)] ~= Nvec)
        error('Cx,Cy,Cz,Ex_c,Ey_c,Ez_c 的长度必须一致。');
    end

    eps_small = 1e-12;

    %% --- 1. 从曲面网格提取截面离散点 (r_nodes, z_nodes) ---
    % 假设 i 方向为截面方向
    r_nodes = zeros(Nu,1);
    z_nodes = zeros(Nu,1);
    for i = 1:Nu
        Xi = X(i,:); Yi = Y(i,:); Zi = Z(i,:);
        ri = sqrt(Xi.^2 + Yi.^2);
        r_nodes(i) = mean(ri);
        z_nodes(i) = mean(Zi);
    end

    %% --- 2. 构造截面折线段 + 弧长参数 s_i ---
    % 段 i: Q0(i)=(r_nodes(i),z_nodes(i)) → Q1(i)=(r_nodes(i1),z_nodes(i1))
    r0 = r_nodes;
    z0 = z_nodes;
    r1 = r_nodes([2:Nu, 1]);   % 周期闭合
    z1 = z_nodes([2:Nu, 1]);

    vr = r1 - r0;
    vz = z1 - z0;

    len_seg = sqrt(vr.^2 + vz.^2);     % 每一段的长度
    len2_seg = len_seg.^2;

    % 整个截面总弧长
    L = sum(len_seg);
    if L < eps_small
        error('截面总弧长过小，无法进行弧长映射。');
    end

    % 节点弧长：s_nodes(i) 是第 i 个节点的弧长坐标
    % 约定：节点 1 的 s=0，节点 i 的 s = sum_{k=1}^{i-1} len_seg(k)
    s_nodes = zeros(Nu,1);
    for i = 2:Nu
        s_nodes(i) = s_nodes(i-1) + len_seg(i-1);
    end
    % s_nodes(end) = L - len_seg(Nu)

    %% --- 3. 用 align_feature 确定对齐的弧长参数 s_ref，计算旋转 phi0 ---
    switch align_feature
        case 'minz'
            [~, i_ref] = min(z_nodes);
        case 'maxz'
            [~, i_ref] = max(z_nodes);
        case 'minr'
            [~, i_ref] = min(r_nodes);
        case 'maxr'
            [~, i_ref] = max(r_nodes);
        case 'none'
            i_ref = [];
        otherwise
            warning('未知 align_feature=%s，按 ''none'' 处理。', align_feature);
            i_ref = [];
    end

    if isempty(i_ref)
        % 不使用特征点对齐，直接整体旋转 phi_target
        phi0 = phi_target;
    else
        s_ref  = s_nodes(i_ref);            % 该特征点的弧长坐标
        phi_ref = 2*pi * (s_ref / L);       % 线性弧长映射下对应的 φ
        phi0    = phi_target - phi_ref;     % 需要的整体旋转量
    end

    %% --- 4. 构造规则甜甜圈的网格 (X_reg, Y_reg, Z_reg) ---
    % 每一行 i 对应截面弧长 s_nodes(i)，角度 φ_i = 2π s_i/L + phi0
    phi_nodes = 2*pi * (s_nodes / L) + phi0;
    % 保持周期特性，phi_nodes 超出 [0,2π) 问题不大，可按需要 mod 一下
    % phi_nodes = mod(phi_nodes, 2*pi);

    % 环向角 θ_j
    theta = linspace(0, 2*pi, Nv+1); theta(end) = [];
    [Phi_grid, Theta_grid] = ndgrid(phi_nodes, theta);

    r_reg_grid = R1 + a1 .* cos(Phi_grid);
    X_reg = r_reg_grid .* cos(Theta_grid);
    Y_reg = r_reg_grid .* sin(Theta_grid);
    Z_reg = a1 .* sin(Phi_grid);

    %% --- 5. 初始化输出矢量 ---
    Cx_reg = zeros(Nvec,1);
    Cy_reg = zeros(Nvec,1);
    Cz_reg = zeros(Nvec,1);

    Ex_p = zeros(Nvec,1);
    Ey_p = zeros(Nvec,1);
    Ez_p = zeros(Nvec,1);

    %% --- 6. 对每一个矢量，按“弧长参数 + 该点基底”做严格映射 ---
    for k = 1:Nvec
        % 6.1 当前矢量位置 & 分量
        Px = Cx(k);
        Py = Cy(k);
        Pz = Cz(k);
        E  = [Ex_c(k); Ey_c(k); Ez_c(k)];

        % 柱坐标 (rP, zP, thetaP)
        rP = sqrt(Px^2 + Py^2);
        zP = Pz;
        thetaP = atan2(Py, Px);
        sinT = sin(thetaP);
        cosT = cos(thetaP);

        % 6.2 在截面折线上找最近点：段 i0 + 参数 t ∈ [0,1]
        bestDist2 = inf;
        best_i = 1;
        best_t = 0;

        for i = 1:Nu
            if len_seg(i) < eps_small
                continue;   % 跳过零长度段
            end
            r0i = r0(i); z0i = z0(i);
            vri = vr(i); vzi = vz(i);

            wr = rP - r0i;
            wz = zP - z0i;

            t = (wr*vri + wz*vzi) / len2_seg(i);
            if t < 0, t = 0; elseif t > 1, t = 1; end

            r_proj = r0i + t*vri;
            z_proj = z0i + t*vzi;

            dr = rP - r_proj;
            dz = zP - z_proj;
            dist2 = dr*dr + dz*dz;

            if dist2 < bestDist2
                bestDist2 = dist2;
                best_i = i;
                best_t = t;
            end
        end

        % 6.3 在截面上的最近点几何 & 弧长参数 s
        i0 = best_i;
        t  = best_t;

        r0i = r0(i0); z0i = z0(i0);
        vri = vr(i0); vzi = vz(i0);
        Li  = len_seg(i0);

        r_cs = r0i + t*vri;      % r(s)
        z_cs = z0i + t*vzi;      % z(s)

        % s = 本段起点弧长 + t * 段长
        s = s_nodes(i0) + t * Li;

        % 截面切向方向：对弧长的导数 dr/ds, dz/ds
        if Li < eps_small
            dr_ds = 0;
            dz_ds = 0;
        else
            dr_ds = vri / Li;
            dz_ds = vzi / Li;
        end

        % 6.4 原曲面在 (s,thetaP) 的切向基：Tθ_old, Ts_old
        %   S_old(s,θ) = (r(s) cosθ, r(s) sinθ, z(s))
        %   Tθ_old = ∂S_old/∂θ = (-r sinθ, r cosθ, 0)
        %   Ts_old = ∂S_old/∂s = (dr/ds cosθ, dr/ds sinθ, dz/ds)
        Ttheta_old = [-r_cs * sinT;
                       r_cs * cosT;
                       0          ];
        Ts_old     = [dr_ds * cosT;
                      dr_ds * sinT;
                      dz_ds       ];

        % 6.5 在 {Tθ_old, Ts_old} 基下分解 E：E ≈ α Tθ_old + β Ts_old
        a = dot(Ttheta_old, Ttheta_old);
        b = dot(Ttheta_old, Ts_old);
        c = dot(Ts_old,     Ts_old);

        d = dot(Ttheta_old, E);
        e = dot(Ts_old,     E);

        detG = a*c - b*b;

        if abs(detG) < eps_small
            % 极端退化时，把 E 投影到切平面（保守处理）
            n_old = cross(Ttheta_old, Ts_old);
            n_norm = norm(n_old);
            if n_norm < eps_small
                alpha = 0;
                beta  = 0;
            else
                n_old = n_old / n_norm;
                E_tan = E - dot(E, n_old) * n_old;
                % 简化：这里不再重新求 α,β，直接用 0；你可以按需要改精细。
                E = E_tan;
                alpha = 0;
                beta  = 0;
            end
        else
            alpha = ( c*d - b*e) / detG;
            beta  = (-b*d + a*e) / detG;
        end

        % 6.6 规则甜甜圈上对应的截面角 φ(s)
        dphi_ds = 2*pi / L;
        phi = 2*pi * (s / L) + phi0;
        phi = mod(phi, 2*pi);

        r_new = R1 + a1 * cos(phi);
        z_new = a1 * sin(phi);

        % 新位置
        Cx_reg(k) = r_new * cosT;
        Cy_reg(k) = r_new * sinT;
        Cz_reg(k) = z_new;

        % 6.7 规则甜甜圈在 (s,θ) 的切向基：Tθ_new, Ts_new
        %   S_new(φ,θ) = ((R1+a1 cosφ) cosθ, (R1+a1 cosφ) sinθ, a1 sinφ)
        %   Tθ_new = ∂S_new/∂θ = (-r_new sinθ, r_new cosθ, 0)
        %   Ts_new = ∂S_new/∂s = (∂S_new/∂φ) * (dφ/ds)
        Ttheta_new = [-r_new * sinT;
                       r_new * cosT;
                       0            ];

        dS_dphi = [-a1 * sin(phi) * cosT;
                   -a1 * sin(phi) * sinT;
                    a1 * cos(phi)       ];
        Ts_new = dphi_ds * dS_dphi;

        % 6.8 用同样的 (α,β) 重建新矢量：E' = α Tθ_new + β Ts_new
        E_new = alpha * Ttheta_new + beta * Ts_new;

        Ex_p(k) = E_new(1);
        Ey_p(k) = E_new(2);
        Ez_p(k) = E_new(3);
    end
end


function [Cx_u, Cy_u, Cz_u, Ex_u, Ey_u, Ez_u] = ...
    resample_vectors_uniform_on_line( ...
        Cx, Cy, Cz, Ex_c, Ey_c, Ez_c, N_new)
%RESAMPLE_VECTORS_UNIFORM_ON_LINE
% 沿一条空间折线 (Cx,Cy,Cz) 重新采样，使得新点在这条线上的弧长
% 分布均匀，同时对矢量 (Ex_c,Ey_c,Ez_c) 做线性插值。
%
% 输入：
%   Cx,Cy,Cz      : 原始线上的点坐标 (N x 1 或 1 x N)，按线的顺序排列
%   Ex_c,Ey_c,Ez_c: 这些点上的矢量分量 (同长度 N)
%   N_new         : 重采样后的点数（包括首尾）
%
% 输出：
%   Cx_u,Cy_u,Cz_u: 等弧长重采样后的位置 (N_new x 1)
%   Ex_u,Ey_u,Ez_u: 等弧长重采样后对应的矢量 (N_new x 1)
%
% 说明：
%   1. 假设这条线是连通的折线，点按顺序给出；
%   2. 函数不会改变矢量方向，只是沿这条线做线性插值；
%   3. 如果存在重复点（零长度段），会自动去掉这些重复点。

    % -------- 0. 整理输入为列向量 --------
    Cx   = Cx(:);
    Cy   = Cy(:);
    Cz   = Cz(:);
    Ex_c = Ex_c(:);
    Ey_c = Ey_c(:);
    Ez_c = Ez_c(:);

    N = numel(Cx);
    if any([numel(Cy), numel(Cz), numel(Ex_c), numel(Ey_c), numel(Ez_c)] ~= N)
        error('Cx,Cy,Cz,Ex_c,Ey_c,Ez_c 的长度必须一致。');
    end
    if N < 2
        error('至少需要两个点才能进行沿线重采样。');
    end
    if N_new < 2
        error('N_new 至少为 2（包含首尾点）。');
    end

    % -------- 1. 计算原折线的累计弧长 s_i --------
    dX = diff(Cx);
    dY = diff(Cy);
    dZ = diff(Cz);
    ds = sqrt(dX.^2 + dY.^2 + dZ.^2);    % 每一段的长度

    % 去掉零长度段（重复点）以避免 interp1 重复自变量
    eps_len = 1e-12;
    keep = [true; ds > eps_len];   % 保留第一个点，以及长度非零的段末点

    Cx  = Cx(keep);
    Cy  = Cy(keep);
    Cz  = Cz(keep);
    Ex_c = Ex_c(keep);
    Ey_c = Ey_c(keep);
    Ez_c = Ez_c(keep);

    % 重新计算弧长
    dX = diff(Cx);
    dY = diff(Cy);
    dZ = diff(Cz);
    ds = sqrt(dX.^2 + dY.^2 + dZ.^2);

    s = [0; cumsum(ds)];   % 累计弧长 s(1)=0, s(end)=总长度
    L = s(end);

    if L < eps_len
        error('整条线的总长度太短，无法进行弧长重采样。');
    end

    % -------- 2. 定义新的等弧长参数 s_new --------
    s_new = linspace(0, L, N_new).';   % N_new x 1

    % -------- 3. 在弧长参数上对位置和矢量做线性插值 --------
    Cx_u = interp1(s, Cx,  s_new, 'linear');
    Cy_u = interp1(s, Cy,  s_new, 'linear');
    Cz_u = interp1(s, Cz,  s_new, 'linear');

    Ex_u = interp1(s, Ex_c, s_new, 'linear');
    Ey_u = interp1(s, Ey_c, s_new, 'linear');
    Ez_u = interp1(s, Ez_c, s_new, 'linear');

    % （可选）如果你想强制矢量模长不变，可以在这里按需要做归一化或缩放。
    % 例如保持原来的局部模长，可以再插值 |E|，然后把方向归一后乘回长度。
    % 但默认我们保持“线性插值”的结果，不做额外修改。
end
