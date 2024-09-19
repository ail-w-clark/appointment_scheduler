#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n ~~~~~~ The Hair Salon ~~~~~~\n"

MAIN_MENU() {
    AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # display available services
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done
}

MAIN_MENU "Welcome to the salon! What would you like to schedule?"

read SERVICE_ID_SELECTED
# check if main menu selection is valid
SERVICE_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
if [[ -z $SERVICE_SELECTED ]]
then
  MAIN_MENU "Please enter a number below that corresponds with the service you'd like."

else
  echo "What's your phone number?"
  read CUSTOMER_PHONE

  # check if existing customer
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo "It looks like it's your first time here. What's your name?"
    read CUSTOMER_NAME
    
    # create new customer
    INPUT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi

  # get time
  echo "Hi, $CUSTOMER_NAME! What time would you like to make your appointment?"
  read SERVICE_TIME

  # get customer_id 
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # input appointment
  NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
  echo "I have put you down for a $SERVICE_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
fi
