#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE TABLE teams, games RESTART IDENTITY")

#Read the data from the .csv file containing the game information, and set variables accordingly
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]] #if statement to ensure that the column headings don't get included
  then

    # get team_id from winners
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

    # if not found
    if  [[ -z $TEAM_ID ]]
    then

      #Insert team
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $WINNER
      fi   
      
    fi

    # get team_id from opponents
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # if not found
    if  [[ -z $TEAM_ID ]]
    then

      #Insert team
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $OPPONENT
      fi
   
    fi


    #Get the winner and opponent ids from the teams table
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    #Get the game_id using the winner and opponent ids
    GAME_ID=$($PSQL "SELECT game_id FROM games WHERE winner_id='$WINNER_ID' AND opponent_id='$OPPONENT_ID'")

    # if not found
    if  [[ -z $GAME_ID ]]
    then

      #Insert game
      INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(round, year, winner_id, opponent_id, winner_goals, opponent_goals) VALUES('$ROUND', '$YEAR', '$WINNER_ID', '$OPPONENT_ID', '$WINNER_GOALS', '$OPPONENT_GOALS')")
      if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into games, $WINNER_ID $OPPONENT_ID
      fi
    fi
  fi
  

done