clear();
%clc();

load data8.mat;
Xinit=[randn(200,2)/160; [randn(200,1)/160-0.5 randn(200,1)/160-2.5]];
Xinit = Xo;
Xo = Xo(1:3:end,:);
Xinit = Xinit(1:3:end,:);


% load spiral
% Xo = D(1:end,:);
% Xinit=[randn(600,1)/160-1.5 randn(600,1)/160+12]; 
% Xinit = Xo;
% Xo = Xo(1:end,:);
% Xinit = Xinit(1:end,:);



% load cross
% Xo = 20*D;
% Xinit=[randn(300,1)/160 randn(300,1)/160];

s2 = 0.2;
lambda = 1.0;
NIter = 200;

Forces = itms_forces(Xinit, Xo, s2, lambda);
%Xfinal = itms_c(Xinit, s2, lambda, NIter);

hold('on');
plot(Xo(:,1), Xo(:,2), 'ro');
quiver(Xo(:,1),Xo(:,2),Forces(:,1),Forces(:,2));
