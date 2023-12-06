%% LASSO REGRESSION 

% Data entry
clear
clc
rng default
load Second_peak_US_county_transformed_data.mat

% Predictors
x = data_fin(:,2:end);
x_names = Varnames(2:end);

% Response variable
y = data_fin(:,1);

%% choosing the lambda value

x_norm = normalize(x); 
[~,FitInfo_scan] = lasso(x_norm,y);
lambda_vec = FitInfo_scan.Lambda;
disp(lambda_vec)

%% Parameters for cross validation

n_fold = 5; 
n_repart = 40; 
cv = cvpartition(y,'KFold',n_fold, 'Stratify',false); 

% Defining an empty vector for storing lambda values and model Mean Squared Error (MSE)
MSE_lambda_mat = [];

% index permutations in lambda_vec
lena_param = length(lambda_vec);
 
param_index_perm_vec = randperm(lena_param);
 
 %% Main code
 
 for index = param_index_perm_vec
     
    % Determining the value of lambda for a given index:
    lambda = lambda_vec(index);
    
    % Defining empty vectors for standard errors on the test and train sets:
    SE_vector_train = [];
    SE_vector_test = [];
    
    % For each lambda, the partitioning will be performed 40 times:
    for repart = 1:n_repart
        cnew = repartition(cv); 
        
        parfor i = 1:n_fold
            
        % Based on the cross-validation partition, we take the test and train indices
        index_train = find(cnew.test(i)==0);
        index_test = find(cnew.test(i));
        
        % We split the data into a test and train set:
        y_train = y(index_train);
        x_train = x(index_train,:);
        y_test = y(index_test);
        x_test = x(index_test,:);
        
        % We standardize the training data:
        mean_x_train = mean(x_train);
        std_x_train = std(x_train);
        x_train_norm = (x_train - mean_x_train)./std_x_train;
        
        % We standardize the test data based on the mean and std of the training set:
        x_test_norm = (x_test - mean_x_train )./std_x_train;
        
        % LASSO regression on the training set for a given lambda value
        [B_train,FitInfo_train] = lasso(x_train_norm, y_train, 'Lambda', lambda, 'PredictorNames', x_names);
       
        % Extracting coefficients from the regression, including the intercept (intersection with the y-axis)
        coef_train = B_train;
        coef0_train = FitInfo_train.Intercept;
        
        % Determining y-values from the model on the training set:
        yhat_train = x_train_norm*coef_train + coef0_train;
        
        % Determining the Mean Squared Error of the model on the training set:
        MSE_train_norm = sum( ( y_train - yhat_train ).^2 )/sum( ( y_train - mean(y_train) ).^2 );
        
        % Determining y-values on the test set:
        yhat_test = x_test_norm*coef_train + coef0_train;
        
        % Determining the Mean Squared Error of the model on the test set:
        MSE_test_norm = sum( ( y_test - yhat_test ).^2 )/sum( ( y_test - mean(y_test) ).^2 );
        
        % Filling the SE vector with data (added at each partition, for each fold)
        SE_vector_train = [ SE_vector_train MSE_train_norm ];
        SE_vector_test = [ SE_vector_test MSE_test_norm ];

        end
        
    end
    % Here, we have gone through all partitions for one lambda, so we need to determine the mean squared error (MSE) based on SE (there are 5x40 = 200 of them):
    MSE_train = mean(SE_vector_train); 
    MSE_test = mean(SE_vector_test);
    
    % Standard errors of the mean squared error:
    sterr_MSE_train = 2*std(SE_vector_train)/sqrt(length(SE_vector_train));
    sterr_MSE_test = 2*std(SE_vector_test)/sqrt(length(SE_vector_test));

    % Filling in the MSE lambda matrix for a given lambda value
    MSE_lambda_mat = [MSE_lambda_mat [lambda; MSE_train; sterr_MSE_train; MSE_test; sterr_MSE_test]];
 end
 
 

 %% Selecting the best model (the model with the lowest MSE)
 
%  Selecting the the model with the lowest MSE
[MSE_test_min, index_min] = min(MSE_lambda_mat(4,:));
% Determining its standard error
sterr_MSE_test_min = MSE_lambda_mat(5, index_min);
% Determining lambda for the minimum MSE model:
lambda_min = MSE_lambda_mat( 1 , index_min );


%% Selecting all models within 1 standard error of the minimum MSE

% The range of MSE we are looking for:
MSE_test_min_err = MSE_test_min + sterr_MSE_test_min;
% We are looking for models with MSE within 1 standard error of the minimum MSE:
index_min_all = find( MSE_lambda_mat( 4 , : ) < MSE_test_min_err );
% We extract the lambda values of those models:
lambda_min_all = MSE_lambda_mat( 1 , index_min_all );
% We find the maximum lambda = SPARSEST MODEL (model with the fewest retained parameters)
lambda_min_all_max = max( lambda_min_all );
%% 
% LASSO regression with lambda_min_all_max, on the entire set of standardized data:

[ B , FitInfo ] = lasso( x_norm , y , 'Lambda' , lambda_min_all_max , 'PredictorNames' , x_names );

ModelPredictors = FitInfo.PredictorNames(B(:)~=0);

coef = B(B(:)~=0);

coef0 = FitInfo.Intercept;

yhat = x_norm*B + coef0;

R_square = 1 - ( sum( ( y - yhat ).^2 )/sum( ( y - mean(y) ).^2 ) );

%% Tabular representation of the results

% Koeficijenti_tabela = [coef0; coef];
% Prediktori_tabela = [{'Intercept'}, ModelPredictors];
% % LASSO_Results = array2table(Koeficijenti_tabela, 'RowNames', Prediktori_tabela, 'VariableNames' {'Estimate'});
% LASSO_Results = array2table(Koeficijenti_tabela, 'RowNames',Prediktori_tabela, 'VariableNames', {'Estimate'}) ;
% disp("LASSO REGRESSION, ROUND 1 RESULTS")
% disp(LASSO_Results)
% 
% fprintf('lambda = %.2f \nmin MSE = %.4f , SE min MSE = %.6f\n',... lambda_min,MSE_test_min, sterr_MSE_test_min);
% 
% fprintf('R_square = %.6f \n', R_square);

%% Graphical representation

% Predictors_spaced = replace(ModelPredictors,"_"," ");
figure
cat = categorical(ModelPredictors);
cat = reordercats(cat, ModelPredictors);
BFC = [26/255,152/255,80/255];
BEC = [0/255,104/255,55/255];
figure
bar(cat, coef,'FaceColor', BFC,'EdgeColor',BEC,'LineWidth',1.5);
ylabel('Model coefficients')
title('Lasso regression')

%% Data preparation for the second round of regression (relaxed)

KeepIndex = find(B(:)~=0); 
x = x(:,KeepIndex);
x_names = x_names(KeepIndex);

% Second round

clearvars -except x y x_names

[ ~ , FitInfo_scan ] = lasso( normalize(x) , y );
lambda_vec = FitInfo_scan.Lambda;
n_fold = 5;
n_repart = 40;
cv = cvpartition(y,'KFold',n_fold,'Stratify',false) ;

MSE_lambda_mat = [] ;

lena_param = length( lambda_vec ) ;

param_index_perm_vec = randperm( lena_param ) ;

for index = param_index_perm_vec
    
    lambda = lambda_vec(index) ;
    SE_vector_train = [] ;
    SE_vector_test = [] ;
    
    for repart = 1:n_repart
        cnew = repartition( cv ) ;
        
        parfor i = 1:n_fold
            
            index_train = find( cnew.test(i)==0 ) ;
            index_test = find( cnew.test(i) ) ;
            y_train = y( index_train ) ;
            x_train = x( index_train , : ) ;
            mean_x_train = mean( x_train ) ;
            std_x_train = std( x_train ) ;
            x_train_norm = ( x_train - mean_x_train )./std_x_train ;
            y_test = y( index_test ) ;
            x_test = x( index_test,:);
            x_test_norm = ( x_test - mean_x_train )./std_x_train ;
            
            [ B_train , FitInfo_train ] = lasso( x_train_norm , y_train , 'Lambda', lambda, 'PredictorNames', x_names);
            coef_train = B_train ;
            coef0_train = FitInfo_train.Intercept ;
            yhat_train = x_train_norm*coef_train + coef0_train ;
            MSE_train_norm = sum( ( y_train - yhat_train ).^2 )/sum( ( y_train - mean(y_train) ).^2 );
            yhat_test = x_test_norm*coef_train + coef0_train ;
            MSE_test_norm = sum( ( y_test - yhat_test ).^2 )/sum( ( y_test - mean(y_test) ).^2 );
            
            SE_vector_train = [ SE_vector_train MSE_train_norm ] ;
            SE_vector_test = [ SE_vector_test MSE_test_norm ] ;
        end
    end
    MSE_train = mean( SE_vector_train ) ;
    MSE_test = mean( SE_vector_test ) ;
    sterr_MSE_train = 2*std( SE_vector_train )/sqrt( length( SE_vector_train ) ) ;
    sterr_MSE_test = 2*std( SE_vector_test )/sqrt( length( SE_vector_test ) ) ;
    MSE_lambda_mat = [ MSE_lambda_mat [ lambda ; MSE_train ; sterr_MSE_train ; MSE_test; sterr_MSE_test]];
end
        
% % Selection of the best model
[ MSE_test_min , index_min ] = min( MSE_lambda_mat( 4 , : ) ) ;
sterr_MSE_test_min = MSE_lambda_mat( 5 , index_min ) ;
lambda_min = MSE_lambda_mat( 1 , index_min ) ;

% % Selection of all models within 1 standard error of the min MSE model
MSE_test_min_err = MSE_test_min + sterr_MSE_test_min ;
index_min_all = find( MSE_lambda_mat( 4 , : ) < MSE_test_min_err ) ;
lambda_min_all = MSE_lambda_mat( 1 , index_min_all ) ;
lambda_min_all_median = median( lambda_min_all ) ;
lambda_min_all_max = max( lambda_min_all ) ;
norm_x = normalize(x) ;

% LASSO regression with lambda_min_all_max on the entire set of standardized data:
[ B_fin , FitInfo_fin ] = lasso( norm_x , y , 'Lambda' , lambda_min_all_max , 'PredictorNames', x_names);
ModelPredictors = FitInfo_fin.PredictorNames(B_fin(:)~=0) ;
coef = B_fin(B_fin(:)~=0) ;
coef0 = FitInfo_fin.Intercept ;
yhat = norm_x*B_fin + coef0 ;
R_square = 1 - ( sum( ( y - yhat ).^2 )/sum( ( y - mean(y) ).^2 ) ) ;

%% Tabular representation of the results

Koeficijenti_tabela = [coef0; coef];
Prediktori_tabela = [{'Intercept'}, ModelPredictors];
LASSO_Results_fin = array2table(Koeficijenti_tabela, 'RowNames',Prediktori_tabela, 'VariableName', {'Estimate'});
disp("RELAXED LASSO REGRESSION, ROUND 2 RESULTS")
disp(LASSO_Results_fin)

fprintf('lambda = %.2f \nmin MSE = %.4f , SE min MSE = %.6f\n',...
lambda_min,MSE_test_min, sterr_MSE_test_min);

fprintf('R_square = %.6f \n', R_square);

%% Graphical representation (bar)

% Predictors_spaced = replace(ModelPredictors,"_"," ");
figure
cat = categorical(ModelPredictors);
cat = reordercats(cat, ModelPredictors);
BFC = [26/255,152/255,80/255];
BEC = [0/255,104/255,55/255];
figure
bar(cat, coef,'FaceColor', BFC,'EdgeColor',BEC,'LineWidth',1.5);
ylabel('Model coefficients')
title('Relaxed Lasso regression')

save Lasso_sparse_Round_1 B_fin FitInfo_fin x y x_names MSE_lambda_mat lambda_min MSE_test_min LASSO_Results_fin

