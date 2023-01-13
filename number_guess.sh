#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align --tuples-only -c"

echo "Enter your username:"
read USERNAME

USER_CHECK=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
NUMBER_OF_GAMES=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME';")
BEST_SCORE=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME';")

GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM users INNER JOIN games USING(user_id) WHERE username='$USERNAME';")
BEST_GAME=$($PSQL "SELECT MIN(number_guesses) FROM users INNER JOIN games USING(user_id) WHERE username='$USERNAME';")
if [[ -z $USER_CHECK ]]
then
  INSERT_USER=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, NULL);")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else 
echo  "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo -e "\nGuess the secret number between 1 and 1000:"
COUNT=1
RANDOM_NUM=$((1 + $RANDOM % 5))

while read NUMBER
do
  if [[ ! $NUMBER =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
  if [[ $NUMBER -eq $RANDOM_NUM ]]
  then
    if [[ -z $USER_CHECK ]]
    then
    echo  "You guessed it in $COUNT tries. The secret number was $RANDOM_NUM. Nice job!"
      break;
    else
      ((NUMBER_OF_GAMES++))
      GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=$NUMBER_OF_GAMES WHERE username='$USERNAME';")
    fi
    if [[ $BEST_SCORE -ge $COUNT || $BEST_SCORE -eq NULL ]]
    then
      BEST_GAME=$($PSQL "UPDATE users SET best_game=$COUNT WHERE username='$USERNAME';")
    fi
    echo  "You guessed it in $COUNT tries. The secret number was $RANDOM_NUM. Nice job!"
    break;
  else
  if [[ $NUMBER -gt $RANDOM_NUM ]]
  then
    COUNT=$(( $COUNT + 1 ))
    echo -e "\nIt's lower than that, guess again:"
  elif [[ $NUMBER -lt $RANDOM_NUM ]]
  then
    COUNT=$(( $COUNT + 1 ))
    echo -e "\nIt's higher than that, guess again:"
    fi
    fi
    fi
done

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
INSERT_GAME=$($PSQL "INSERT INTO games(number_guesses, user_id) VALUES($COUNT, $USER_ID);")