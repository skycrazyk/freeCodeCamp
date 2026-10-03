#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [ -z $1 ]; then 
  echo "Please provide an element as an argument."
else
  if [[ $1 =~ ^[0-9]+$ ]]; then
    CONDITION="e.atomic_number = $1"
  else
    CONDITION="symbol = '$1' OR name = '$1'"
  fi

  ELEMENTS=$($PSQL "SELECT e.symbol, e.name, t.type, e.atomic_number, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius FROM elements e INNER JOIN properties p ON e.atomic_number = p.atomic_number INNER JOIN types t ON p.type_id = t.type_id WHERE $CONDITION")

  if [ -z $ELEMENTS ]; then
    echo "I could not find that element in the database."
  else 
    IFS='|' read -r SYMBOL NAME TYPE ANUMBER AMASS MELTING BOILING <<< "$ELEMENTS"
    echo "The element with atomic number $ANUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $AMASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
  fi
fi
