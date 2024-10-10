%This function is used to find the first index that meet conditions in
%pattern-time trace
function [startIdx, duration] = findSignalIndexFunc(PreClassM, Pattern, minDuration)

indices = find(PreClassM == Pattern);
startIdx = 0;
duration = 0;

if minDuration == 0
    startIdx = inf;
    duration = 0;
    return;
end

for i = 1:length(indices)
    idx = indices(i);
    if startIdx == 0
        startIdx = idx;
        duration = 1;
    elseif idx == startIdx + duration
        duration = duration + 1;
    else
        if duration >= minDuration
            return;
        else
            startIdx = idx;
            duration = 1;
        end
    end
end

if duration >= minDuration
    return;
end

startIdx = inf;
duration = 0;
end
