% Three-curve Thurstone Case V visualization
clear; close all; clc;
rng(42);  % reproducible non-integer means

% Parameters (per-stimulus)
baseMuA = 3; baseMuB = 1;
jitterA = 0.35 * (2*rand-1);
jitterB = 0.35 * (2*rand-1);
muA   = baseMuA + jitterA;
muB   = baseMuB + jitterB;
sigma = 1.0483;

% Axes for A and B
xmin = min(muA, muB) - 5*sigma;
xmax = max(muA, muB) + 5*sigma;
x    = linspace(xmin, xmax, 2000);

% PDFs for A and B
pdfA = normpdf(x, muA, sigma);
pdfB = normpdf(x, muB, sigma);

% Difference D = Q_A - Q_B
muD    = muA - muB;
sigmaD = sqrt(2) * sigma;
xd     = linspace(muD - 5*sigmaD, muD + 5*sigmaD, 2000);
pdfD   = normpdf(xd, muD, sigmaD);

% Probability that A > B
pA_beats_B = 1 - normcdf(0, muD, sigmaD);  % = normcdf(muD/sigmaD)

% Colors
colA = [0.60 0.40 0.80]; % light purple
colB = [0.85 0.33 0.10];% MATLAB orange 
colD = [0.00 0.60 0.50];      % teal

% Plot
figure('Color','w'); hold on;

% The three curves
hA = plot(x,  pdfA, 'Color', colA, 'LineWidth', 2, 'DisplayName','Stimulus A');
hB = plot(x,  pdfB, 'Color', colB, 'LineWidth', 2, 'DisplayName','Stimulus B');
hD = plot(xd, pdfD, 'Color', colD, 'LineWidth', 2, 'DisplayName','Difference (A-B)');

% Shade area under D for x >= 0 (P(A > B)) — auxiliary (hidden from legend)
mask   = xd >= 0;
x_fill = xd(mask);
y_fill = pdfD(mask);
fill([x_fill, fliplr(x_fill)], [y_fill, zeros(size(y_fill))], ...
     colD, 'FaceAlpha', 0.18, 'EdgeColor','none', 'HandleVisibility','off');

% Legend: only A, B, D
legend([hA hB hD], 'Location','northwest', 'Orientation','vertical', 'Box','off');

% Labels and title
ylabel('Probability Density','FontSize',14);
xl = xlabel('Perceived Quality','FontSize',14);
set(xl, 'Units','normalized'); pos = get(xl,'Position'); pos(2) = pos(2) - 0.03; set(xl,'Position',pos);
title('Thurstone Case V: Perceived Quality Distributions','FontSize',16);

% Hide numeric ticks; annotate μ_A, μ_B, and 0 as markers
set(gca, 'XTick', [], 'Box','off');

% Baseline x-axis (hidden from legend)
plot([min([xmin, xd(1)]) max([xmax, xd(end)])], [0 0], 'k-', 'LineWidth', 0.5, 'HandleVisibility','off');

% Tick markers and labels at μ_A, μ_B, and 0
yticklen = 0.05 * max([pdfA, pdfB, pdfD]);
plot([muA muA], [0 yticklen], 'Color', colA, 'LineWidth', 1, 'HandleVisibility','off');
plot([muB muB], [0 yticklen], 'Color', colB, 'LineWidth', 1, 'HandleVisibility','off');
plot([0 0],     [0 yticklen], 'k-',           'LineWidth', 1, 'HandleVisibility','off');

text(muA, -0.7*yticklen, '\mu_A', 'HorizontalAlignment','center', 'VerticalAlignment','top', 'Color', colA, 'FontSize', 12);
text(muB, -0.7*yticklen, '\mu_B', 'HorizontalAlignment','center', 'VerticalAlignment','top', 'Color', colB, 'FontSize', 12);
text(0,   -0.7*yticklen, '0',     'HorizontalAlignment','center', 'VerticalAlignment','top', 'Color', 'k', 'FontSize', 12);

% Probability annotation
text(muD + 0.8*sigmaD, max(pdfD)*0.78, ...
     sprintf('P(A > B)'), ...
     'Color', colD, 'FontSize', 12, 'FontWeight','bold');

grid on; ax = gca; ax.YGrid = 'on'; ax.XGrid = 'off';
hold off;