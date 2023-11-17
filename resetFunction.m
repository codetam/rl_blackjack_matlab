function [InitialObservation, InitialState] = resetFunction()
    % parameters
    initial_stake = 1000;
    num_players = 4;
    bets = [5, 20, 100]';
    % turn will be between 1 and 4
    turn = randi(4);
    should_print = true;


    % initialize and shuffle deck
    deck = [1:52, 1:52];
    deck = deck(randperm(length(deck)));

    % on turn n, on average 2-3 cards will be known per each player +
    % dealer
    hits = randi([2,3], 1, (num_players + 1) * (turn - 1));
    num_cards_out = (num_players + 1) * 2 * (turn - 1) + sum(hits);

    cards_out = zeros(10,1);
    % cards removed from the deck
    for i = 1:num_cards_out
        cards_out(getcardnum(deck(i))) = ...
            cards_out(getcardnum(deck(i))) + 1;
    end
    deck = deck(num_cards_out+1:end);
    % Observation received by the agent
    % The final element is 1 because it's the first gamestate
    InitialObservation = [zeros(14,1); 1];
    InitialObservation(1:10) = cards_out;
    
    % State of the environment
    InitialState.cards_out = cards_out;
    InitialState.playercards = 0;
    InitialState.dealercards = 0;
    InitialState.current_bet = 0;
    InitialState.stake = initial_stake;
    InitialState.initial_stake = initial_stake;
    InitialState.deck = deck;
    InitialState.gamestate = 1;
    InitialState.num_players = num_players;
    InitialState.bets = bets;
    InitialState.turn = turn;
    InitialState.should_print = should_print;
end