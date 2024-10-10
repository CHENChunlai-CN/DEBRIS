% % path: the name of the folder contains ‘Sxxx_xxxx.mat’ and ‘Netv230712.mat’ files.
% attention: only recognise and handle Sxxxx_xxxx folders;see user manual for more information input and output parameters.
clear
path = 'F:\shuqi\DEBRIS\Response_related_test\gamma_factor_test\1';
cd(path);
cross = 0; % A correction factor to account for the cross-talk of donor emission into the acceptor detection channel
gamma_factor=[1];% recommended value =1 ;gamma_factor = intensity_change_of_acceptor / intensity_change_of_donor
ColorNum=1;% 1 for one-color trace and 2 for two-color trace；
%% Predict each Sxxx_xxxx .mat file using Netv230712.
traces_Prediction_GPU(path,gamma_factor) 
% traces_Prediction_CPU(path,gamma_factor) 
%% Classify all predicted  Sxxx_xxxx .mat file and output corresponding FRET information
steady_TwoColor_Traces_Classify(path,cross)   
%% Classify all predicted  Sxxx_xxxx .mat file and output events related information.
% dynamic_Traces_Classify(path,ColorNum,cross)
%% Classify all predicted  Sxxx_xxxx .mat file and output photobleaching related information.
% steady_OneColor_Traces_Classify(path)
