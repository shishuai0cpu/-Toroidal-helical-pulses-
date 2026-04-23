%% ================== 数据区（请替换成你的数据） ==================
% 公共横坐标（例如某个参数、时间等）
x_theory = 0:90;                % 理论的自变量
x_sim    = 15:15:75;              % 仿真点
x_test   = 15:15:75;              % 测试点

% 指标 涡旋度（用于左 y 轴）
yA_theory = 90-x_theory;     % 理论 A
yA_sim    = 90-[20.42 26.30 43.46 57.09 75.09];  % 仿真 A
yA_test   = 90-[27.03 27.38 51.38 58.94 74.73]; % 测试 A

% 指标 B（用于右 y 轴）
yB_theory = ones(size(x_theory));   % 理论 B
yB_sim    = [0.9213 0.9752 0.9329 0.9782 0.9954];   % 仿真 B
yB_test   = [0.9681 0.9944 0.9292 0.9877 0.9656];   % 测试 B

%% ================== 颜色（APL 风格，三组数据） ==================
c_theory = [0.0 0.15 0.55];   % 深蓝 - 理论
c_sim    = [0.75 0.20 0.25];  % 砖红 - 仿真
c_test   = [0.20 0.45 0.25];  % 暗绿 - 测试

%% ================== 绘图 ==================
figure;

% ---------- 左 y 轴：指标 A ----------
yyaxis left
h1 = plot(x_theory, yA_theory, '-', ...
    'Color', c_theory, 'LineWidth', 2.2);  % 理论 A 曲线

hold on;
h2 = scatter(x_sim, yA_sim, 80, 'o', ...
    'MarkerEdgeColor', c_sim, ...
    'MarkerFaceColor', 'none', ...
    'LineWidth', 1.4);                     % 仿真 A 散点（空心圆）

h3 = scatter(x_test, yA_test, 80, 's', ...
    'MarkerEdgeColor', c_test, ...
    'MarkerFaceColor', 'none', ...
    'LineWidth', 1.4);                     % 测试 A 散点（空心方）

ylabel('Metric A (单位)', 'FontSize', 14);
set(gca, 'YColor', [0 0 0]);              % 轴线颜色用黑色更期刊风
set(gca, 'YTick', [0,45,90]);

% ---------- 右 y 轴：指标 B ----------
yyaxis right
h4 = plot(x_theory, yB_theory, '--', ...
    'Color', c_theory, 'LineWidth', 2.0);  % 理论 B 曲线（同色但虚线）

h5 = scatter(x_sim, yB_sim, 70, '^', ...
    'MarkerEdgeColor', c_sim, ...
    'MarkerFaceColor', 'none', ...
    'LineWidth', 1.3);                     % 仿真 B 散点（三角）

h6 = scatter(x_test, yB_test, 70, 'd', ...
    'MarkerEdgeColor', c_test, ...
    'MarkerFaceColor', 'none', ...
    'LineWidth', 1.3);                     % 测试 B 散点（菱形）

ylabel('Metric B (单位)', 'FontSize', 14);
set(gca, 'YColor', [0 0 0]);              % 右轴同样用黑色

% ---------- 公共设置 ----------
xlabel('X (自变量)', 'FontSize', 16);
set(gca, 'FontSize', 14, 'LineWidth', 1.2);
box on;
xlim([0 91])
yyaxis left
ylim([0 91])

yyaxis right
ylim([0 2])

set(gca, 'XTick', [0,45,90]);

% 图例：只按“理论/仿真/测试”分，不按 A/B 重复
legend([h1 h2 h3 h4 h5 h6], ...
       {'Theory', 'Simulation', 'Experiment', 'Experiment', 'Experiment', 'Experiment'}, ...
       'Location', 'best', 'FontSize', 13, 'Box', 'off');


%% ========== 如需投稿：保存为矢量图 ==========
set(gcf, 'Renderer', 'painters');
print(gcf, '-dpdf', '-painters', 'E:\工作\硕士阶段文章\文章\数据整理\涡旋斯格名子\画图与处理程序与数据\螺旋度\figure_name111.pdf');


