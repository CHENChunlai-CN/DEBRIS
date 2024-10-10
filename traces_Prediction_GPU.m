%This function is to predict intensity-time traces into pattern-time traces
%using CPU

function traces_Prediction_GPU (path,gamma_factor)

netname = 'Netv230712.mat';
load(netname); %% load net
sfileNames = dir(fullfile(path, 'S*.mat')); %% deal all S/s* .mat files

%% load data
for s=1:size(sfileNames,1)
    load(sfileNames(s).name);
    stepsize=1; % stepsize of fragment
    minI=2e4; % normalization:always 2e4 ,recommend value is 50%~70% x (ID+IA)
    Tracepreds={}; % record pattern traces.
    Probabilitypreds={}; % record probability of each categorie.

    %% prediction
    for a =1:numel(gamma_factor)
        factor = gamma_factor(1,a);
        for i=1:size(Traces,1)
            temptrace=Traces{i,1}';
            temptrace2 =temptrace;
            temptrace2(:,2)=(1/factor)*temptrace2(:,2); %% acceptor intensity / gamma_factor
            savename = ['C' num2str(factor) netname(1:end-4) sfileNames(s).name];
            frag={};
            for j=1:stepsize:(size(temptrace2,1)-9)
                frag(end+1,1)={(temptrace2(j:j+9,:)'/max(minI,mean(maxk(sum(temptrace2(j:j+9,:),2),3))))}; % normalized the intensity into [0,1]cfro prediction
            end

            PreClass=classify(net,frag,"ExecutionEnvironment","gpu");
            PreClass2=predict(net,frag,"ExecutionEnvironment","gpu");
            Probabilitypreds{i}=PreClass2;

            tempclass=str2double(cellstr(PreClass));
            tempdata=[temptrace2(1:end-9,:),tempclass];
            Tracepreds{i}=tempdata;
        end
        save(savename,'Traces','Tracepreds','Probabilitypreds');
        disp('done');
    end
end
% end