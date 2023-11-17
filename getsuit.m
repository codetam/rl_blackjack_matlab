function suit = getsuit(card)
    switch mod(card,4)
        case 0
            suit = '♠';
        case 1
            suit = '♥';
        case 2
            suit = '♦';
        case 3
            suit = '♣';
    end
end