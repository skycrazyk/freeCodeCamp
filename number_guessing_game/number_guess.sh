#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

READ_GUESS () {
  read GUESS

  if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    READ_GUESS
  else
    if [[ "$GUESS" -eq "$SECRET_NUMBER" ]]; then
      echo "You guessed it in $TRY_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"

      if [[ -z $USER_ID ]]; then
        RESULT=$($PSQL "INSERT INTO users(name) VALUES ('$USERNAME')")
        USER_ID=$($PSQL "SELECT id FROM users WHERE name='$USERNAME'")
      fi

      RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES ($USER_ID, $TRY_COUNT)")
      exit 0
    elif [[ "$GUESS" -lt "$SECRET_NUMBER" ]]; then
      TRY_COUNT=$((TRY_COUNT+1))

      echo "It's lower than that, guess again:"
      READ_GUESS
    else 
      TRY_COUNT=$((TRY_COUNT+1))

      echo "It's higher than that, guess again:"
      READ_GUESS
    fi
  fi
}

if [[ $1 = 'clear' ]]; then
  RESULT=$($PSQL "TRUNCATE TABLE users, games")

  echo "Tables are cleared"
  exit 0
fi

echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT id FROM users WHERE name='$USERNAME'")

if [[ -z $USER_ID ]]; then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else

  GAMES_COUNT=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
  MIN_GUESS=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID")

  echo "Welcome back, $USERNAME! You have played $GAMES_COUNT games, and your best game took $MIN_GUESS guesses."
fi

SECRET_NUMBER=$(($RANDOM%(1000-1+1)+1))

if [[ $1 = 'debug' ]]; then
  echo "DEBUG: SECRET_NUMBER: $SECRET_NUMBER"
fi

TRY_COUNT=1

echo "Guess the secret number between 1 and 1000:"
READ_GUESS