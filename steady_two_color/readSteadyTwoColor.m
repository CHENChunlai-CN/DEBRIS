clear
fullpath = mfilename('fullpath');
[path,name] =fileparts(fullpath);
cd(path);
load('C1Net0712I8C3s0101_0000.mat');
label1 = load('s0101_0000_label1.mat','Tracecat_label').Tracecat_label;
label2 = load('s0101_0000_label2.mat','Tracecat_label').Tracecat_label;
Alex=1;

i=1;
while i <= numel(Traces)
    temptrace = Traces{i,1}';
    preclass = Tracepreds{i}(:,3)';
    preclass(preclass == -3 | preclass ==-4) =100;
    cat = zeros(size(preclass));
    cat(1,find(preclass(1,:)==100))=1;
    cat(1,find(preclass(1,:)==4))=4;
    cat(1,find(preclass(1,:)==3))=3;
    cat(1,find(preclass(1,:)==1))=5;cat(1,find(preclass(1,:)==2))=5;
    cat(1,find(preclass(1,:)==0))=2;

    if Alex
        temptrace = temptrace(1:floor(size(temptrace,1)/2),:);
    end

    if label1(i,1) == 2
        ilabel1 = label1(i,3);
    else
        ilabel1 = label1(i,2);
    end
    if label2(i,1) == 2
        ilabel2 = label2(i,3);
    else
        ilabel2 = label2(i,2);
    end

    hdl3=gcf;
    clf;
    figure(hdl3);
    subplot(2,1,1)
    plot(1:size(temptrace,1), temptrace(:,1),'g','Marker','.','MarkerSize',8);
    hold on
    plot(1:size(temptrace,1), temptrace(:,2),'r','Marker','.','MarkerSize',8);
    ylabel('Intensity');
    xlim([1,size(temptrace,1)]);
    hold on
    title(sprintf('No.%d of %d \n DEBRIS: %d / %d \n Expert #1: %d / %d \n Expert #2: %d / %d', ...
        i,numel(Traces),Tracecat_frag(i,1),Tracecat_frag(i,2),label1(i,1),ilabel1,label2(i,1),ilabel2),'FontSize',12);
    grid on
    zoom on

    subplot(2,1,2)
    plot(1:size(cat,2), cat,'black','Marker','.','MarkerSize',12);
    xlim([1,size(temptrace,1)]);
    set(gca,'YTick',[1 2 3 4 5]);
    set(gca,'YTickLabel',{'Junk','Non-FRET','Ddis','Adis','FRET'});
    ylabel('Pattern');
    grid on
    zoom on

    reply=input('Press Enter to continue, "b" to go back, "q" to quit: ','s');
    if isempty(reply)  % presses 'Enter' to continue to the next image
        i = i + 1;
    elseif strcmp(reply, 'b') && i > 1  % presses 'b' to return to othe previous image
        i = i - 2;
    elseif strcmp(reply, 'q')  % presses 'q' to exit
        break;
    end
end