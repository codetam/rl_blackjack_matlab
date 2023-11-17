% -1 -> lose
% 0 -> tie
% 1 -> win
function [dealer_cards, deck, cards_out, result] = dealerturn(dealer_cards, player_cards, deck, cards_out)
    result = 0;
    while result > -1 && result < 17
        [dealer_cards, deck, cards_out, result] = hit(dealer_cards,deck,cards_out);
    end
    % dealer has not busted
    if result > -1
        player_sum = calculatesum(arrayfun(@getcardnum, player_cards));
        if result > player_sum
            result = -1;
        elseif result == player_sum
            result = 0;
        else
            result = 1;
        end
    % dealer has busted, player has won
    else
        result = 1;
    end
end