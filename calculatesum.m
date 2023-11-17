% -1 -> bust
% n -> current sum
function result = calculatesum(cards)
    result = sum(cards);
    % if the user has an ace
    if ismember(1, cards) && (result + 10) < 21
        result = sum(cards) + 10;
    end
    if result > 21
        result = -1;
    end
end