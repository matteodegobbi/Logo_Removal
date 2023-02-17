clear
close all
x = linspace(-6,6,50);
y = x';
z = ones(50) .* (8*cos(2*x).*(abs(x)<1) - y.^2 +x.^2);
surf(x,y,z);
 
zLinea=8*ones(50);
hold on
plot3([-3,3],[0,0],[8,8],LineWidth=5,Color='red')
plot3([0,0],[-3,3],[8,8],LineWidth=5,Color='magenta')