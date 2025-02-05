#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess --no-align --tuples-only -c"

# Prompt for username
echo -e "\nEnter your username:"
read USERNAME

# Fetch user data
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=(SELECT user_id FROM users WHERE username='$USERNAME')")
BEST_GAME=$($PSQL "SELECT MIN(number_guesses) FROM games WHERE user_id=(SELECT user_id FROM users WHERE username='$USERNAME')")

# Check if user exists
if [[ -z $USER_ID ]]; then
  # Insert new user
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
else
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generate random number
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
GUESS_COUNT=0

# Start guessing game
echo -e "\nGuess the secret number between 1 and 1000:"
while read USER_GUESS; do
  # Validate input
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]; then
    echo -e "\nThat is not an integer, guess again:"
    continue
  fi

  # Increment guess count
  ((GUESS_COUNT++))

  # Check guess
  if [[ $USER_GUESS -lt $SECRET_NUMBER ]]; then
    echo "It's higher than that, guess again:"
  elif [[ $USER_GUESS -gt $SECRET_NUMBER ]]; then
    echo "It's lower than that, guess again:"
  else
    break
  fi
done

# Insert game record
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, number_guesses) VALUES($USER_ID, $GUESS_COUNT)")

# Winning message
echo -e "\nYou guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"

