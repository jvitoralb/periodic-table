#!/bin/bash

PSQL=""

DB_CONFIG() {
  echo -e "\nSetting database...\n"

  PSQL="psql --username=freecodecamp --dbname=periodic_table -t -c"

  EXISTS_DB=$($PSQL "SELECT 1 FROM pg_database WHERE datname='periodic_table';")

  echo -e "\nDatabase is ready!\n"
}
DB_CONFIG

TABLE_HANDLER() {
  if [[ -z $1 ]]
  then
    echo "Please provide an element as an argument." 
    return
  fi

  ELEMENT_PROPS=""
  
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ELEMENT_PROPS=$($PSQL "SELECT e.symbol, e.name, p.*, t.type FROM elements e JOIN properties p ON p.atomic_number=e.atomic_number JOIN types t ON p.type_id=t.type_id WHERE e.atomic_number=$1;")
  elif (( ${#1} <= 2 ))
  then
    ELEMENT_PROPS=$($PSQL "SELECT e.symbol, e.name, p.*, t.type FROM elements e JOIN properties p ON e.atomic_number=p.atomic_number JOIN types t ON p.type_id=t.type_id WHERE symbol='$1';")
  else
    ELEMENT_PROPS=$($PSQL "SELECT e.symbol, e.name, p.*, t.type FROM elements e JOIN properties p ON e.atomic_number=p.atomic_number JOIN types t ON p.type_id=t.type_id WHERE name='$1';")
  fi

  if [[ -z $ELEMENT_PROPS ]]
  then
    echo -e "\nI could not find that element in the database.\n"
    return
  fi

  DISPLAY_RESULT $ELEMENT_PROPS
}

DISPLAY_RESULT() {
  echo "$ELEMENT_PROPS" | while read SYMBOL B NAME B ATMC_NUM B ATMC_MASS B MELTING B BOILING B TYPE_ID B TYPE
  do
    echo -e "\nThe element with atomic number $ATMC_NUM is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATMC_MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius.\n"
  done
}

START() {
  DB_CONFIG
  TABLE_HANDLER $1
}
START $1
