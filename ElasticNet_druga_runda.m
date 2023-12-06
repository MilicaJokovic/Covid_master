%% ElasticNet second round of regression (relaxed)

% Data entry

clc
clear
rng default 
load ElasticNet_sparse_Round_1.mat
%clearvars -except x y x_names

%% Second round

%  Data preparation and parameters for cross-validation

KeepIndex = find(B(:)~=0); 
x = x(:,KeepIndex);
x_names = x_names(KeepIndex);

n_fold = 5;
cv = cvpartition(y,'Kfold',n_fold,'Stratify',false);
n_repart = 40;

% Defining an empty vector to record alpha and lambda values, as well as the MSE of the model
MSE_alpha_lambda_mat = [];

%%  Determining optimal values for lambda and alpha through cross-validation
% Formiranje matrice alpha lambda kombinacija

param_matrix = [];

% Taking 100 values in the range from 0 to 1
alpha_vec = 0.01:0.01:1; 

% We select lambda values through a single 'scan' round of regression for each alpha separately:
x_norm = normalize(x); 
for i = 1:length(alpha_vec)
alpha = alpha_vec(i);
[B_scan, FitInfo_scan] = lasso(x_norm,y,'Alpha',alpha);
% The combinations will be saved in the param_matrix
param_matrix = [param_matrix [repelem(alpha,length(FitInfo_scan.Lambda));FitInfo_scan.Lambda]];
end
    
% Random permutation of indices in the param_matrix
param_index_perm_vec = randperm(size(param_matrix,2));

%% Main code


for index = param_index_perm_vec
    
    % Assigning the appropriate alpha and lambda combination from the param_matrix:
    alpha = param_matrix(1,index);
    lambda = param_matrix(2,index);
    
    % Defining empty vectors for standard errors (SE)
    SE_vector_train = [];
    SE_vector_test = [];
    
    for repart = 1:n_repart
        cnew = repartition(cv); 
        
        parfor i = 1:n_fold
            
            % Determining test and train indices based on the cnew partition
            index_train = find(cnew.test(i)==0);
            index_test = find(cnew.test(i));
            
            % Extracting the training set of data
            y_train = y(index_train);
            x_train = x(index_train,:);
            
            % Standardizing the training set of data:
            mean_x_train = mean(x_train);
            std_x_train = std(x_train);
            x_train_norm = (x_train - mean_x_train)./std_x_train;
            
            % Extracting the test set of data:
            y_test = y(index_test);
            x_test = x( index_test,:);
            
            % Standardizing the test set based on the mean and standard deviation of the training set
            x_test_norm = ( x_test - mean_x_train )./std_x_train;
            
            % Elastic Net regression on the training set:
            [B_train,FitInfo_train] = lasso(x_train_norm,y_train,'Alpha',alpha,'Lambda',lambda,'PredictorNames',x_names);
            
            % % Extracting coefficients from the regression, including the intercept (intersection with the y-axis)
            coef_train = B_train; 
            coef0_train = FitInfo_train.Intercept; 
            
            % Determining the y-values predicted by the model on the training set
            yhat_train = x_train_norm*coef_train + coef0_train; 
            
            % Determining the mean squared error on the training set
            MSE_train_norm = sum((y_train - yhat_train).^2)/sum((y_train - mean(y_train)).^2);
            
            %Determining y and the mean squared error of the model on the test set:
            yhat_test = x_test_norm*coef_train + coef0_train;
            MSE_test_norm = sum((y_test - yhat_test ).^2 )/sum((y_test - mean(y_test)).^2);
            
            % Filling the SE vector with data
            SE_vector_train = [SE_vector_train MSE_train_norm];
            SE_vector_test = [SE_vector_test MSE_test_norm];
        end
        
    end
    
    % Here, we have gone through all partitions for one lambda, so we need to determine the mean squared error (MSE) based on SE:
    MSE_train = mean(SE_vector_train); 
    MSE_test = mean(SE_vector_test);
    
    % Standard errors of the mean squared error:
    sterr_MSE_train = 2*std(SE_vector_train)/sqrt(length(SE_vector_train));
    sterr_MSE_test = 2*std(SE_vector_test)/sqrt(length(SE_vector_test));
    
    % Filling the MSE matrix with lambda and alpha values
    MSE_alpha_lambda_mat = [MSE_alpha_lambda_mat [alpha;lambda;MSE_train;sterr_MSE_train;MSE_test;sterr_MSE_test]];
end
save ElNet_early_saveR MSE_alpha_lambda_mat x y x_names

%% Selecting the best model (the model with the lowest MSE)

%  Selecting the the model with the lowest MSE
[MSE_test_min, index_min] = min(MSE_alpha_lambda_mat(5,:));
% Determining its standard error
sterr_MSE_test_min = MSE_alpha_lambda_mat(6,index_min);
% Determining the MSE value within one standard error of the min MSE
MSE_test_min_err = MSE_test_min + sterr_MSE_test_min;

%% Selecting models that are within one standard error of the min MSE model

index_min_all = find( MSE_alpha_lambda_mat( 5 , : ) < MSE_test_min_err );
MSE_min_all_test = MSE_alpha_lambda_mat( 5 , index_min_all );
sterr_MSE_min_all_test = MSE_alpha_lambda_mat( 6 , index_min_all );
MSE_min_all_train = MSE_alpha_lambda_mat( 3 , index_min_all );
sterr_MSE_min_all_train = MSE_alpha_lambda_mat( 4 , index_min_all );
lambda_min_all = MSE_alpha_lambda_mat( 2 , index_min_all );
alpha_min_all = MSE_alpha_lambda_mat(1, index_min_all);

% Checking how many predictors the selected models have:
x_norm = normalize(x) ;
sp = zeros(1,length(lambda_min_all)); 

%  We perform Elastic Net regression for all selected combinations of alpha and lambda on the entire dataset and save the number of predictors equal to zero
for i = 1:length(lambda_min_all)
    [ B , ~ ] = lasso(x_norm, y, 'Alpha', alpha_min_all(i), 'Lambda', lambda_min_all(i), 'PredictorNames', x_names);

    sp(i) = sum(B == 0) ; 
            
end

%% Determining the model with the fewest predictors

[max_sp, index_max_sp] = max(sp);
lambda_max_sparse = lambda_min_all(index_max_sp);
alpha_max_sparse = alpha_min_all(index_max_sp);
MSE_max_sparse_test = MSE_min_all_test(index_max_sp);
sterr_MSE_sparse_test = sterr_MSE_min_all_test(index_max_sp);
MSE_max_sparse_train = MSE_min_all_train(index_max_sp);
sterr_MSE_sparse_train = sterr_MSE_min_all_train(index_max_sp);


%% Elastic Net regression for the optimal model on the entire set of standardized data:

[B,FitInfo] = lasso(x_norm, y, 'Alpha',alpha_max_sparse,'Lambda',lambda_max_sparse,'PredictorNames',x_names);

coef = B;
coef0 = FitInfo.Intercept ;

yhat = x_norm*coef + coef0  ;
R_square = 1 - (sum((y - yhat).^2)/sum((y - mean(y)).^2));

%% Tabular representation of the results

ModelPredictors = FitInfo.PredictorNames(B(:)~=0); 
koeficijenti = B(B(:)~=0);
Intercept = FitInfo.Intercept; 

Koeficijenti_tabela = [Intercept; koeficijenti]; 
Prediktori_tabela = [{'Intercept'}, ModelPredictors]; 
fprintf('Table for sparsest Elastic Net regression ') ; 
EN_Results_fin = array2table(Koeficijenti_tabela, 'RowNames',Prediktori_tabela, 'VariableNames', {'Estimate'}) ; 
fprintf('\n\n <strong>Sparse Elastic Net regression results </strong>\n')
disp(EN_Results_fin) 

fprintf('alpha = %.2f, lambda = %.2f \nMSE (test) = %.4f\n, SE MSE (test) = %.4f',...
    alpha_max_sparse, lambda_max_sparse,MSE_max_sparse_test, sterr_MSE_sparse_test) ; 

fprintf('R_square = %.6f \n', R_square); 

%%  Graphical representation of the results

figure
cat = categorical(ModelPredictors); 
cat = reordercats(cat, ModelPredictors);
BFC = [26/255,152/255,80/255];
BEC = [0/255,104/255,55/255];
figure
bar(cat, koeficijenti,'FaceColor', BFC,'EdgeColor',BEC,'LineWidth',1.5);
ylabel('Model coefficients')
title('Elastic net regression (sparse)')

save ElasticNet_sparse_Round_1R B FitInfo x y x_names MSE_alpha_lambda_mat alpha_max_sparse lambda_max_sparse MSE_max_sparse_test EN_Results_fin
