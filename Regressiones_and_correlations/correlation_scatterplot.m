%% CORRELATION
 
load Second_peak_US_county_transformed_data.mat
load Lasso_sparse_Round_1.mat

% function correlation_scatterplot(var1,var2,varname1,varname2)
%23fim,34deat,51smok,71unchil
%UNTITLED5 Summary of this function goes here
x_org = data_fin(:,2:end);
x_names = Varnames(2:end);
y = data_fin(:,1);

x = normalize(x_org);

figure
subplot(2,2,1)
ed1 = x(:,34) ; 
ed2 = y(:,1) ; 
[R,P] = corrcoef(ed1,ed2) ; 

p = polyfit(ed1,ed2,1);
h = min(ed1):0.1:max(ed1) ; 
pv = polyval(p,h);
plot(ed1,ed2,'o','MarkerSize',2,'MarkerEdgeColor',[0/255,104/255,55/255],...
    'MarkerFaceColor',[26/255,152/255,80/255])
hold on
plot(h,pv,'r--','LineWidth',2)
xlabel("Total Deaths",'FontSize' ,12);
ylabel("m/r",'FontSize' ,12);
str = {['R = ',num2str(R(1,2))],['P = ',num2str(P(1,2))]} ; 
annotation('textbox',[0.15,0.8,0.1,0.1],'String',str)
hold off

subplot(2,2,2)
ed1 = x(:,23) ; 
ed2 = y(:,1) ; 
[R,P] = corrcoef(ed1,ed2) ; 

p = polyfit(ed1,ed2,1);
h = min(ed1):0.1:max(ed1) ; 
pv = polyval(p,h);
plot(ed1,ed2,'o','MarkerSize',2,'MarkerEdgeColor',[0/255,104/255,55/255],...
    'MarkerFaceColor',[26/255,152/255,80/255])
hold on
plot(h,pv,'r--','LineWidth',2)
xlabel("Female 65",'FontSize' ,12);
ylabel("m/r",'FontSize' ,12);
str = {['R = ',num2str(R(1,2))],['P = ',num2str(P(1,2))]} ; 
annotation('textbox',[0.15,0.8,0.1,0.1],'String',str)
hold off

subplot(2,2,3)
ed1 = x(:,51) ; 
ed2 = y(:,1) ; 
[R,P] = corrcoef(ed1,ed2) ; 

p = polyfit(ed1,ed2,1);
h = min(ed1):0.1:max(ed1) ; 
pv = polyval(p,h);
plot(ed1,ed2,'o','MarkerSize',2,'MarkerEdgeColor',[0/255,104/255,55/255],...
    'MarkerFaceColor',[26/255,152/255,80/255])
hold on
plot(h,pv,'r--','LineWidth',2)
xlabel("Adult smoking",'FontSize' ,12);
ylabel("m/r",'FontSize' ,12);
str = {['R = ',num2str(R(1,2))],['P = ',num2str(P(1,2))]} ; 
annotation('textbox',[0.15,0.8,0.1,0.1],'String',str)
hold off

subplot(2,2,4)
ed1 = x(:,71) ; 
ed2 = y(:,1) ; 
[R,P] = corrcoef(ed1,ed2) ; 

p = polyfit(ed1,ed2,1);
h = min(ed1):0.1:max(ed1) ; 
pv = polyval(p,h);
plot(ed1,ed2,'o','MarkerSize',2,'MarkerEdgeColor',[0/255,104/255,55/255],...
    'MarkerFaceColor',[26/255,152/255,80/255])
hold on
plot(h,pv,'r--','LineWidth',2)
xlabel("Uninsured children",'FontSize' ,12);
ylabel("m/r",'FontSize' ,12);
str = {['R = ',num2str(R(1,2))],['P = ',num2str(P(1,2))]} ; 
annotation('textbox',[0.15,0.8,0.1,0.1],'String',str)
hold off
% end

