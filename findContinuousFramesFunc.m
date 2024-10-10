%%Tihs function is used to find a column of data that lasts for a specified number of 
% frames with a specified number of numbers, and outputs a matrix of coordinates that meets the requirements
function result = findContinuousFramesFunc(data, target_number, num_frames)
result = [];
current_frames = 0;

for i = 1:length(data)
    if data(i) == target_number
        current_frames = current_frames + 1;
        if current_frames == 1
            start_frame = i;
        end
        if current_frames >= num_frames
            if isempty(result) || start_frame ~= result(end)
                result = [result; start_frame];
            end
        end
    else
        current_frames = 0;
    end
end
end