%%This function is used to find pairs of donor/event appear and donor/event disappear
function result = findClosestPairsFunc(A, B)
result = [];
last_match_a = -inf;  %The initial value of a for the last match is set to negative infinity

for i = 1:length(B)
    min_difference = inf;
    best_match_a = 0;
    best_match_b = 0;

    for j = 1:length(A)
        if A(j) < B(i) && A(j) > last_match_a
            difference = B(i) - A(j);
            if difference < min_difference
                min_difference = difference;
                best_match_a = A(j);
                best_match_b = B(i);
            end
        elseif A(j) >= B(i)
            break; % Because A is sorted, subsequent elements will not be smaller
        end
    end

    if best_match_a > 0 && best_match_b > 0
        result = [result; best_match_a, best_match_b];
        last_match_a = best_match_a;  % Update the last matching a
    end
end
end