clc;clear all;
close all
%基本参数
c=3.0e8;
mu=4.0*pi*1.0e-7;                                  
epsilon=1.0/(c*c*mu);
z0=sqrt(mu/epsilon);
q1=0.02;
f0=1e-7;
q2=20*q1;
l=0;

x=-0.5:0.0100000000:0.5;
y=-0.5:0.0100000000:0.5;


z=0.0;
t=z/c-15*q1/c:0.1*q1/c:z/c+15*q1/c;
tt=t;
[x,y,t]=meshgrid(x,y,t);
[theta,rho]=cart2pol(x,y);


    Etheta1=(-((mu./epsilon).^(1./2).*((4.*f0.*rho.*exp(l.*theta.*1i).*(c.*(- q2 + z.*1i + c.*t.*1i).*1i - c.*(q1 + z.*1i - c.*t.*1i).*1i).*(rho./(q1 + z.*1i - c.*t.*1i)).^abs(l))./(- rho.^2 + (- q2 + z.*1i + c.*t.*1i).*(q1 + z.*1i - c.*t.*1i)).^3 + (f0.*exp(l.*theta.*1i).*abs(l).*(c.*(- q2 + z.*1i + c.*t.*1i).*1i - c.*(q1 + z.*1i - c.*t.*1i).*1i).*(rho./(q1 + z.*1i - c.*t.*1i)).^(abs(l) - 1))./((- rho.^2 + (- q2 + z.*1i + c.*t.*1i).*(q1 + z.*1i - c.*t.*1i)).^2.*(q1 + z.*1i - c.*t.*1i)) + (c.*f0.*exp(l.*theta.*1i).*abs(l).*(rho./(q1 + z.*1i - c.*t.*1i)).^(abs(l) - 1).*1i)./((- rho.^2 + (- q2 + z.*1i + c.*t.*1i).*(q1 + z.*1i - c.*t.*1i)).*(q1 + z.*1i - c.*t.*1i).^2) + (c.*f0.*rho.^2.*exp(l.*theta.*1i).*abs(l).*(rho./(q1 + z.*1i - c.*t.*1i)).^(abs(l) - 1).*2i)./((- rho.^2 + (- q2 + z.*1i + c.*t.*1i).*(q1 + z.*1i - c.*t.*1i)).^2.*(q1 + z.*1i - c.*t.*1i).^2) + (c.*f0.*rho.*exp(l.*theta.*1i).*abs(l).*(rho./(q1 + z.*1i - c.*t.*1i)).^(abs(l) - 2).*(abs(l) - 1).*1i)./((- rho.^2 + (- q2 + z.*1i + c.*t.*1i).*(q1 + z.*1i - c.*t.*1i)).*(q1 + z.*1i - c.*t.*1i).^3)))./c);
    Erho1=(((mu./epsilon).^(1./2).*((f0.*l.*exp(l.*theta.*1i).*(c.*(- q2 + z.*1i + c.*t.*1i).*1i - c.*(q1 + z.*1i - c.*t.*1i).*1i).*(rho./(q1 + z.*1i - c.*t.*1i)).^abs(l).*1i)./(- rho.^2 + (- q2 + z.*1i + c.*t.*1i).*(q1 + z.*1i - c.*t.*1i)).^2 - (c.*f0.*l.*rho.*exp(l.*theta.*1i).*abs(l).*(rho./(q1 + z.*1i - c.*t.*1i)).^(abs(l) - 1))./((- rho.^2 + (- q2 + z.*1i + c.*t.*1i).*(q1 + z.*1i - c.*t.*1i)).*(q1 + z.*1i - c.*t.*1i).^2)))./(c.*rho));
    ez1=zeros(size(Erho1));


    Hrho1=(- (4.*f0.*rho.*exp(l.*theta.*1i).*(rho./(q1 + z.*1i - c.*t.*1i)).^abs(l).*(2.*z + q2.*1i - q1.*1i))./(- rho.^2 + (- q2 + z.*1i + c.*t.*1i).*(q1 + z.*1i - c.*t.*1i)).^3 + (f0.*exp(l.*theta.*1i).*abs(l).*(rho./(q1 + z.*1i - c.*t.*1i)).^(abs(l) - 1).*1i)./((- rho.^2 + (- q2 + z.*1i + c.*t.*1i).*(q1 + z.*1i - c.*t.*1i)).*(q1 + z.*1i - c.*t.*1i).^2) + (f0.*rho.^2.*exp(l.*theta.*1i).*abs(l).*(rho./(q1 + z.*1i - c.*t.*1i)).^(abs(l) - 1).*2i)./((- rho.^2 + (- q2 + z.*1i + c.*t.*1i).*(q1 + z.*1i - c.*t.*1i)).^2.*(q1 + z.*1i - c.*t.*1i).^2) - (f0.*exp(l.*theta.*1i).*abs(l).*(rho./(q1 + z.*1i - c.*t.*1i)).^(abs(l) - 1).*(2.*z + q2.*1i - q1.*1i))./((- rho.^2 + (- q2 + z.*1i + c.*t.*1i).*(q1 + z.*1i - c.*t.*1i)).^2.*(q1 + z.*1i - c.*t.*1i)) + (f0.*rho.*exp(l.*theta.*1i).*abs(l).*(rho./(q1 + z.*1i - c.*t.*1i)).^(abs(l) - 2).*(abs(l) - 1).*1i)./((- rho.^2 + (- q2 + z.*1i + c.*t.*1i).*(q1 + z.*1i - c.*t.*1i)).*(q1 + z.*1i - c.*t.*1i).^3));
    Htheta1=(-((f0.*l.*exp(l.*theta.*1i).*(rho./(q1 + z.*1i - c.*t.*1i)).^abs(l).*(2.*z + q2.*1i - q1.*1i).*1i)./(- rho.^2 + (- q2 + z.*1i + c.*t.*1i).*(q1 + z.*1i - c.*t.*1i)).^2 + (f0.*l.*rho.*exp(l.*theta.*1i).*abs(l).*(rho./(q1 + z.*1i - c.*t.*1i)).^(abs(l) - 1))./((- rho.^2 + (- q2 + z.*1i + c.*t.*1i).*(q1 + z.*1i - c.*t.*1i)).*(q1 + z.*1i - c.*t.*1i).^2))./rho);
    hz1=(- (- (2.*f0.*exp(l.*theta.*1i).*(c.*(- q2 + z.*1i + c.*t.*1i).*1i - c.*(q1 + z.*1i - c.*t.*1i).*1i).^2.*(rho./(q1 + z.*1i - c.*t.*1i)).^abs(l))./(- rho.^2 + (- q2 + z.*1i + c.*t.*1i).*(q1 + z.*1i - c.*t.*1i)).^3 + (2.*c.^2.*f0.*exp(l.*theta.*1i).*(rho./(q1 + z.*1i - c.*t.*1i)).^abs(l))./(- rho.^2 + (- q2 + z.*1i + c.*t.*1i).*(q1 + z.*1i - c.*t.*1i)).^2 + (2.*c.^2.*f0.*rho.*exp(l.*theta.*1i).*abs(l).*(rho./(q1 + z.*1i - c.*t.*1i)).^(abs(l) - 1))./((- rho.^2 + (- q2 + z.*1i + c.*t.*1i).*(q1 + z.*1i - c.*t.*1i)).*(q1 + z.*1i - c.*t.*1i).^3) + (c.^2.*f0.*rho.^2.*exp(l.*theta.*1i).*abs(l).*(rho./(q1 + z.*1i - c.*t.*1i)).^(abs(l) - 2).*(abs(l) - 1))./((- rho.^2 + (- q2 + z.*1i + c.*t.*1i).*(q1 + z.*1i - c.*t.*1i)).*(q1 + z.*1i - c.*t.*1i).^4) - (c.*f0.*rho.*exp(l.*theta.*1i).*abs(l).*(c.*(- q2 + z.*1i + c.*t.*1i).*1i - c.*(q1 + z.*1i - c.*t.*1i).*1i).*(rho./(q1 + z.*1i - c.*t.*1i)).^(abs(l) - 1).*2i)./((- rho.^2 + (- q2 + z.*1i + c.*t.*1i).*(q1 + z.*1i - c.*t.*1i)).^2.*(q1 + z.*1i - c.*t.*1i).^2))./c.^2 - (2.*f0.*exp(l.*theta.*1i).*(rho./(q1 + z.*1i - c.*t.*1i)).^abs(l))./(- rho.^2 + (- q2 + z.*1i + c.*t.*1i).*(q1 + z.*1i - c.*t.*1i)).^2 - (2.*f0.*exp(l.*theta.*1i).*(rho./(q1 + z.*1i - c.*t.*1i)).^abs(l).*(2.*z + q2.*1i - q1.*1i).^2)./(- rho.^2 + (- q2 + z.*1i + c.*t.*1i).*(q1 + z.*1i - c.*t.*1i)).^3 + (2.*f0.*rho.*exp(l.*theta.*1i).*abs(l).*(rho./(q1 + z.*1i - c.*t.*1i)).^(abs(l) - 1))./((- rho.^2 + (- q2 + z.*1i + c.*t.*1i).*(q1 + z.*1i - c.*t.*1i)).*(q1 + z.*1i - c.*t.*1i).^3) + (f0.*rho.^2.*exp(l.*theta.*1i).*abs(l).*(rho./(q1 + z.*1i - c.*t.*1i)).^(abs(l) - 2).*(abs(l) - 1))./((- rho.^2 + (- q2 + z.*1i + c.*t.*1i).*(q1 + z.*1i - c.*t.*1i)).*(q1 + z.*1i - c.*t.*1i).^4) + (f0.*rho.*exp(l.*theta.*1i).*abs(l).*(rho./(q1 + z.*1i - c.*t.*1i)).^(abs(l) - 1).*(2.*z + q2.*1i - q1.*1i).*2i)./((- rho.^2 + (- q2 + z.*1i + c.*t.*1i).*(q1 + z.*1i - c.*t.*1i)).^2.*(q1 + z.*1i - c.*t.*1i).^2));

ez2=sqrt(mu/epsilon)*hz1;
Etheta2=sqrt(mu/epsilon)*Htheta1;
Erho2=sqrt(mu/epsilon)*Hrho1;


hz2=-sqrt(epsilon/mu)*ez1;
Htheta2=-sqrt(epsilon/mu)*Etheta1;
Hrho2=-sqrt(epsilon/mu)*Erho1;
a=3*pi/12;
bata=0.1*pi;
Etheta3=(exp(1i*bata)*sin(a)*Etheta1+cos(a)*1*Etheta2);
Erho3=(exp(1i*bata)*sin(a)*Erho1+cos(a)*1*Erho2);
ez3=(exp(1i*bata)*sin(a)*ez1+cos(a)*1*ez2);

Htheta3=(sin(a)*Htheta1+cos(a)*1*Htheta2);
Hrho3=(sin(a)*Hrho1+cos(a)*1*Hrho2);
hz3=(sin(a)*hz1+cos(a)*1*hz2);

%%

figure
quiver(real(squeeze(-ez3(51,:,:))),real(squeeze( Erho3(51,:,:))))

draw_z=imag(squeeze(-ez3(51,:,:)));
draw_rho=imag(squeeze(Erho3(51,:,:)));
draw_theta=imag(squeeze(Etheta3(51,:,:)));


%%
draw3d(x,y,t,Etheta3,1,0.3)
 
draw3d(x,y,t,Erho3,2,0.3)

draw3d(x,y,t,ez3,3,0.4)


function draw3d(x,y,t,x_time_dimension,aaa,bbb)
figure(aaa)
f=real(x_time_dimension)/max(max(max(abs(real(x_time_dimension)))));

p1 = patch(isosurface(x,y,t,f,bbb));
isonormals(x,y,t,f,p1)
p1.FaceColor =[256,32,46]/256;
p1.EdgeColor = 'none';
view(3)

p1 = patch(isosurface(x,y,t,f,-bbb));
isonormals(x,y,t,f,p1)
p1.FaceColor = [39,111,256]/256;
p1.EdgeColor = 'none';
view(3)
camlight 
camproj perspective
lighting phong 

material dull  

for i=-1:2:1
for j=-1:2:1
for k=1
    l1 = light;
l1.Style = 'local ';
l1.Position = [i j k];
end
end
end
    daspect([1 1 2.5e-9])
xlim([-0.4,0.4])
ylim([-0.4,0.4])
zlim([1.2e-9,2e-9])

%     set(gca,'ZDir','reverse'); 
view(-37.5,30)
grid on

set(gca, 'ZTick', [1.2e-9,2e-9]);
set(gca, 'XTick', [-0.4,0,0.4]);
set(gca, 'YTick', [-0.4,0,0.4]);

set(gca, 'FontSize',30,'FontName','Times New Roman');%字体


end


