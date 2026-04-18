function plot_episode_results(t, y, e, u, kpCorr, kiCorr, figTitle)

figure('Name', figTitle);

subplot(5,1,1);
plot(t, y, 'LineWidth', 1.2);
grid on;
ylabel('Response');
title(figTitle);

subplot(5,1,2);
plot(t, e, 'LineWidth', 1.2);
grid on;
ylabel('Error');

subplot(5,1,3);
plot(t, u, 'LineWidth', 1.2);
grid on;
ylabel('Control');

subplot(5,1,4);
if ~isempty(kpCorr)
    plot(t, kpCorr, 'LineWidth', 1.2);
end
grid on;
ylabel('Kp\_corr');

subplot(5,1,5);
if ~isempty(kiCorr)
    plot(t, kiCorr, 'LineWidth', 1.2);
end
grid on;
ylabel('Ki\_corr');
xlabel('Time (s)');
end