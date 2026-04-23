


function demo_axis_arrows

% 参数
L  = 1.5;        % 箭头整体长度
Lc = 0.85*L;   % 圆柱部分长度
R  = 0.02;     % 圆柱半径
Rh = 0.05;     % 锥体底面半径
Lh = L - Lc;   % 锥体长度

% 画三根箭头：x,y,z
drawArrow3D([0 0 0], [L 0 0], R, Rh, Lh, 'k');
drawArrow3D([0 0 0], [0 L 0], R, Rh, Lh, 'k');
drawArrow3D([0 0 0], [0 0 L], R, Rh, Lh, 'k');

end


% ===========================================================
% 3D Arrow (Cylinder + Cone)
% ===========================================================
function drawArrow3D(p0, p1, rcyl, rhead, Lhead, color)

% 方向向量
v  = p1 - p0;
Lv = norm(v);
uhat = v / Lv;

% 圆柱长度
Lcyl = Lv - Lhead;

% 生成圆柱（沿 z 轴）
[Xc,Yc,Zc] = cylinder(rcyl, 40);
Zc = Zc * Lcyl;

% 生成锥体（沿 z 轴）
[ Xh, Yh, Zh ] = cylinder([rhead 0], 40);
Zh = Zh * Lhead;
Zh = Zh + Lcyl;     % 移到圆柱末端

% 合并
X = [Xc; Xh];
Y = [Yc; Yh];
Z = [Zc; Zh];

% 构造旋转到方向 v 的矩阵
R = localRotationMatrix(uhat);

% 旋转并平移
pts = R * [X(:)'; Y(:)'; Z(:)'];
Xr = reshape(pts(1,:), size(X)) + p0(1);
Yr = reshape(pts(2,:), size(Y)) + p0(2);
Zr = reshape(pts(3,:), size(Z)) + p0(3);

% 绘制
surf(Xr, Yr, Zr, 'FaceColor', color, 'EdgeColor', 'none');
end


% ===========================================================
% 方向向量构造旋转矩阵
% ===========================================================
function R = localRotationMatrix(dir)
% 将 z 轴方向旋转到 dir
dir = dir(:)/norm(dir);

z = [0 0 1]';
if norm(cross(z,dir)) < 1e-9
    if dot(z,dir) > 0
        R = eye(3);     % 平行且同方向
    else
        R = diag([1 -1 -1]);  % 反向
    end
    return;
end

v = cross(z,dir);
s = norm(v);
c = dot(z,dir);

vx = [   0   -v(3)  v(2)
       v(3)   0    -v(1)
      -v(2)  v(1)   0  ];

R = eye(3) + vx + vx*vx*((1-c)/(s^2));
end
