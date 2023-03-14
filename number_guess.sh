#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

MAIN_MENU(){
SECRET_NUMBER=$(( $RANDOM % 1000 ))
echo "Enter your username:"
read USER
USERNAME=$($PSQL "SELECT username FROM usernames WHERE username = '$USER'")
GAMES_PLAYED=$($PSQL "SELECT games_played FROM usernames WHERE username = '$USER'")
BEST_GAME=$($PSQL "SELECT best_game FROM usernames WHERE username = '$USER'")
if [[ $USER == $USERNAME ]]
  then
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  echo "Welcome, $USER! It looks like this is your first time here."
fi
NUMBER_OF_GUESSES=$(( 0 ))
echo "Guess the secret number between 1 and 1000:"
read GUESS
while [[ $GUESS != $SECRET_NUMBER ]]
do
if [[ $GUESS < $SECRET_NUMBER && $GUESS =~ ^[0-9]+$ ]]
  then
  NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1 ))
  echo "It's higher than that, guess again:"
  read GUESS
elif [[ $GUESS > $SECRET_NUMBER && $GUESS =~ ^[0-9]+$ ]]
  then
  NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1 ))
  echo "It's lower than that, guess again:"
  read GUESS
else
  NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1 ))
  echo "That is not an integer, guess again:"
  read GUESS
fi
done
  if [[ $USER != $USERNAME ]]
    then
    $PSQL "INSERT INTO usernames(username, games_played, best_game) VALUES ('$USER', 0, 0);" > /dev/null
    BEST_GAME=$($PSQL "SELECT best_game FROM usernames WHERE username = '$USER'")
    NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1 ))
    $PSQL "UPDATE usernames SET games_played = $(( $GAMES_PLAYED + 1 )) WHERE username = '$USER'" > /dev/null
    if [[ $NUMBER_OF_GUESSES < $BEST_GAME ]]
      then
      $PSQL "UPDATE usernames SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USER';" > /dev/null
    elif [[ $BEST_GAME = $(( 0 )) ]]
      then 
      $PSQL "UPDATE usernames SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USER';" > /dev/null
  fi
  echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

  elif [[ $USER == $USERNAME ]]
  then
  BEST_GAME=$($PSQL "SELECT best_game FROM usernames WHERE username = '$USER'")
  NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1 ))
  $PSQL "UPDATE usernames SET games_played = $(( $GAMES_PLAYED + 1 )) WHERE username = '$USER'" > /dev/null
  if [[ $NUMBER_OF_GUESSES < $BEST_GAME ]]
  then
  $PSQL "UPDATE usernames SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USER';" > /dev/null
  elif [[ $BEST_GAME = $(( 0 )) ]]
  then $PSQL "UPDATE usernames SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USER';" > /dev/null
  fi
  echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
  fi
}
MAIN_MENU
