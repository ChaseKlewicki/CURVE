clc; clear;
disp(rand)

%% tare
%base data refers to the raw data of the tare file

offset = 0.7;
VtoPa = 62.9; %value to convert from votltage to pascals
delta = 0.8;
%to do in future: generalize columns and stuff
base_data1 = csvread("run641.csv",2,34); %grabs everything after the date
base_data2 = readmatrix("run641.csv","Range",[2, 1, length(base_data1(:,1))+1, 32]); %everything before the date

base_data_combined = cat(2,base_data2,base_data1); %everything but dates and header
%data to tare goes from col 18 to... 31(?) or perhaps 23?
%(ask if right number)
%(ask if std is standard deviation)

tare = base_data_combined(1,18:26); %this may not be accurate in future data
for i = 1:length(base_data1(:,1)) 
    data(i,:) = cat(2,base_data_combined(i,1:17),base_data_combined(i,18:26)-tare,base_data_combined(i,27:36));
    %creates a new matrix of data; tares the weight data from column one.
    %new matrix doesn't include tare data.
end
data(:,30) = (data(:,30) - base_data_combined(1,30)).*62.9; %tares Q_V

%yoink the data for best fit line
alpha = data(:,15)-offset;
X_N = data(:,18);
Y_N = data(:,20);
X_M = data(:,24);
Y_M = data(:,26);
Pa = data(:,30);

%create best fit line

p_xn = polyfit(alpha, X_N, 1); 
p_yn = polyfit(alpha, Y_N, 1);
p_pa = polyfit(alpha, Pa, 1);

%forces also: pressure
%ignore standard distribution
%X: axial
%Y: normal
%M is moment

%% data analysis

%sets up outside parameters
c = 0.2;
b = 0.6;
rho = 1.23;
nu = 1.5*10^-5;
S = b*c; 

%import the data (could make a function for this)
raw_data1 = csvread("run653.csv",2,34); %cut out the first row of data due to back q value
raw_data2 = readmatrix("run653.csv","Range",[2, 1, length(raw_data1(:,1))+1, 32]); %everything before the date
raw_data_combined = cat(2,raw_data2,raw_data1); %everything but dates and header

for i = 1:length(raw_data1(:,1)) 
    data_t(i,:) = cat(2,raw_data_combined(i,1:17),raw_data_combined(i,18:26)-tare,raw_data_combined(i,27:36));
    %creates a new matrix of data; tares the weight data from column one.
    %new matrix doesn't include tare data.
end
%get Q from the difference of row 1 of the actual data
alpha_t = data_t(:,15);
data_t(:,30) = (data_t(:,30) - data_t(1,30)).*62.9; %tares Q_V

%TARE THE DATA HERE
Q = data_t(:,30);
%tare X and Y
X_t = -data_t(:,18) + data_t(1,18) + (p_xn(1)*(alpha_t)+p_xn(2));
Y_t = data_t(:,20) - data_t(1,20) - (p_yn(1)*(alpha_t)+p_yn(2));

%calcualte l and d
L=Y_t.*cos((alpha_t-delta)*pi/180)-X_t.*sin((alpha_t-delta)*pi/180);
D=X_t.*cos((alpha_t-delta)*pi/180)+Y_t.*sin((alpha_t-delta)*pi/180);

%calculate desired info
Cl = L./Q./S;
Cd = D./Q./S;
Re = (2.*Q./rho).^0.5.*c./nu;
LD = Cl./Cd;
ReVal = mean(Re);
ReVal = round(ReVal);

%graph the graphs
figure(4);
subplot(2,2,1);
plot(alpha,Cl,'Color','#c90025','Marker','*')
grid("on");
title("Cl");
xlabel("alpha")
ylabel("Cl")
hold("on")
plot(alpha,alpha.*0.11,'Color','black','LineWidth',1.1)
N = ['Re: ', num2str(ReVal)];
legend(N,'flat plate')

subplot(2,2,2);
plot(alpha,Cd,'Color','#c90025','Marker','*')
grid("on");
title("Cd");
xlabel("alpha")
ylabel("Cd")
N = ['Re: ', num2str(ReVal)];
legend(N)

subplot(2,2,3);
plot(Cd, Cl,'Color','#c90025','Marker','*')
grid("on");
title("L/D");
xlabel("Cd")
ylabel("Cl")
N = ['Re: ', num2str(ReVal)];
legend(N)

subplot(2,2,4);
plot(alpha,LD,'Color','#c90025','Marker','*')
grid("on");
title("L/D");
xlabel("alpha")
ylabel("L/D")
N = ['Re: ', num2str(ReVal)];
legend(N)

%% graph LD together

%{
[alpha_orig, LD_orig] = plot_other;

figure(2);
plot(alpha_t,LD,'Color','#c90025','Marker','o')
hold on
plot(alpha_orig,LD_orig,'Color','#0055ff','Marker','*')
grid("on");
title("L/D");
xlabel("alpha")
ylabel("L/D")
legend('Calculated from tare','data.csv')
%}

%should be shifting by delta, not alpha offset (table is aware of alpha
%offset, so already accounts for it, but does not account for delta)