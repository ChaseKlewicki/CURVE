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

alpha_offset = 0.7; % degrees
Q_conversion = 62.9; % Pa/V

%------------------------------ WOZ data ------------------------------
wozrow = taredata(taredata.Code == 1, :); % where code = 1

% define axial force, normal force, and dynamic pressure in woz row
wozaxial = wozrow.X_N; % WOZ axial force
woznormal = wozrow.Y_N; % WOZ normal force
wozQV = wozrow.Q_V; %WOZ pressure in voltage BEFORE conversion

% subtract WOZ values from force data
axialtared = taredata.X_N - wozaxial;
normaltared = taredata.Y_N - woznormal;

% convert dynamic pressure Q from V to Pa
QPatared = (taredata.Q_V - wozQV) * Q_conversion;

% adjust alpha values from the data.csv file
alphaoffset = ogdata.Alpha_Deg + alpha_offset;

% linear fits for weight tare
fit_axial = polyfit(alphaoffset, axialtared, 1);
fit_normal = polyfit(alphaoffset, normaltared, 1);

% fitted values at each angle of attack
fitaxial_vs_alpha = polyval(fit_axial, alphaoffset);
fitnormal_vs_alpha = polyval(fit_normal, alphaoffset);

%---------------------------------- plots ---------------------------------
% Axial Force vs. Alpha
figure;
subplot(2, 1, 1);
plot(alphaoffset, axialtared, 'o', 'MarkerFaceColor', 'b','MarkerSize', 3, 'DisplayName', 'Tared Data');
hold on;
plot(alphaoffset, fitaxial_vs_alpha, '-', 'DisplayName', 'Fit Line');
xlabel('Alpha (°)');
ylabel('Axial Force Tare (N)');
title('Axial Force vs Alpha');
legend('Location', 'best');
grid on;

% Normal Force vs. Alpha
subplot(2, 1, 2);
plot(alphaoffset, normaltared, 'o', 'MarkerFaceColor', 'b', 'MarkerSize', 3,'DisplayName', 'Tared Data');
hold on;
plot(alphaoffset, fitnormal_vs_alpha, '-', 'DisplayName', 'Fit Line');
xlabel('Alpha (°)');
ylabel('Normal Force Tare (N)');
title('Normal Force vs Alpha');
legend('Location', 'best');
grid on;