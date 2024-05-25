function [PositionOrientaion] = PossiblePositions(x1, y1, length, board)
%This function returns an array of possible final positions based upon an
%initial position entered by the user, it also returns the correct final
%orientation (i.e facing up, facing down) as a number to be used as a
%sprite

%Defualt Return Statement if no positions are found
PositionOrientaion = [];
%because initial peice is already placed
length = length - 1;

%%check right
for i = 1 : length 
    if (x1 + i > 10)
        break
    elseif (board(y1, x1 + i) ~= 0)
        break
    elseif (i == length)
        PositionOrientaion = [PositionOrientaion; x1 + i, y1, 3];
    end
end
%%check left
for i = 1 : length 
    if (x1 - i < 1)
        break
    elseif (board(y1, x1 - i) ~= 0)
        break
    elseif (i == length)
        PositionOrientaion = [PositionOrientaion; x1 - i, y1, 5];
    end
end
%%check up
for i = 1 : length 
    if (y1 - i < 1)
        break
    elseif (board(y1 - i, x1) ~= 0)
        break
    elseif (i == length)
        PositionOrientaion = [PositionOrientaion; x1, y1 - i, 8];
    end
end
%%check down
for i = 1 : length 
    if (y1 + i > 10)
        break
    elseif (board(y1 + i, x1) ~= 0)
        break
    elseif (i == length)
        PositionOrientaion = [PositionOrientaion; x1, y1 + i, 6];
    end
end