#!/bin/bash

# Set up the PSQL variable for querying the database
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate a random number between 1 and 1000
SECRET_NUMBER=$((1 + RANDOM % 1000))

# Function to get the username from the user
get_username() {
  echo "Enter your username:"
  read USERNAME
  USERNAME_RESULT=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")
  if [[ -z $USERNAME_RESULT ]]; then
    INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else
    GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games INNER JOIN users USING(user_id) WHERE username = '$USERNAME'")
    BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games INNER JOIN users USING(user_id) WHERE username = '$USERNAME'")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi
}

# Function to play the guessing game
play_game() {
  NUMBER_OF_GUESSES=0
  GUESS=0

  echo "Guess the secret number between 1 and 1000:"

  while [[ $GUESS -ne $SECRET_NUMBER ]]; do
    read GUESS

    if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
      echo "That is not an integer, guess again:"
    else
      NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))

      if [[ $GUESS -lt $SECRET_NUMBER ]]; then
        echo "It's higher than that, guess again:"
      elif [[ $GUESS -gt $SECRET_NUMBER ]]; then
        echo "It's lower than that, guess again:"
      fi
    fi
  done

  echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
  INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, number_guessed, number_of_guesses) VALUES($USER_ID, $SECRET_NUMBER, $NUMBER_OF_GUESSES)")
}

# Main script flow
get_username
play_game
