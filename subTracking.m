clear all; close all; clc;
load subdata.mat % Imports the data as the 262144x49 (space by time) matrix called subdata

L = 10; % spatial domain
n = 64; % Fourier modes
x2 = linspace(-L,L,n+1); x = x2(1:n); y =x; z = x;
k = (2*pi/(2*L))*[0:(n/2 - 1) -n/2:-1]; ks = fftshift(k);
samples = 49;

%% averaging signal
ave = zeros(n,n,n);
for i=1:samples
    Un(:,:,:)=reshape(subdata(:,i),n,n,n);
    Unt=fftshift(fftn(Un(:,:,:)));
    ave = ave + Unt;
end
ave = abs(ave)/samples;
%% plotting averaged signal in frequency domain
M = max(abs(ave),[],'all');
[X,Y,Z]=meshgrid(x,y,z);
[Kx,Ky,Kz]=meshgrid(ks,ks,ks);
figure()
isosurface(Kx,Ky,Kz,abs(ave)/M,0.7)
axis([-10 10 -10 10 -10 10]), grid on, 
drawnow
% x ranges from 4.4 to 5.4, y ranges from -6.5 to -7.5, z ranges from 1.5 to 2.5
%% filtering
x0 = 4.9; %x offset
y0 = -7; %y offset
z0 = 2; %z offset
xs = 0.6; %x std. dev
ys = 0.6; %y std. dev
zs = 0.6; %z std. dev
filter = exp(-((Kx-x0).^2/(2*xs^2)+(Ky-y0).^2/(2*ys^2)+(Kz-z0).^2/(2*zs^2)));
filtered = ave .* filter;
%% plotting filtered signal in frequency domain
M = max(abs(filtered),[],'all');
isosurface(X,Y,Z,abs(filtered)/M,0.65);
axis([-10 10 -10 10 -10 10]), grid on 
drawnow
%% filtering non-averaged data and inverse transforming back to time domain
path = [];
for i = 1:samples
    Un(:,:,:)=reshape(subdata(:,i),n,n,n);
    Unt=fftshift(fftn(Un(:,:,:)));
    Untf=Unt.*filter;
    Unf = ifftn(Untf);
    [M] = max(abs(Unf),[],'all');
    [xCoord, yCoord, zCoord] = ind2sub(size(Unf), find(abs(Unf) == M));
    path = [path, [xCoord; yCoord; zCoord]];
    isosurface(X,Y,Z,abs(Unf)/M,0.98);
    axis([-10 10 -10 10 -10 10]), grid on 
    drawnow
end

%% Plotting submarine path
plot3(path(1,:),path(2,:),path(3,:), "LineWidth", 2);
hold on;
plot3(path(1,1),path(2,1),path(3,1), 'o', 'LineWidth', 2);
plot3(path(1,end),path(2,end),path(3,end), 'o', 'LineWidth', 2);

grid on
legend("Submarine Path", "Starting Point", "Ending Point")
%% Plotting P-8 poseidon path
figure()
plot(path(1,:),path(2,:), "LineWidth", 2);
hold on;
plot(path(1,1),path(2,1), 'o', 'LineWidth', 2);
plot(path(1,end),path(2,end), 'o', 'LineWidth', 2);
legend("Tracking Path", "Starting Point", "Ending Point")
