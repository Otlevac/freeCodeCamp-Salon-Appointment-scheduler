#! /bin/bash

PSQL="psql -X -U freecodecamp -d salon --tuples-only -c" 

echo -e "\n~~~~~ MY SALON ~~~~~\n"
SERVICE=$($PSQL "SELECT * FROM services")


MAIN_MENU(){
  
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "Welcome to My Salon, how can I help you?\n\n"
  fi
  
  echo "$SERVICE" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # find service
    SERVICE_ID=$($PSQL "SELECT * FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    # if not found
    if [[ -z $SERVICE_ID ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      FIND_CUSTOMER_PHONE=$($PSQL "SELECT * FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      # if customer's phone not found
      if [[ -z $FIND_CUSTOMER_PHONE ]]
      then
        INSERT_CUSTOMER_PHONE=$($PSQL "INSERT INTO customers(phone) VALUES('$CUSTOMER_PHONE')")
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        ADD_CUSTOMER_NAME=$($PSQL "UPDATE customers SET name='$CUSTOMER_NAME'")
      fi
      echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
      read SERVICE_TIME
      # find customer_id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      # insert in appointments 
      INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      # find custumer and service name
      FIND_CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID ")
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME,$FIND_CUSTOMER_NAME."
    fi
  fi
}

MAIN_MENU
