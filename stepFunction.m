function [NextObs,Reward,IsDone,NextState] = stepFunction(Action,State)
    NextState = State;
    NextObs = zeros(15,1);
    if State.gamestate == 1
        if ~ismember(Action,[1 2 3])
            error('Action must be 1, 2 or 3');
        end
        % on average, players tend to take 2 or 3 hits per hand
        hits = randi([2,3], 1, NextState.num_players - 1);
        num_cards_out = 1 + NextState.num_players * 2 + sum(hits);

        % cards removed from the deck
        for i = 1:num_cards_out
            NextState.cards_out(getcardnum(NextState.deck(i))) = ...
                NextState.cards_out(getcardnum(NextState.deck(i))) + 1;
        end
        NextObs(1:10) = NextState.cards_out;

        % add player cards
        NextState.player_cards = NextState.deck(NextState.num_players*2-1:NextState.num_players*2)';
        player_nums = arrayfun(@getcardnum, NextState.player_cards);
        NextObs(11) = calculatesum(player_nums);
        % add dealer card
        NextState.dealer_cards = NextState.deck(NextState.num_players*2+1);
        NextObs(12) = getcardnum(NextState.deck(NextState.num_players*2+1));

        % check for the ace
        if ismember(player_nums, 1)
            NextObs(13) = 1;
        else
            NextObs(13) = 0;
        end
        NextState.current_bet = NextState.bets(Action);
        NextObs(14) = NextState.bets(Action);
        NextObs(15) = 2;
        
        % update deck
        NextState.deck = NextState.deck(num_cards_out+1:end);
        NextState.gamestate = 2;
        Reward = 0;
        IsDone = false;
    end
    if State.gamestate == 2
        if ~ismember(Action,[1 2 3])
            error('Action must be 1, 2 or 3');
        end
        % agent chose to hit
        if Action == 1
            [NextState.player_cards, NextState.deck, NextState.cards_out, result] = ...
                hit(NextState.player_cards, NextState.deck, NextState.cards_out);
            % agent has busted
            if result == -1
                [NextState, Reward] = agent_has_finished(NextState, true);
                NextObs = calculate_next_obs(NextState, 1);
                [NextState, IsDone] = end_turn(NextState);
            elseif result == 21
                [NextState, Reward] = agent_has_finished(NextState, false);
                NextObs = calculate_next_obs(NextState, 1);
                [NextState, IsDone] = end_turn(NextState);
            else
                Reward = 0;
                IsDone = false;
                NextObs = calculate_next_obs(NextState, 2);
            end
        else
            % agent chose to stand
            [NextState, Reward] = agent_has_finished(NextState, false);
            NextObs = calculate_next_obs(NextState,1);
            [NextState, IsDone] = end_turn(NextState);
        end
    end
end


function [State, Reward] = agent_has_finished(State, busted)
    if busted == false
        [State.dealer_cards, State.deck, State.cards_out, result] = ...
            dealerturn(State.dealer_cards, State.player_cards, State.deck, State.cards_out);
    else
        result = -1;
    end
    switch result
        case -1
            % agent has lost
            Reward = - State.current_bet;
            State.stake = State.stake - State.current_bet;
        case 0
            % player has tied
            Reward = 0;
        case 1
            % player has won 
            Reward = State.current_bet;
            State.stake = State.stake + State.current_bet;
    end
end

function NextObs = calculate_next_obs(State, next_gamestate)
    NextObs = zeros(15,1);
    NextObs(1:10) = State.cards_out;
    player_nums = arrayfun(@getcardnum, State.player_cards);
    NextObs(11) = calculatesum(player_nums);
    NextObs(12) = getcardnum(State.dealer_cards(1));

    % check for the ace
    if ismember(1, player_nums)
        NextObs(13) = 1;
    else
        NextObs(13) = 0;
    end
    NextObs(14) = State.current_bet;
    NextObs(15) = next_gamestate;
end

function [State, IsDone] = end_turn(State)
    if State.should_print == true
        fprintf("\n-------Turn n. %d-------\n", State.turn);
        fprintf("Stake: $%d", State.stake);
        printgamestate(State.dealer_cards, State.player_cards);
    end
    IsDone = true;
    State.gamestate = 1;
end