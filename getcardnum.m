function num = getcardnum(card)
    if card > 39
        num = 10;
    else
        num = mod(card,10);
        if num < 1
            num = 10;
        end
    end
end