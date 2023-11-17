function printgamestate(dealer_cards, player_cards)
    fprintf('\nDealer has ');
    for i = 1:length(dealer_cards)
        fprintf('%d%s ',getcardnum(dealer_cards(i)), getsuit(dealer_cards(i)));
    end
    fprintf('sum: %d', calculatesum(arrayfun(@getcardnum, dealer_cards))); 
    fprintf('\nYou have: '); 
    for i = 1:length(player_cards)
        fprintf('%d%s ',getcardnum(player_cards(i)), getsuit(player_cards(i)));
    end
    fprintf('sum: %d\n', calculatesum(arrayfun(@getcardnum, player_cards)));
end