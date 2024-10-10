%This function is used to classify steady two-color traces and output histogram of FRET distribution:
%output:
%1. 'C1Net0712I8C3Sxxx_xxxxallFRET.txt': record FRET of each frame of all selected traces.
%2. 'C1Net0712I8C3Sxxx_xxxxhistFRETplus.txt': histogram of FRET from allFRET.txt files,range starts at [-0.21,1.21], binsize is 0.01.
%3. 'C1Net0712I8C3Sxxx_xxxx.jpg': visible FRET histogram for the first column and second column of histFRETplus.txt file.

function steady_TwoColor_Traces_Classify(path,cross)

filenames = dir(fullfile(path,'C*.mat')); % get all Net predicted files

offset=7; % offset between intensity traces and pattern traces, dependent on length of training data.
mindD=3;  % reliable frame of 'donor disappear' pattern.
mindA=3;  % reliable frame of 'acceptor disappear' pattern.
mindN=5;  % reliable frame of 'Junk' pattern.
mind0=2;  % reliable frame of 'Non-FRET' pattern.
Ratiothreshold =2; % tolerabel differencee of minimum and maximum intensity (both donor and acceptor) before photobleaching.
window_size =4; %% window size of findchangepts

for n =1:numel(filenames)
    load(filenames(n).name);
    savename = filenames(n).name(1:end-4);
    Tracecat_frag = zeros(2, size(Tracepreds,2)); % record categories of each trace; 5:junk; 1: donor bleached;2: acceptoe bleached   
    
    allFRET=[]; % record FRET of each frame of all selected traces.
    histd = (-0.21:0.01:1.21)';
    signal = [histd, zeros(size(histd))]; %record frequencey counts of allFRET,range starts at [-0.21,1.21], binsize is 0.01.

    for j = 1:size(Tracepreds,2)
        PreClassM = Tracepreds{1,j}(:,3);
        PreClassM(PreClassM == -3 | PreClassM == -4) = 100;
        temptrace = Traces{j,1}';
        temptrace1 = temptrace(:,1)+temptrace(:,2);
        temptrace1=medfilt1(temptrace1,9); %%smooth of trace

        % classification rules based on paper's criteria
        if findSignalIndexFunc(PreClassM,3,mindD) <numel(PreClassM)
            if findSignalIndexFunc(PreClassM,4,mindA) <numel(PreClassM)
                [startA,durationA] = findSignalIndexFunc(PreClassM,4,mindA);
                [startD,durationD] = findSignalIndexFunc(PreClassM,3,mindD);
                changeA=findChangePointsFunc(Traces{j}(2,:),startA,window_size,offset);
                changeD=findChangePointsFunc(sum(Traces{j}),startD,window_size,offset);
                if  findSignalIndexFunc(PreClassM,3,mindD) > findSignalIndexFunc(PreClassM,4,mindA) &&...
                        findSignalIndexFunc(PreClassM,4,mindA) < findSignalIndexFunc(PreClassM,100,mindN)&&...
                        findSignalIndexFunc(PreClassM,4,mindA) < findSignalIndexFunc(PreClassM,-3,mindN)&&...
                        findSignalIndexFunc(PreClassM,4,mindA) < findSignalIndexFunc(PreClassM,-4,mindN)&&...
                        findSignalIndexFunc(PreClassM,3,mindD) < findSignalIndexFunc(PreClassM,100,mindN)&&...
                        findSignalIndexFunc(PreClassM,3,mindD) < findSignalIndexFunc(PreClassM,-3,mindN)&&...
                        findSignalIndexFunc(PreClassM,3,mindD) < findSignalIndexFunc(PreClassM,-4,mindN)&&...
                        findSignalIndexFunc(PreClassM,4,mindA) < findSignalIndexFunc(PreClassM,0,mind0)&&...
                        findSignalIndexFunc(PreClassM((startA+durationA):startD,:),4,mindA) > numel(PreClassM) &&...% no more 4 between first 4 and first3
                        max(temptrace1(2:(changeA-1),1)) ./ min(temptrace1(1:(changeA-1),1)) <= Ratiothreshold && ...
                        max(temptrace1((changeA+1):(max(changeD-2,changeA+1)+1),1)) ./ min(temptrace1((changeA+1):(max(changeD-2,changeA+1)+1),1)) <= Ratiothreshold

                    Tracecat_frag(1,j) = 2;% A bleach
                    Tracecat_frag(2,j) = changeA;

                elseif findSignalIndexFunc(PreClassM,3,mindD) < findSignalIndexFunc(PreClassM,4,mindA)&&...
                        findSignalIndexFunc(PreClassM,3,mindD) < findSignalIndexFunc(PreClassM,100,mindN)&&...
                        findSignalIndexFunc(PreClassM,3,mindD) < findSignalIndexFunc(PreClassM,-3,mindN)&&...
                        findSignalIndexFunc(PreClassM,3,mindD) < findSignalIndexFunc(PreClassM,-4,mindN)&&...
                        findSignalIndexFunc(PreClassM,3,mindD) < findSignalIndexFunc(PreClassM,0,mind0)&&...
                        max(temptrace1(2:(changeD-1),1)) ./ min(temptrace1(2:(changeD-1),1)) <= Ratiothreshold

                    Tracecat_frag(1,j) = 1;% D bleach
                    tempsum = sum(Traces{j});
                    Tracecat_frag(2,j) = changeD;
                else
                    Tracecat_frag(1,j) = 5;% junk
                    Tracecat_frag(2,j) = 0;
                end
            else
                [startD,durationD] = findSignalIndexFunc(PreClassM,3,mindD);
                changeD=findChangePointsFunc(sum(Traces{j}),startD,window_size,offset);
                if findSignalIndexFunc(PreClassM,3,mindD) < findSignalIndexFunc(PreClassM,100,mindN) &&...
                        findSignalIndexFunc(PreClassM,3,mindD) < findSignalIndexFunc(PreClassM,-3,mindN)&&...
                        findSignalIndexFunc(PreClassM,3,mindD) < findSignalIndexFunc(PreClassM,-4,mindN)&&...
                        findSignalIndexFunc(PreClassM,3,mindD) < findSignalIndexFunc(PreClassM,0,mind0)&&...)%%%%% 增加0的判据
                        max(temptrace1(2:(changeD-1),1)) ./ min(temptrace1(2:(changeD-1),1)) <= Ratiothreshold

                    Tracecat_frag(1,j) = 1 ; % D bleach
                    tempsum = sum(Traces{j});
                    Tracecat_frag(2,j) = changeD;
                else
                    Tracecat_frag(1,j) = 5 ; % junk
                    Tracecat_frag(2,j) = 0;
                end
            end
        else
            Tracecat_frag(1,j) = 5; % junk
            Tracecat_frag(2,j) = 0;
        end
        bleachFrame=floor(Tracecat_frag(2,j));

        % FRET and frequency counts of FRET
        ID=temptrace(:,1);
        IA=temptrace(:,2);
        IA=IA-ID.*cross;
        fret=IA./(IA+ID);
        allFRET = [allFRET;fret(1:bleachFrame)];
        histtemp = transpose(hist(fret(1:bleachFrame), histd));
        signal(:, 2) = signal(:, 2) + histtemp(:,1);
    end

    Tracecat_frag = Tracecat_frag';
    save([savename 'allFRET.txt'],'allFRET','-ascii');
    save([savename 'histplusFRET.txt'],'signal','-ascii');
    save([savename '.mat'],'Tracecat_frag','Tracepreds','Traces');

    % hitogram of the sample
    clf;
    plot(signal(:,1),signal(:,2),'r','LineWidth', 3);
    xlabel('FRET');
%     ylabel('Counts');
    title([savename 'D' num2str(mindD) num2str(mindA) num2str(mindN) num2str(mind0)], 'FontSize', 10);
    saveas(gcf,[savename '.jpg']);
end
end



