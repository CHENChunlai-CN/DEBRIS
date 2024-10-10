%{ Classify dynamically emrgying one- or two-color traces and output:
% 1. EventsInfo:record  information of all pairscol1: number of selected traces
    % col2: cat of the fragments
    % col3: frame of the event appear
    % col4: frame of the FRET disappear
    % col5: frame of the event disappear
    % col6:frame of the last event end
    % col7: appearing frames: frames before the events appear = col3-col6(last)
    % col8: dwell frames of the event = col5-col3+1
    % col9: FRET of the first one frame
    % col10: FRET of the last one frame
    % col11: average FRET of the first 3 frames
    % col12: average FRET of the last 3 frames
    % col13: average FRET of the total events
% 2. SyncM1:record FRET of each frame aroud events appear;1~131:31=b1,[31 131]
    % col1: order,31=frame of events start;
    % col2: intensity of donor
    % col3: intensity of acceptor
    % col4: FRET;
    % col5: dwell time of the events;
% 3. SyncM2:record FRET of each frame aroud events disappear;1~131:b2 = 100,[0 100]
    % col1: order,100=frame of events end;
    % col2: intensity of donor
    % col3: intensity of acceptor
    % col4: FRET;
    % col5: dwell time of the events;
%}

function dynamic_Traces_Classify (path,ColorNum,cross)

filenames = dir(fullfile(path,'C*.mat'));
offset = 7;% offset between intensity traces and pattern traces, dependent on length of training data.
appearframe=5; % reliable frame of 'donor / siganl appear' pattern.
bleachframe=5; % reliable frame of 'donor / siganl disappear' pattern.
mindA=3;  % reliable frame of 'acceptor disappear' pattern.
mindN=5;  % reliable frame of 'Junk' pattern.
mind0=2;  % reliable frame of 'Non-FRET' pattern.
window_size=4; %% window size of findchangepts

% parameters for filter,only traces that meet the filter criteria are recorded in SyncM1 and SyncM2.
FRETthreshold=0.1; % apparent FRET filter; -inf: no filter
lastingframe = 0;   % dwell frames filter; 0: no filter

% filenames cycle to deal with each file
for n =1:numel(filenames)
    filename=[filenames(n).name(end-13:end-4)]
    load(filenames(n).name,'Traces',"Tracepreds");
    PairMatrix={};   % record pairs within each trace
    events =0;       % count how many events
    EventsInfo=[];   % record all information of all selected paired events.
    SyncM_counts =0; % SyncM1/2 record SyncM_counts events
    SyncM1=[];       % record FRET of each frame within one event;1~131:31=b1,[31 131]
    SyncM2=[];       % record FRET of each frame within one event;1~131:b2 = 100,[0 100]
    allFRET=[];      % record FRET of each frame of all selected traces.
    histd = (-0.21:0.01:1.21)';
    signal = [histd, zeros(size(histd))]; %record frequencey counts of allFRET,range starts at [-0.21,1.21], binsize is 0.01.

    % traces cycle to get paired events within each trace
    j = 1;
    while j < numel(Traces)+1
        preclass = Tracepreds{j}(:,3)';
        temptrace = Traces{j}';
        result1=findContinuousFramesFunc(preclass,-3,appearframe); % find 'Signal/donor appear' pattern.
        result2=findContinuousFramesFunc(preclass,3,bleachframe);  % find 'Signal/donor disappear' pattern.
        Pair=findClosestPairsFunc(result1, result2); % pair a 'Signal/donor appear' pattern to a 'Signal/donor disappear' pattern.
        p_events =0; % count how many events within each trace

        ID = temptrace(:,1);
        IA = temptrace(:,2);
        IA = IA-cross*ID;
        fret = IA ./ (ID+IA);

        % Pairs cycle for classification of each pair
        for p=1:size(Pair,1)
            preclassM = Tracepreds{j}(Pair(p,1):Pair(p,2),3);
            if findSignalIndexFunc(preclassM,4,mindA)<numel(preclassM)&&... %% have acceptor bleach
                    findSignalIndexFunc(preclassM,100,mindN)>numel(preclassM)&&...
                    findSignalIndexFunc(preclassM,0,mind0)>findSignalIndexFunc(preclassM,4,mindA)&&...
                    findSignalIndexFunc(preclassM,-4,mindN)> numel(preclassM)
                % PairMatirx
                cat =2;
                Pair(p,3)=cat;
                tempsum1 = temptrace(:,2);
                tempsum = sum(Traces{j});
                b1 = findChangePointsFunc(tempsum,Pair(p,1),window_size,offset)+1;
                b2 = findChangePointsFunc(tempsum1,findSignalIndexFunc(preclassM,4,mindA)+Pair(p,1),window_size,offset); % acceptor belach
                b3 = findChangePointsFunc(temptrace(:,1),Pair(p,2),window_size,offset); % donor belach
                Pair(p,4:6)=[b1 b2 b3];

                % EventsInfo
                p_events = p_events+1;
                events = events+1;
                EventsInfo=eventsinfoAdd(EventsInfo,j,events,b1,b2,b3,p_events,cat,fret,temptrace,cross);
                % SyncM1,SyncM2
                if  EventsInfo(events,13)>FRETthreshold && EventsInfo(events,8)>lastingframe &&  (ColorNum==2)
                    SyncM_counts = SyncM_counts+1;
                    [SyncM1,SyncM2] = SyncAdd(SyncM1,SyncM2,b1,b2,temptrace,cross,SyncM_counts);

                end

            elseif  findSignalIndexFunc(preclassM,4,mindA)>numel(preclassM) &&... %% no acceptor bleach
                    findSignalIndexFunc(preclassM,100,mindN)>numel(preclassM)&&...
                    findSignalIndexFunc(preclassM,0,mind0)>numel(preclassM)&&...
                    findSignalIndexFunc(preclassM,-4,mindN)>numel(preclassM)
                % PairMatrix
                cat=1;
                Pair(p,3)=cat;
                tempsum = sum(Traces{j});
                b1 = findChangePointsFunc(tempsum,Pair(p,1),window_size,offset)+1;
                b2 = findChangePointsFunc(tempsum,Pair(p,2),window_size,offset);
                b3=b2;
                Pair(p,4:5)=[b1 b2];
                % EventsInfo
                p_events = p_events+1;
                events = events+1;
                EventsInfo=eventsinfoAdd(EventsInfo,j,events,b1,b2,b3,p_events,cat,fret,temptrace,cross);
                % SyncM1,SyncM2
                if  EventsInfo(events,13)>FRETthreshold && EventsInfo(events,8)>lastingframe &&  (ColorNum==2)
                    SyncM_counts = SyncM_counts+1;
                    [SyncM1,SyncM2] = SyncAdd(SyncM1,SyncM2,b1,b2,temptrace,cross,SyncM_counts);
                end
            else
                cat =5;
                Pair(p,3)=cat;
                Pair(p,4:5)=[0 0];
            end
            %get FRET histogram
            if  Pair(p,3) ~=5 && EventsInfo(events,13)>FRETthreshold && EventsInfo(events,8)>lastingframe && (ColorNum==2)
                fretl=floor(Pair(p,4:5));
                allFRET = [allFRET;fret(fretl(1):fretl(2),1)];
                histtemp = transpose(hist(fret(fretl(1):fretl(2),1), histd));
                signal(:, 2) = signal(:, 2) + histtemp(:,1);
            end
        end
        j = j+1;
        PairMatrix{end+1,1}=Pair;
    end
    % filter events that meet the criteria of total average FRET and dwell time
%     EventsInfoS=EventsInfo;
    EventsInfoS=EventsInfo(EventsInfo(:,13)>FRETthreshold&EventsInfo(:,8)>lastingframe,:);

%     savename = ['A' num2str(appearframe) 'B' num2str(bleachframe) 'N' num2str(mindN) 'L' num2str(lastingframe) 'F' num2str(FRETthreshold)];
    if ColorNum==2
        save(['a' filename 'SyncM1.txt'],'SyncM1','-ascii');
        save(['a' filename  'SyncM2.txt'],'SyncM2','-ascii');
        save(['a' filename  'allFRET.txt'],'allFRET','-ascii');
        save(['a' filename 'histplusFRET.txt'],'signal','-ascii');
    end
    save(filenames(n).name,'Traces','Tracepreds','PairMatrix','EventsInfoS');
    save(['a' filename  'EventsInfoS.txt'],'EventsInfoS','-ascii');
end

%% function
    function EventsInfo = eventsinfoAdd(EventsInfo,j,events,b1,b2,b3,p_events,cat,fret,temptrace,cross)
        EventsInfo(events,1) = j; % col1:number of traces
        EventsInfo(events,2) = cat;% col2:cat of the fragments
        EventsInfo(events,3) = b1;% col3:frame of the event appear
        EventsInfo(events,4) = b2;% col4:frame of the FRET disappear
        EventsInfo(events,5)=b3;% col5:frame of the event end
        if p_events == 1
            EventsInfo(events,6) = 0;% col6: frame of the last event end
            EventsInfo(events,7) = b1-0;% col7:appearing frame: time before the events apeear = col3-col6(last)
        else
            EventsInfo(events,6) = EventsInfo(events-1,5);
            EventsInfo(events,7) = b1-EventsInfo(events,6);
        end
        EventsInfo(events,8) = b2-b1;% col8:dwell frame of the event = col4--col3+1
        EventsInfo(events,9) = fret(b1,1);% col9: FRET of the first one frame
        EventsInfo(events,10) = fret(b2,1);% col10: FRET of the last one frame
        IDb = mean(temptrace(max(b1-5,1):b1-1,1));IAb = mean(temptrace(max(b1-5,1):b1-1,2));

        ID = mean(temptrace(b1:b1+3,1))-IDb;IA = mean(temptrace(b1:b1+3,2))-IAb;
        EventsInfo(events,11) =(IA-cross*ID)/(IA-cross*ID+ID);% col11: average FRET of the first 3 frames

        ID = mean(temptrace(b2-1:b2,1))-IDb;IA = mean(temptrace(b2-1:b2,2))-IAb;
        EventsInfo(events,12) =(IA-cross*ID)/(IA-cross*ID+ID);% col12: average FRET of the last 3 frames

        ID = mean(temptrace(b1:b2,1))-IDb;IA = mean(temptrace(b1:b2,2))-IAb;
        EventsInfo(events,13) =(IA-cross*ID)/(IA-cross*ID+ID);% col13: average FRET of the total event
    end

%% get SyncM information function
    function [SyncM1,SyncM2] = SyncAdd(SyncM1,SyncM2,b1,b2,temptrace,cross,SyncM_counts)
        start_index = 131*(SyncM_counts-1)+1;end_index = 131*SyncM_counts;
        IDb = mean(temptrace(max(b1-5,1):b1-1,1));IAb = mean(temptrace(max(b1-5,1):b1-1,2));
        SyncM= (-30:1:100)'; %order,position b1 at 31
        SyncM(:,2:5)=NaN;
        if 1<=b1 && b1<=31
            t1=1;t2=b1+100;
            indices = (31-b1+1):131;
        elseif 31<b1&&b1<size(temptrace,1)-100
            t1=b1-30;t2=b1+100;
            indices = 1:131;
        elseif b1>=size(temptrace,1)-100
            t1=b1-30;t2=size(temptrace,1);
            indices = 1:(size(temptrace,1)-b1+31);
        end
        SyncM(indices,2) = temptrace(t1:t2,1)-IDb; % intensity of donor
        SyncM(indices,3) = temptrace(t1:t2,2)-IAb; % intensity of acceptor
        SyncM(indices,4) = (SyncM(indices,3)-cross*SyncM(indices,2)) ./(SyncM(indices,2)+SyncM(indices,3)-cross*SyncM(indices,2)); % FRET
        dwelltime = zeros([size(indices,2),1]);dwelltime(dwelltime(:,1)==0,1) = b2-b1+1;
        SyncM(indices,5) = dwelltime; % dwell time of the evetns
        SyncM1(start_index:end_index,:) = SyncM;

        SyncM= (-100:1:30)'; %order,position b2 at 100
        SyncM(:,2:5)=NaN;
        if 1<=b2 && b2<=99
            t1=1;t2=b2+31;
            indices = (100-b2+1):131;
        elseif 99<b2&&b2<size(temptrace,1)-31
            t1=b2-99;t2=b2+31;
            indices = 1:131;
        elseif b2>=size(temptrace,1)-31
            t1=b2-99;t2=size(temptrace,1);
            indices = 1:(size(temptrace,1)-b2+100);
        end
        SyncM(indices,2) = temptrace(t1:t2,1)-IDb; % intensity of donor
        SyncM(indices,3) = temptrace(t1:t2,2)-IAb; % intensity of acceptor
        SyncM(indices,4) = (SyncM(indices,3)-cross*SyncM(indices,2)) ./(SyncM(indices,2)+SyncM(indices,3)-cross*SyncM(indices,2)); % FRET
        dwelltime = zeros([size(indices,2),1]);dwelltime(dwelltime(:,1)==0,1) =b2-b1+1;
        SyncM(indices,5) = dwelltime; %dwell time of the evetns
        SyncM2(start_index:end_index,:) = SyncM;
    end
end
