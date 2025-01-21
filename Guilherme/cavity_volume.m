clear; clc;

%Parameters
Re = [20000 40000 60000 80000]; %Reynolds Number

r = 0.0005; %Radius of Orifice m

L = 0.0015; %Neck Length m

n = 9; %Number of Holes

c = 0.2; %Chord Length m

volumes = cavityvolume(Re, r, L, n, c);

for i = 1:length(volumes)
    fprintf("Volume for  Re(%.0f) = %.0f is %f m^3\n", i, Re(i), volumes(i))
end

%Function for Volume of Cavity
function cavityvolume = cavityvolume(Re, r, L, n, c)
    a = 343; %Speed of sound m/s
    nu  = 1.5e-5; %Kinematic Viscocity m^2/s

    cavityvolume = zeros(size(Re));
    for i = 1:length(Re)
        st = 0.023 * Re(i)^0.5;
        U = (Re(i)*nu)/(c); %Air Velocity m/s
        f = ((st*U)/(c)); %fFrequency Hz
        k = (n*pi*r^2)/(L + 1.697*r);

        cavityvolume(i) = k/(f*(2*pi/a))^2;
    end
end
