%%for the calculation of the gamma factor and spectral crosstalk based on 'A photobleaaching' classification.
clear
path = 'F:\shuqi\DEBRIS\DEBRIS_upload\all_data\Steady_two_color';
cd(path)
files = dir(fullfile(path,'*Netv230712*.mat'));
for f =1:numel(files)
    filename = files(f).name;
    load(filename);
    gamma_factor=[];
    cross_talk=[];
    for i=1:numel(Traces)
        cat = Tracecat_frag(i,1);
        if cat ==2
            bleach_acceptor =Tracecat_frag(i,2);
            intensity =Traces{i,1}';
            intensity=medfilt2(intensity,[3,1]);
            acceptor_change = mean(intensity(max(1,bleach_acceptor-4):bleach_acceptor-2,2))-...
                mean(intensity(bleach_acceptor+2:min(size(intensity,1),bleach_acceptor+4),2));
            donor_change =  mean(intensity(bleach_acceptor+2:min(size(intensity,1),bleach_acceptor+4),1))-...
                mean(intensity(max(1,bleach_acceptor-4):bleach_acceptor-2,1));
            cross =  mean(intensity(bleach_acceptor+2:min(size(intensity,1),bleach_acceptor+4),2))/...
                mean(intensity(bleach_acceptor+2:min(size(intensity,1),bleach_acceptor+4),1));
            gamma_factor(end+1,1) = acceptor_change/donor_change;
            cross_talk(end+1,1)=cross;
        end
    end
    log_gamma_factor = log10(gamma_factor(gamma_factor>0));
    data = log_gamma_factor;
    gaussianModel = fittype('a * exp(-((x - mu) / w) ^ 2)', ...
        'independent', 'x', 'dependent', 'y');
    clf;
    h = histogram(data, 'Normalization', 'pdf', 'BinWidth', 0.05);
    counts = h.Values;
    binEdges = h.BinEdges;
    binCenters = (binEdges(1:end-1) + binEdges(2:end)) / 2;
    initialParams = [1, 0, 1]; % a、mu、w
    [fitResult, gof] = fit(binCenters', counts', gaussianModel, 'StartPoint', initialParams);
%     %plot pf fitting
%     x = linspace(min(data), max(data), 1000);
%     y = feval(fitResult, x);
% %     figure;
% %     h = histogram(data, 'Normalization', 'pdf', 'BinWidth', 0.05);
%     hold on;
%     plot(x, y, 'r-', 'LineWidth', 2);
%     legend('Counts', 'Gaussian Fit');
%     title(['Gaussian Fit of ' filename(end-13:end-4)]);
%     hold off
    if size(find(Tracecat_frag(:,1) == 2),1) < size(find(Tracecat_frag(:,1) ~= 5),1)*0.25
        fprintf('Note: too few traces of acceptor photobleaching, unreliable gamma factor\n');
    end
   fprintf(['gamma factor of ' filename(end-13:end-4) ':%f\n'],power(10,fitResult.mu));
    fprintf(['cross talk of ' filename(end-13:end-4) ':%f\n\n'],mean(cross_talk));
end
