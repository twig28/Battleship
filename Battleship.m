clc 
clear

%pre-sets the ai's number of guesses around a hit to 0
HitGuessesAI = 0;

%Setups Game using the simpleGameEngine program
warning('off', 'all');
my_scene = simpleGameEngine('Battleship.png',84,84);

%declares sprites
blank_sprite = 1;
water_sprite = 2;
left_ship_sprite = 3;
horiz_ship_sprite = 4;
right_ship_sprite = 5;
top_ship_sprite = 6;
vert_ship_sprite = 7;
bot_ship_sprite = 8;
hit_sprite = 9;
miss_sprite = 10;

%Visually sets up board
board_display = water_sprite * ones(10,21);
board_display(:,11) = blank_sprite;

%Creates two arrays for player and AI
%uses Setup() function to create a board for the AI
EnemyBoard = Setup();
PlayerBoard = zeros(10, 10);

drawScene(my_scene,board_display);

%Introduces the plaayer to the game usin msgboxs 
uiwait(msgbox('Welcome To Battleship! To place or guess a ship, enter a number corresponding to the tile from 1-10 for both x and y coordinates.'))
uiwait(msgbox('Your board is the board on the left, while your opponent has the board on the right'))

%variable to iterate
k = 1;
%array of battleship boats 
boats = [5, 4, 3, 3, 2];
%Loop for placing the players ships on board
while(k <= length(boats))
    
%Displays Appropraite Message Based Upon Boat
currentShip = boats(k);
if currentShip == 5
prompt = {'Enter the x (horiz) value of the carrier (5 tiles):', 'Enter the y (vert) value of the carrier (5 tiles):'};
end
if currentShip == 4
prompt = {'Enter the x (horiz) value of the battleship (4 tiles):', 'Enter the y (vert) value of the battleship (4 tiles):'};
end
if currentShip == 3
prompt = {'Enter the x (horiz) value of the destroyer/submarine (3 tiles):', 'Enter the y (vert) value of the destroyer/submarine (3 tiles):'};
end
if currentShip == 2
prompt = {'Enter the x (horiz) value of the patrol boat (2 tiles):', 'Enter the y (vert) value of the patrol boat (2 tiles):'};
end

%Gets Input For Initial Position and stores it 
dlgtitle ='Enter Initial Position';
InitialPosition = inputdlg(prompt, dlgtitle, [1 65]);
InitialPosition = [InitialPosition(1,:) , InitialPosition(2,:)];
InitialPosition = cellfun(@str2num, InitialPosition);

%Checks if it is a valid initial position
if (InitialPosition(1) > 10 || InitialPosition(2) > 10)
    fprintf('Invalid Position, Re-Place This Ship\n');
    continue
elseif (PlayerBoard(InitialPosition(2), InitialPosition(1)) ~= 0)
    fprintf('Invalid Position, Re-Place This Ship\n');
    continue
end

%returns a 3xN array of possible locations and thier corresponding orientation based upon the direction from initial position 
PositionOrientaionArray = PossiblePositions(InitialPosition(1), InitialPosition(2), currentShip, PlayerBoard);
%if no positions are found 
if (isempty(PositionOrientaionArray))
    fprintf('No Valid End Positions, Re-Place This Ship\n');
    continue
end

%uses the size of the returned array to get the number of final positions
%to choose from
sz = size(PositionOrientaionArray);
NumPositions = sz(1);

%Converts this array to a proper string
PositionArrayDisplay = PositionOrientaionArray(:, 1:2);
PositionArrayDisplay = string(PositionArrayDisplay);

%display the coordinates as strings in a list to be selected from
list = [""];
for i = 1:NumPositions
    list(i) = PositionArrayDisplay(i, 1) + ", " + PositionArrayDisplay(i, 2);
end

%shows the user a list of final positions to choose from
[indx,tf] = listdlg('ListString', list, 'PromptString', 'Select A Final Position', 'SelectionMode', 'single');

%sets the final position arr equal to the chosen set of coordinates
FinalPositionArr = PositionOrientaionArray(indx, :);

%Places Ship visually and in the playerBoard array
%3 = right, 5 = left, 8 = down, 6 = up according to the sprite that it
%needs
initialOrientation = FinalPositionArr(3);
%If Left, Places Peices Accordingly
if initialOrientation == 5
    finalOrientation = 3;
    for i = 1 : currentShip - 1
        if(i ~= currentShip)
            board_display(InitialPosition(2), InitialPosition(1) - i) = 4;
            PlayerBoard(InitialPosition(2), InitialPosition(1) - i) = k;
        end
    end
%If Right, Places Peices Accordingly
elseif initialOrientation == 3
     finalOrientation = 5;
     for i = 1 : currentShip - 1
        if(i ~= currentShip)
            board_display(InitialPosition(2), InitialPosition(1) + i) = 4;
            PlayerBoard(InitialPosition(2), InitialPosition(1) + i) = k;
        end
     end
%If Down, Places Peices Accordingly
elseif initialOrientation == 8
     finalOrientation = 6;
     for i = 1 : currentShip - 1
        if(i ~= currentShip)
            board_display(InitialPosition(2) - i, InitialPosition(1)) = 7;
            PlayerBoard(InitialPosition(2) - i, InitialPosition(1)) = k;
        end
    end
else
%If Up, Places Peices Accordingly
    finalOrientation = 8;
    for i = 1 : currentShip - 1
        if(i ~= currentShip)
            board_display(InitialPosition(2) + i, InitialPosition(1)) = 7;
            PlayerBoard(InitialPosition(2) + i, InitialPosition(1)) = k;
        end
    end
end

%Places end of boats in proper orientation
board_display(InitialPosition(2), InitialPosition(1)) = initialOrientation;
PlayerBoard(InitialPosition(2), InitialPosition(1)) = currentShip;
board_display(FinalPositionArr(2), FinalPositionArr(1)) = finalOrientation;
PlayerBoard(FinalPositionArr(2), FinalPositionArr(1)) = currentShip;

%draws board after every iteration
drawScene(my_scene, board_display);

%iterates
k = k + 1;

end

%setsup the hitmiss display
hitmiss_display = blank_sprite * ones(10,21);

%redraws
drawScene(my_scene,board_display,hitmiss_display)

%winner: player = 0; 2 = AI;
winner = 1;

%main while loop for the guessing part of the game
while winner
    NumPlayerShips = 0;
    NumAIShips = 0;
    NumAI1 = 0;
    NumAI2 = 0;
    NumAI3 = 0;
    NumAI4 = 0;
    NumAI5 = 0;
    %checks if any ships are left on both boards and which type for AI and
    %sums them
    for i = 1:10
        for j = 1:10
            if PlayerBoard(i, j) ~= 0 
                NumPlayerShips = NumPlayerShips + 1;
            elseif EnemyBoard(i, j) == 1
                NumAI1 = NumAI1 + 1;
            elseif EnemyBoard(i, j) == 2
                NumAI2 = NumAI2 + 1;
            elseif EnemyBoard(i, j) == 3
                NumAI3 = NumAI3 + 1;
            elseif EnemyBoard(i, j) == 4
                NumAI4 = NumAI4 + 1;
            elseif EnemyBoard(i, j) == 5
                NumAI5 = NumAI5 + 1;
            end
            if EnemyBoard(i, j) ~= 0
                NumAIShips = NumAIShips + 1;
            end
        end
    end

    %Determines the winner if either board has zero ships
    if NumAIShips == 0
        winner = 1;
        break;
    elseif NumPlayerShips == 0
        winner = 2;
        break;
    end

%Creates A String containing the statistics of the enemy's board
%then displays via a messagebox on the left side
message = "Carrier  Battleship  Submarine  Destroyer  PT Boat ------------------------------------------------------------------         ";
if NumAI1 == 0
    message = message + '-Sunk-    ';
else
    message = message + '-Afloat-  ';
end
if NumAI2 == 0
    message = message + ' -Sunk-    ';
else
    message = message + ' -Afloat-  ';
end
if NumAI3 == 0
    message = message + '    -Sunk-    ';
else
    message = message + '    -Afloat-  ';
end
if NumAI4 == 0
    message = message + '     -Sunk-    ';
else
    message = message + '     -Afloat-  ';
end
if NumAI5 == 0
    message = message + '   -Sunk-    ';
else
    message = message + '   -Afloat-  ';
end

EnemyStats = msgbox(message, "Enemy Board");
set(EnemyStats, 'position', [10 500 200 75]);

%Prompts the user for a guess and inuts it properly
prompt = {'Enter the x (horiz) value to guess:', 'Enter the y (vert) value to guess:'};
dlgtitle ='Guess Enemy Position';
PlayerGuess = inputdlg(prompt, dlgtitle, [1 60]);
PlayerGuess = [PlayerGuess(1,:) , PlayerGuess(2,:)];
PlayerGuess = cellfun(@str2num, PlayerGuess);

%If Position is Invalid (or if player already Guessed it), restarts loop
if (PlayerGuess(1) > 10 || PlayerGuess(2) > 10 || PlayerGuess(2) < 1 || PlayerGuess(1) < 1 || hitmiss_display(PlayerGuess(2), PlayerGuess(1) + 11) == hit_sprite || hitmiss_display(PlayerGuess(2), PlayerGuess(1) + 11) == miss_sprite)
    fprintf('Invalid position or already guessed, re-guess\n');
    delete(EnemyStats);
    continue;
end
%Depending on guess from player, outputs accordingly and changes the board
%accordingly
if EnemyBoard(PlayerGuess(2), PlayerGuess(1)) ~=0
    fprintf("Hit!\n");
    EnemyBoard(PlayerGuess(2), PlayerGuess(1)) = 0;
    hitmiss_display(PlayerGuess(2), PlayerGuess(1) + 11) = hit_sprite;
else
    fprintf("Miss!\n");
    hitmiss_display(PlayerGuess(2), PlayerGuess(1) + 11) = miss_sprite;
end

%redraws
drawScene(my_scene,board_display,hitmiss_display)

%Pauses for 1 second to make AI Guess more smooth
pause(1.0);

%Generates a random guess unless HitGuessesAI is positive, if so attempts to guess
%up, down, left, or right of LocationHitAI depending on the value of HitGuessesAI
%Also makes sure the AI does not guess the same spot twice or in an invalid
%position
while(1)
    AIGuess = [randi(10), randi(10)];
    if HitGuessesAI == 4
        AIGuess = [LocationHitAI(2) + 1, LocationHitAI(1)];
    end
    if HitGuessesAI == 3
        AIGuess = [LocationHitAI(2) - 1, LocationHitAI(1)];
    end
    if HitGuessesAI == 2
        AIGuess = [LocationHitAI(2), LocationHitAI(1) + 1];
    end
    if HitGuessesAI == 1
        AIGuess = [LocationHitAI(2), LocationHitAI(1) - 1];
    end
    HitGuessesAI = HitGuessesAI - 1;
    if (AIGuess(1) > 10 || AIGuess(2) > 10 || AIGuess(1) < 1 || AIGuess(2) < 1)
        continue;
    elseif hitmiss_display(AIGuess(2), AIGuess(1)) == hit_sprite || hitmiss_display(AIGuess(2), AIGuess(1)) == miss_sprite
         continue;      
    else
        break;
    end
end
%Detects, implements and outputs the outcome of the AI's Guess
if (PlayerBoard(AIGuess(2), AIGuess(1)) ~= 0)
        fprintf("The Enemy Hit Your Ship at %i, %i!\n\n", AIGuess(2), AIGuess(1))
        PlayerBoard(AIGuess(2), AIGuess(1)) = 0;
        hitmiss_display(AIGuess(2), AIGuess(1)) = hit_sprite;
        HitGuessesAI = 4;
        LocationHitAI = [AIGuess(2), AIGuess(1)];
    else
        fprintf("The Enemy Guessed at %i, %i, and Missed!\n\n", AIGuess(2), AIGuess(1))
        hitmiss_display(AIGuess(2), AIGuess(1)) = miss_sprite;
end

%redraws
drawScene(my_scene, board_display, hitmiss_display)

%deletes stats box so it can be updated
delete(EnemyStats)
end

%Depending on the winner value that broke the loop, displays the winner
if winner == 0
    fprintf("You lost!")
else
    fprintf("You won!")
end