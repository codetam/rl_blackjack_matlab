function [player_cards, deck, cards_out, result] = hit(player_cards, deck, cards_out)
    % Adds the drawn card to cards_out and to player_cards
    player_cards = [player_cards; deck(1)];
    cards_out(getcardnum(deck(1))) = cards_out(getcardnum(deck(1))) + 1;
    deck = deck(2:end);

    player_nums = arrayfun(@getcardnum, player_cards);
    result = calculatesum(player_nums);
end