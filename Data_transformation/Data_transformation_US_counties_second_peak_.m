%% COVID-19 US counties data transformation
%% Initial analysis, determination of infection and mortality rates, and data transformations for counties in the United States.  

% Loading data:

clear 

load Second_Peak_US_county_data.mat

Varnames = Varnames_data_mat ; 

data = data_mat ; 


%% Data Transformation

data_mat_transf(:,1) = data_mat(:,1).^(1/3) ; 
data_mat_transf(:,2) = log(data_mat(:,2)) ;
data_mat_transf(:,3) = data_mat(:,3) ;
data_mat_transf(:,4) = data_mat(:,4) ;
data_mat_transf(:,5) = log(data_mat(:,5) - min(data_mat(:,5))) ;
data_mat_transf(:,6) = log(data_mat(:,6)) ;
data_mat_transf(:,7) = log(data_mat(:,7)) ;
data_mat_transf(:,8) = log(data_mat(:,8)) ;
data_mat_transf(:,9) = ((data_mat(:,9)) - min(data_mat(:,9))).^(1/3);
data_mat_transf(:,10) = -(max(data_mat(:,10))-data_mat(:,10)).^(1/3) ;
data_mat_transf(:,11) = log(data_mat(:,11)) ;
data_mat_transf(:,12) = ((data_mat(:,12)) - min(data_mat(:,12))).^(1/3);
data_mat_transf(:,13) = -sqrt(max(data_mat(:,13))-data_mat(:,13)) ;
data_mat_transf(:,14) = sqrt(data_mat(:,14)) ;
data_mat_transf(:,15) = data_mat(:,15) ;
data_mat_transf(:,16) = data_mat(:,16) ;
data_mat_transf(:,17) = sqrt(data_mat(:,17)) ;
data_mat_transf(:,18) = data_mat(:,18).^(1/3) ; 
data_mat_transf(:,19) = data_mat(:,19) ;
data_mat_transf(:,20) = data_mat(:,20) ;
data_mat_transf(:,21) = data_mat(:,21) ;
data_mat_transf(:,22) = data_mat(:,22) ;
data_mat_transf(:,23) = -log((max(data_mat(:,23))-data_mat(:,23))) ;
data_mat_transf(:,24) = data_mat(:,24).^2 ;
data_mat_transf(:,25) = sqrt(data_mat(:,25) - min(data_mat(:,25))) ;
data_mat_transf(:,26) = ((data_mat(:,26)) - min(data_mat(:,26))).^(1/3);
data_mat_transf(:,27) = ((data_mat(:,27)) - min(data_mat(:,27))).^(1/3);
data_mat_transf(:,28) = log(data_mat(:,28) - min(data_mat(:,28))) ;
data_mat_transf(:,29) = log(data_mat(:,29)) ;
data_mat_transf(:,30) = ((data_mat(:,30)) - min(data_mat(:,30))).^(1/3);
data_mat_transf(:,31) = sqrt(data_mat(:,31) - min(data_mat(:,31)));
data_mat_transf(:,32) = data_mat(:,32) ;
data_mat_transf(:,33) = sqrt(data_mat(:,33) - min(data_mat(:,33)));
data_mat_transf(:,34) = ((data_mat(:,34)) - min(data_mat(:,34))).^(1/3);
data_mat_transf(:,35) = data_mat(:,35).^2 ;
data_mat_transf(:,36) = data_mat(:,36);
data_mat_transf(:,37) = data_mat(:,37);
data_mat_transf(:,38) = data_mat(:,38);
data_mat_transf(:,39) = data_mat(:,39);
data_mat_transf(:,40) = data_mat(:,40);
data_mat_transf(:,41) = data_mat(:,41);
data_mat_transf(:,42) = data_mat(:,42);
data_mat_transf(:,43) = data_mat(:,43);
data_mat_transf(:,44) = data_mat(:,44);
data_mat_transf(:,45) = data_mat(:,45);
data_mat_transf(:,46) = data_mat(:,46);
data_mat_transf(:,47) = data_mat(:,47);
data_mat_transf(:,48) = data_mat(:,48);
data_mat_transf(:,49) = data_mat(:,49);
data_mat_transf(:,50) = sqrt(data_mat(:,50)); 
data_mat_transf(:,51) = data_mat(:,51);
data_mat_transf(:,52) = sqrt(data_mat(:,52)); 
data_mat_transf(:,53) = data_mat(:,53);
data_mat_transf(:,54) = data_mat(:,54);
data_mat_transf(:,55) = data_mat(:,55);
data_mat_transf(:,56) = data_mat(:,56);
data_mat_transf(:,57) = data_mat(:,57);
data_mat_transf(:,58) = data_mat(:,58);
data_mat_transf(:,59) = data_mat(:,59);
data_mat_transf(:,60) = data_mat(:,60).^(1/3) ;
data_mat_transf(:,61) = sqrt(data_mat(:,61)) ;
data_mat_transf(:,62) = data_mat(:,62);
data_mat_transf(:,63) = data_mat(:,63);
data_mat_transf(:,64) = data_mat(:,64).^2 ;
data_mat_transf(:,65) = -(max(data_mat(:,65))-data_mat(:,65)).^(1/3) ;
data_mat_transf(:,66) = data_mat(:,66);
data_mat_transf(:,67) = data_mat(:,67);
data_mat_transf(:,68) = data_mat(:,68).^(1/3) ;
data_mat_transf(:,69) = sqrt(data_mat(:,69)) ;
data_mat_transf(:,70) = data_mat(:,70).^2 ;
data_mat_transf(:,71) = data_mat(:,71).^2 ;
data_mat_transf(:,72) = data_mat(:,72);
data_mat_transf(:,73) = data_mat(:,73);
data_mat_transf(:,74) = data_mat(:,74);
data_mat_transf(:,75) = data_mat(:,75);
data_mat_transf(:,76) = log(data_mat(:,76)) ;
data_mat_transf(:,77) = sqrt(data_mat(:,77)) ;
data_mat_transf(:,78) = data_mat(:,78);
data_mat_transf(:,79) = data_mat(:,79).^2 ;
data_mat_transf(:,80) = data_mat(:,80);
data_mat_transf(:,81) = sqrt(data_mat(:,81) - min(data_mat(:,81))) ;
data_mat_transf(:,82) = sqrt(data_mat(:,82)) ;
data_mat_transf(:,83) = log(data_mat(:,83)) ;
data_mat_transf(:,84) = sqrt(data_mat(:,84)) ;
data_mat_transf(:,85) = log(data_mat(:,85)) ;
data_mat_transf(:,86) = data_mat(:,86);
data_mat_transf(:,87) = sqrt(data_mat(:,87) - min(data_mat(:,87))) ;
data_mat_transf(:,88) = data_mat(:,88);
data_mat_transf(:,89) = sqrt(data_mat(:,89)) ;
data_mat_transf(:,90) = data_mat(:,90);
data_mat_transf(:,91) = data_mat(:,91).^(1/3) ;
data_mat_transf(:,92) = data_mat(:,92);
data_mat_transf(:,93) = data_mat(:,93).^(1/3) ;
data_mat_transf(:,94) = data_mat(:,94).^(1/3) ;
data_mat_transf(:,95) = log(data_mat(:,95)) ;
data_mat_transf(:,96) = data_mat(:,96).^(1/3) ;
data_mat_transf(:,97) = data_mat(:,97);
data_mat_transf(:,98) = data_mat(:,98);
data_mat_transf(:,99) = data_mat(:,99);
data_mat_transf(:,100) = sqrt(data_mat(:,100)) ;
data_mat_transf(:,101) = data_mat(:,101);
data_mat_transf(:,102) = sqrt(data_mat(:,102)) ;
data_mat_transf(:,103) = log(data_mat(:,103)) ;
data_mat_transf(:,104) = data_mat(:,104);
data_mat_transf(:,105) = data_mat(:,105);
data_mat_transf(:,106) = data_mat(:,106);
data_mat_transf(:,107) = data_mat(:,107);
data_mat_transf(:,108) = log(data_mat(:,108)) ;
data_mat_transf(:,109) = data_mat(:,109);
data_mat_transf(:,110) = data_mat(:,110);
data_mat_transf(:,111) = data_mat(:,111);
data_mat_transf(:,112) = sqrt(data_mat(:,112)) ;
data_mat_transf(:,113) = log(data_mat(:,113)) ;
data_mat_transf(:,114) = log(data_mat(:,114)) ;
data_mat_transf(:,115) = data_mat(:,115).^2 ;
data_mat_transf(:,116) = data_mat(:,116)


%% Removing outlier

data_mat_transf_out = substituteoutlier(data_mat_transf); 

%% Check
s= (abs(skewness(data_mat_transf_out)))' ; 
for i = 1:length(s)
    s(i,2)=i;
end
T = array2table(s);
T = sortrows(T,'s1','descend');


%% Data saving:
save Second_peak_US_county_transformed_data.mat data_mat_transf_out Varnames_data_mat













