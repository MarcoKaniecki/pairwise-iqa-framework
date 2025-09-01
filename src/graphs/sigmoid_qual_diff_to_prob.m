% Sigmoid (probit) function for Thurstone Case V

% Define the scaling parameter beta
beta = 1 / norminv(0.75);  % norminv(0.75) ≈ 0.674

% Quality score difference
d = linspace(-5, 5, 1000);

% Probability according to Thurstone Case V
P = normcdf(d / beta);

% Plot
figure;
plot(P, d, 'b', 'LineWidth', 2);
hold on;

% Mark key points
plot([0.25 0.5 0.75], [-1 0 1], 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'k');

% Labels and title
xlabel('Probability');
ylabel('Difference in quality score');
title('Thurstone Case V: Quality Difference to Probability Mapping');
grid on;

% Add text annotations
text(0.5, 0, '  (0.5, 0)', 'VerticalAlignment', 'top');
text(0.75, 1, '  (0.75, 1)', 'VerticalAlignment', 'top');
text(0.25, -1, '  (0.25, -1)', 'VerticalAlignment', 'top');

hold off;
