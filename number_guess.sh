#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"


NUMBER_GUESS() {
  read GUESS
  GUESS_COUNTER=$((GUESS_COUNTER+1))
  if [[ $GUESS != $SECRET_NUMBER ]]
  then
    if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
      echo -e "\nThat is not an integer, guess again:"
      NUMBER_GUESS
    fi
    
    if [[ $GUESS -lt $SECRET_NUMBER ]]
    then
      echo -e "\nIt's higher than that, guess again:"
      NUMBER_GUESS
    fi

    if [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      echo -e "\n It's lower than that, guess again:"
      NUMBER_GUESS
    fi
  fi
}

#get username
echo "Enter your username:"
read USERNAME

#check if username exists
USERNAME_ENTERED=$($PSQL "SELECT username FROM players WHERE username='$USERNAME'")

if [[ -z $USERNAME_ENTERED ]]
then
  #store new username
  STORE_USERNAME=$($PSQL "INSERT INTO players(username) VALUES('$USERNAME')")
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."

  echo -e "\nGuess the secret number between 1 and 1000:"
  SECRET_NUMBER=$((1 + RANDOM % 1000))
  GUESS_COUNTER=0
  NUMBER_GUESS
else
  PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE username='$USERNAME'")
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE player_id=$PLAYER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE player_id=$PLAYER_ID")

  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  
  echo -e "\nGuess the secret number between 1 and 1000:"
  SECRET_NUMBER=$((1 + RANDOM % 1000))
  GUESS_COUNTER=0
  NUMBER_GUESS
fi

echo -e "\nYou guessed it in $GUESS_COUNTER tries. The secret number was $SECRET_NUMBER. Nice job!"

PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE username='$USERNAME'")
ENTER_GAME_RESULT=$($PSQL "INSERT INTO games(player_id, number_of_guesses) VALUES($PLAYER_ID, $GUESS_COUNTER)")

