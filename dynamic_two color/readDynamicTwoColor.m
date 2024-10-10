clear
fullpath = mfilename('fullpath');
[path,name] =fileparts(fullpath);
cd(path);
load ('C1Netv230712S1501_1000.mat');
j=1;
while j < numel(PairMatrix)+1
    j
    preclass = Tracepreds{j}(:,3)';
    temptrace = Traces{j}';
    cat = zeros(size(preclass));
    cat(1,find(preclass(1,:)==100))=1;cat(1,find(preclass(1,:)==-4))=1;
    cat(1,find(preclass(1,:)==3))=3;
    cat(1,find(preclass(1,:)==4))=4;
    cat(1,find(preclass(1,:)==-3))=5;
    cat(1,find(preclass(1,:)==1))=6;cat(1,find(preclass(1,:)==2))=6;
    cat(1,find(preclass(1,:)==0))=2;

    
        %see Traces one by one
        hdl3=gcf;
        clf;
        figure(hdl3);

        subplot(2,1,1)
        redpart=[];
        plot(1:size(temptrace,1), temptrace(:,2),'r','Marker','.','MarkerSize',8);
        hold on
        plot(1:size(temptrace,1), temptrace(:,1),'g','Marker','.','MarkerSize',8);
        ylabel('Intensity');
        hold on

        for i =1: size(PairMatrix{j,1},1)
            x_range = PairMatrix{j,1}(i,4):1: PairMatrix{j,1}(i,5);
            y = max(max(temptrace(:,:)))+min(min(temptrace(:,:)));
            y_range=zeros(1,size(x_range,2));
            if PairMatrix{j,1}(i,3) == 1
                line(x_range,y_range,'Color',"red",'LineWidth',10,'Marker','.','MarkerSize',8)
            elseif PairMatrix{j,1}(i,3) == 2
                line(x_range,y_range,'Color',"blue",'LineWidth',10,'Marker','.','MarkerSize',8)
            end
            redpart = [redpart,PairMatrix{j,1}(i,4):1: PairMatrix{j,1}(i,5)];
        end
        x_remaining = setdiff(1:size(temptrace,1),redpart);
        y_range=zeros(1,size(x_remaining,2));
        line(x_remaining, y_range, 'Color', 'black', 'LineWidth', 1,'Marker','.','MarkerSize',8);
        title(sprintf('No.%d of %d molecules',j,numel(Traces)),'FontSize',15);
        grid on
        zoom on

       subplot(2,1,2)
        plot(1:size(cat,2), cat,'black','Marker','.','MarkerSize',8);
        set(gca,'YTick',[1 2 3 4 5 6]);
        set(gca,'YTickLabel',{'Junk','Non-FRET','Ddis','Adis','Dapp','FRET'})
        ylabel('Pattern');
        grid on;
        zoom on;

        reply=input('Press Enter to continue, "f" for fret, "c" for co-locol, "b" to go back, "q" to quit: ','s');
        if isempty(reply)  % presses 'Enter' to continue to the next image
            j = j + 1;
        elseif strcmp(reply, 'b') && j > 1  % presses 'b' to return to othe previous image
            j = j - 1;
        elseif strcmp(reply, 'q')  %presses 'q' to exit
            break;
        end
end