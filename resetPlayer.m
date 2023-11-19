function [InitialObservation, InitialState] = resetPlayer()
    % parameters
    should_print = true;
    num_players = 4;
    % turn will be between 1 and 4
    turn = randi(4);

    % initialize and shuffle deck
    deck = [1:52, 1:52];
    deck = deck(randperm(length(deck)));

    % on turn n, on average 2-3 cards will be known per each player +
    % dealer
    cards_out = zeros(10,1);
    hits = randi([2,3], 1, (num_players + 1) * (turn - 1));
    num_cards_out = (num_players + 1) * 2 * (turn - 1) + sum(hits);

    % beginning of turn
    hits = randi([2,3], 1, num_players - 1);
    num_cards_out = num_cards_out + 1 + num_players * 2 + sum(hits);

    % cards removed from the deck
    for i = 1:num_cards_out
        cards_out(getcardnum(deck(i))) = ...
            cards_out(getcardnum(deck(i))) + 1;
    end
    % add player cards
    player_nums = zeros(10,1);
    player_cards = deck(num_cards_out-2:num_cards_out-1)';
    for i = 1:2
        player_nums(getcardnum(player_cards(i))) = ...
            player_nums(getcardnum(player_cards(i))) + 1;
    end
    % add dealer card
    dealer_card = deck(num_cards_out);
    deck = deck(num_cards_out+1:end);

    % Observation received by the agent
    InitialObservation = zeros(21,1);
    InitialObservation(1:10) = cards_out;
    InitialObservation(11:20) = player_nums;
    InitialObservation(21) = getcardnum(dealer_card);

    % State of the environment
    InitialState.cards_out = cards_out;
    InitialState.player_cards = player_cards;
    InitialState.dealer_cards = dealer_card;
    InitialState.deck = deck;
    InitialState.num_players = num_players;
    InitialState.turn = turn;
    InitialState.should_print = should_print;
end