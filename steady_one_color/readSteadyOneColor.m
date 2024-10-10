clear
fullpath = mfilename('fullpath');
[path,name] =fileparts(fullpath);
cd(path);
load('C1Net0712I8C3s1102_0009.mat');
label = load('s1102_0009_label.mat','Tracecat_label').Tracecat_label;

i=1;
while i <= numel(Traces)
    temptrace = Traces{i,1}';
    preclass = Tracepreds{i}(:,3)';
    preclass(preclass == -3 | preclass ==-4) =100;
    cat = zeros(size(preclass));
    cat(1,find(preclass(1,:)==100))=1;
    cat(1,find(preclass(1,:)==3))=3;
    cat(1,find(preclass(1,:)==1))=4;cat(1,find(preclass(1,:)==2))=4;
    cat(1,find(preclass(1,:)==0))=2;

    hdl3=gcf;
    clf;
    figure(hdl3);
    subplot(2,1,1)
    plot(1:size(temptrace,1), temptrace(:,1),'g','Marker','.','MarkerSize',8);
    hold on
    title(sprintf('No.%d of %d \n DEBRIS: %d / %d \n Expert : %d / %d ', ...
        i,numel(Traces),Tracecat_frag(i,1),Tracecat_frag(i,2),label(i,1),label(i,2)),'FontSize',12);
    grid on
    zoom on

    subplot(2,1,2)
    plot(1:size(cat,2), cat,'black','Marker','.','MarkerSize',12);
    set(gca,'YTick',[1 2 3 4]);
    set(gca,'YTickLabel',{'Junk','Non-Sig','Sdis','Sig'})
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