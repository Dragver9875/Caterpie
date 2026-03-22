function plot_episode_results(t, y, e, u, figTitle)
figure('Name',figTitle);

subplot(3,1,1);
plot(t,y,'LineWidth',1.2); grid on;
ylabel('Response');
title(figTitle);

subplot(3,1,2);
plot(t,e,'LineWidth',1.2); grid on;
ylabel('Error');

subplot(3,1,3);
plot(t,u,'LineWidth',1.2); grid on;
ylabel('Control');
xlabel('Time (s)');
end