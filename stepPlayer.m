function [NextObs,Reward,IsDone,NextState] = stepPlayer(Action,State)
    NextState = State;
    if ~ismember(Action,[1 2])
        error('Action must be 1 or 2');
    end
    % agent chose to hit
    if Action == 1
        [NextState.player_cards, NextState.deck, NextState.cards_out, result] = ...
            hit(State.player_cards, State.deck, State.cards_out);
        % agent has busted
        if result == -1
            [NextState, Reward] = agent_has_finished(NextState, true);
            NextObs = calculate_next_obs(NextState);
            IsDone = end_turn(NextState);
        elseif result == 21
            [NextState, Reward] = agent_has_finished(NextState, false);
            NextObs = calculate_next_obs(NextState);
            IsDone = end_turn(NextState);
        else
            Reward = 0;
            IsDone = false;
            NextObs = calculate_next_obs(NextState);
        end
    else
        % agent chose to stand
        [NextState, Reward] = agent_has_finished(NextState, false);
        NextObs = calculate_next_obs(NextState);
        IsDone = end_turn(NextState);
    end
end


function [State, Reward] = agent_has_finished(State, busted)
    if busted == false
        [State.dealer_cards, State.deck, State.cards_out, result] = ...
            dealerturn(State.dealer_cards, State.player_cards, State.deck, State.cards_out);
    else
        result = -1;
    end
    % Reward is either -1, 0 or 1
    Reward = result;
end

function NextObs = calculate_next_obs(State)
    NextObs = zeros(21,1);
    NextObs(1:10) = State.cards_out;
    for i = 1:numel(State.player_cards)
        NextObs(10 + getcardnum(State.player_cards(i))) = ...
            NextObs(10 + getcardnum(State.player_cards(i))) + 1;
    end
    NextObs(21) = getcardnum(State.dealer_cards(1));
end

function [IsDone] = end_turn(State)
    if State.should_print == true
        fprintf("\n-------Turn n. %d-------", State.turn);
        printgamestate(State.dealer_cards, State.player_cards);
    end
    IsDone = true;
end