clc
clear
close all

format longG
%---------------------------- data access ---------------------------------
% weight tare data
tare_data = 'run653.csv'; % replace with the uploaded file's name
taredata = readtable(tare_data);

% original data.csv file
og_data = 'data.csv';
ogdata = readtable(og_data);

alpha_offset = 0; % degrees
Q_conversion = 62.9; % Pa/V

%------------------------------ WOZ data ------------------------------
wozrow = taredata(taredata.Code == 1, :); % where code = 1

% axial force, normal force, and dynamic pressure in woz row
wozaxial = wozrow.X_N; % WOZ axial force negative
woznormal = wozrow.Y_N; % WOZ normal force
wozQV = wozrow.Q_V; %WOZ pressure in voltage BEFORE CONVERSION

% subtract WOZ values from force data
axialtared = -(taredata.X_N - wozaxial);
normaltared = taredata.Y_N - woznormal;

% convert dynamic pressure Q from V to Pa
QPatared = (taredata.Q_V - wozQV) * Q_conversion;

% adjust alpha values from the data.csv file
alphaoffset = ogdata.Alpha_Deg + alpha_offset;

%----------------------------- Linear fits -------------------------------
% linear fits for weight tare
fit_axial = polyfit(alphaoffset, axialtared, 1);
fit_normal = polyfit(alphaoffset, normaltared, 1);

% fitted values at each angle of attack
fitaxial_vs_alpha = polyval(fit_axial, alphaoffset);
fitnormal_vs_alpha = polyval(fit_normal, alphaoffset);

%---------------------------------- plots ---------------------------------
% ------------------------------- AXIAL FORCE ------------------------------
figure;
subplot(2, 2, 1);
plot(alphaoffset, axialtared, 'b-o', 'MarkerFaceColor', 'b','MarkerSize', 3, 'DisplayName', 'Tared Data');
hold on;
plot(alphaoffset, fitaxial_vs_alpha, '-', 'DisplayName', 'Fit Line');
xlabel('Alpha (°)');
ylabel('Axial Force Tare (N)');
title('Axial Force vs Alpha');
legend('Location', 'best');
grid off;

ax = gca; % set axes to origin
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
ax.Box = 'off';

%-------------------------------- NORMAL FORCE ----------------------------
subplot(2, 2, 2);
plot(alphaoffset, normaltared, 'b-o', 'MarkerFaceColor', 'b', 'MarkerSize', 3,'DisplayName', 'Tared Data');
hold on;
plot(alphaoffset, fitnormal_vs_alpha, '-', 'DisplayName', 'Fit Line');
xlabel('Alpha (°)');
ylabel('Normal Force Tare (N)');
title('Normal Force vs Alpha');
legend('Location', 'best');
grid off;

ax = gca; % set axes to origin
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
ax.Box = 'off';

%---------------------------- L & D ---------------------------------------
%DATA.CSV

data = csvread('data.csv',1); 
alpha_deg = data(1:end, 2); % AoA
axial_N = data(1:end,3); % force - axial direction
normal_N = data(1:end,4); % force - normal direction
delta = data(1:end, 6); % alignment offset

%---------------------------- L & D ---------------------------------------
L = normal_N .* cosd(alpha_deg - delta) - axial_N .* sind(alpha_deg - delta);
D = axial_N .* cosd(alpha_deg - delta) + normal_N .* sind(alpha_deg - delta);

%RUN 653
D = axialtared .* cosd(alphaoffset) + normaltared .* sind(alphaoffset);
L = normaltared .* cosd(alphaoffset) - axialtared .* sind(alphaoffset);
LDRatio = L ./ D;

subplot(2,2,3)
plot(alphaoffset, LDRatio, 'r-o', 'MarkerFaceColor', 'r', 'MarkerSize', 4, 'DisplayName', '653')
hold on
plot(alpha_deg, LDRatio, 'b-o', 'MarkerFaceColor', 'b', 'MarkerSize', 3, 'DisplayName', 'data.csv')

title('L/D');
xlabel('a [°]');
ylabel('L/D');
legend('Location', 'best');

ax = gca; % set axes to origin
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
ax.Box = 'off';

set(gca, 'box', 'off')
set(gca, 'FontSize',10);

axis([-8, 13, -10, 18]); % ticks for axes
x_ticks = -6:1:14;
y_ticks = -10:1:18;

grid off;
hold off