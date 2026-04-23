clear; clc; close all;

figure; hold on; axis equal;
set(gca,'FontSize',12);
xlabel('x'); ylabel('y');
title('Decomposition of radial polarization on logarithmic spiral grating');

% Spiral parameters
a = 0.2;
b = 0.40;
theta = linspace(2.5*pi,4*pi,500);
r = a.*exp(b.*theta);

% Coaxial inner & outer radii taken from spiral start/end
r_in  = r(1);        % radius at spiral start
r_out = r(end);      % radius at spiral end

% Logarithmic spiral in base (unrotated) coordinates
x_base = r.*cos(theta);
y_base = r.*sin(theta);

% Rotation angle for the spiral: 45 degrees
ang = 45*pi/180;
R = [cos(ang) -sin(ang); sin(ang) cos(ang)];

% Rotate spiral
xy_rot = R * [x_base; y_base];
x = xy_rot(1,:);
y = xy_rot(2,:);

% --- Plot logarithmic spiral (rotated) ---
plot(x,y,'LineWidth',1.8,'Color',[0 0.28 0.67]);
% text(x(end)-0.3, y(end)-0.1, 'Logarithmic spiral', ...
%     'FontSize',12,'Interpreter','latex');

% --- Coaxial inner & outer conductors as circles (not affected by rotation) ---
phi = linspace(0, 2*pi, 400);
x_in  = r_in  * cos(phi);
y_in  = r_in  * sin(phi);
x_out = r_out * cos(phi);
y_out = r_out * sin(phi);

plot(x_in,  y_in,  'k','LineWidth',3,  'Color',[0.2 0.2 0.2]);
plot(x_out, y_out, 'k','LineWidth',3, 'Color',[0.2 0.2 0.2]);

% text(r_in+0.05, 0, 'Inner conductor',  'Interpreter','latex','FontSize',10);
% text(r_out+0.05,0, 'Outer conductor',  'Interpreter','latex','FontSize',10);

% Feed at center
plot(0,0,'ko','MarkerFaceColor','k','LineWidth',3);
% text(0.05,0.05,'Feed','FontSize',12,'Interpreter','latex');

% --- Radial Er arrows from inner circle to outer circle (grey) ---
theta_er = (0:60:300)*pi/180;   % directions for arrows
for k = 1:length(theta_er)
    dir = [cos(theta_er(k)), sin(theta_er(k))];   % unit radial direction
    start_pt = r_in  * dir;                       % on inner circle
    end_pt   = r_out * dir;                       % on outer circle
    vec      = end_pt - start_pt;                 % arrow vector
    quiver(start_pt(1), start_pt(2), vec(1), vec(2), ...
        'AutoScale','off','MaxHeadSize',0.5, 'Color',[0.6 0.6 0.6]);
end

% Label one Er arrow
r_mid_for_label = 0.5*(r_in + r_out);
% text(r_mid_for_label, 0.1*r_mid_for_label, '$\mathbf{E}_r$', ...
%     'Interpreter','latex','FontSize',13,'Color',[0.4 0.4 0.4]);

% =========================================================
% Choose study point P: radius at the middle between inner and outer circles
% P lies on the spiral with radius r_mid
% =========================================================
r_mid = 0.5*(r_in + r_out);           % mid radius between inner and outer
theta0_base = (1/b)*log(r_mid/a);     % solve r = a*exp(b*theta) for theta
r0 = r_mid;                           % radius of study point

% Base (unrotated) point on spiral
P0 = [r0*cos(theta0_base); r0*sin(theta0_base)];

% Tangent & normal in base coordinates
dr_dtheta0 = a*b*exp(b*theta0_base);  % dr/dtheta = b*r
dx_dtheta0 = dr_dtheta0*cos(theta0_base) - r0*sin(theta0_base);
dy_dtheta0 = dr_dtheta0*sin(theta0_base) + r0*cos(theta0_base);

t0 = [dx_dtheta0; dy_dtheta0];
t_hat0 = t0 / norm(t0);
n_hat0 = [-t_hat0(2); t_hat0(1)];

% Local radial direction in base coordinates
e_r_hat0 = P0 / norm(P0);

% Local Er vector at P in base coordinates
Er_len = 0.6*r0;
E_r0 = Er_len * e_r_hat0;

% Decomposition in base coordinates
E_parallel0 = (dot(E_r0, t_hat0)) * t_hat0;
E_perp0     = (dot(E_r0, n_hat0)) * n_hat0;

% =========================================================
% Rotate all local vectors and point by 45 degrees
% =========================================================
P          = R * P0;
t_hat      = R * t_hat0;
n_hat      = R * n_hat0;
E_r        = R * E_r0;
E_parallel = R * E_parallel0;
E_perp     = R * E_perp0;

% --- Plot study point P ---
plot(P(1),P(2),'ro','MarkerFaceColor','r','LineWidth',3);
% text(P(1)+0.05, P(2)+0.05,'P', ...
%     'FontSize',13,'Color','r','Interpreter','latex');

% --- Tangent and normal at P (rotated) ---
L_basis = 0.4*r0;
% --- Tangent direction  t-hat  (Bright Green) ---
quiver(P(1), P(2), L_basis*t_hat(1), L_basis*t_hat(2), ...
    'AutoScale','off','LineWidth',2.8,'MaxHeadSize',1.4, ...
    'Color',[0 0.8 0.2]);   % Bright green


% --- Normal direction  n-hat  (Bright Blue) ---
quiver(P(1), P(2), L_basis*n_hat(1), L_basis*n_hat(2), ...
    'AutoScale','off','LineWidth',2.8,'MaxHeadSize',1.4, ...
    'Color',[0.1 0.4 1]);   % Bright blue


% --- Local radial Er  (Strong Orange) ---
quiver(P(1), P(2), E_r(1), E_r(2), ...
    'AutoScale','off','LineWidth',3.0,'MaxHeadSize',1.4, ...
    'Color',[1 0.5 0]);   % Orange


% --- Parallel component E_parallel  (Purple) ---
quiver(P(1), P(2), E_parallel(1), E_parallel(2), ...
    'AutoScale','off','LineWidth',3.0,'MaxHeadSize',1.4, ...
    'Color',[0.6 0.2 0.8]);   % Purple


% --- Normal component E_perp  (Strong Red) ---
quiver(P(1), P(2), E_perp(1), E_perp(2), ...
    'AutoScale','off','LineWidth',3.0,'MaxHeadSize',1.4, ...
    'Color',[1 0.1 0.1]);   % Red

% --- Dashed projection lines from E_r tip to components ---
Er_tip = P + E_r;
Foot_t = P + E_parallel;
Foot_n = P + E_perp;

plot([Er_tip(1), Foot_t(1)], [Er_tip(2), Foot_t(2)], ...
    '--', 'Color',[0.6 0.2 0.8], 'LineWidth',1);
plot([Er_tip(1), Foot_n(1)], [Er_tip(2), Foot_n(2)], ...
    '--', 'Color',[0.85 0.33 0.10], 'LineWidth',1);

% --- Limits and grid ---
xlim([min(x_out)-0.6, max(x_out)+0.6]);
ylim([min(y_out)-0.6, max(y_out)+0.6]);
grid off;
axis off
plot([0, P(1)], [0, P(2)], '--', ...
    'Color',[0.3 0.3 0.3], 'LineWidth',1.5);   % grey dashed line