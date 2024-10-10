%This function is used to find the significant change points of intensity

function change_idx = findChangePointsFunc(tempsum, index_range, window_size,w_offset)
if (index_range + w_offset)>length(tempsum)
    index_range = length(tempsum);
else
    index_range = index_range+w_offset;
end

start_index = index_range - window_size;
end_index = index_range + window_size;

if start_index < 1
    start_index = 1;
end

if end_index > length(tempsum)
    end_index = length(tempsum);
end
windowed_tempsum = tempsum(start_index:end_index);
change_points = findchangepts(windowed_tempsum)-1;
change_idx = change_points + start_index - 1;

if ~isempty(change_points)
    change_idx = change_points + start_index - 1;
else
    % If no change points are found, set the selected index to 0.
    change_idx = 0;
end
end
