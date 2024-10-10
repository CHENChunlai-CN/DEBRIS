%This function is used to classify steady one-color traces and output photobleaching information:
%output(aBleachS1101_0000.txt = bleachInfo: record bleach information in bleachInfo)
    % col1: Number of selected traces
    % col2: bleach frame
    % col3: mean intensity before bleach
    % col4: total intensity before bleach
    % col5: standard deviation of intensity before bleach
    % col6: SNR=S/N = col3/col5;

function  steady_OneColor_Traces_Classify(path)   
filenames = dir(fullfile(path,'C*.mat')); % get all Net predicted files

offset = 7; % offset between intensity traces and pattern traces, dependent on length of training data.
mindD = 3;  % reliable frame of 'Sigal disappear' pattern.
mindN = 5;  % reliablen frame of 'Junk signal' pattern.
Ratiothreshold=2.5; % tolerabel differencee of minimum and maximum intensity before photobleaching.
window_size =4; % window size of findchangepts

for n=1:numel(filenames)
    filename = filenames(n).name;
    load(filename);
    bleachInfo = [];
    count =0;
    Tracecat_frag=[]; % record categories of each trace; 5:junk; 1: Selected
        for j =1: numel(Traces)
        temptrace = Traces{j,1}';
        temptrace1=medfilt1(temptrace(:,1),5); %smooth of trace
        preclass = Tracepreds{1,j}(:,3);
        preclassM = preclass;
        preclassM(preclassM == -3 | preclassM == -4) = 100;
        [startD,durationD] = findSignalIndexFunc(preclassM,3,mindD);
        changeD=findChangePointsFunc(temptrace(:,1),startD,window_size,offset);
        if findSignalIndexFunc(preclassM,3,mindD)< numel(preclassM)&&...
                findSignalIndexFunc(preclassM,3,mindD)< findSignalIndexFunc(preclassM,100,mindN)&&...
                max(temptrace1(2:(changeD-1),1)) ./ min(temptrace1(2:(changeD-1),1))<= Ratiothreshold &&...
                findSignalIndexFunc(preclassM,100,1) >= 5 && (changeD-1)>=10

            count = count+1;
            Tracecat_frag(j,1) = 1;
            Tracecat_frag(j,2) = changeD;
            bleachInfo(count,1) =j;
            bleachInfo(count,2) = changeD;
            bleachInfo(count,3) = mean(temptrace(1:bleachInfo(count,2),1));
            bleachInfo(count,4) =sum(temptrace(1:bleachInfo(count,2),1));
            bleachInfo(count,5) = std(temptrace(1:bleachInfo(count,2),1));
            bleachInfo(count,6) = bleachInfo(count,3)/bleachInfo(count,5);
        else
            Tracecat_frag(j,1) = 5;
            Tracecat_frag(j,2) = 0;
        end
    end
%     savename = [filename(end-13:end-4) 'D' num2str(mindD) num2str(mindN) 'R' num2str(Ratiothreshold)];
    save(filename,'bleachInfo','Traces','Tracepreds','bleachInfo','Tracecat_frag');
    save(['aBleach' filename(end-13:end-4) '.txt'],'bleachInfo','-ascii');
end