#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\n~~~~~ MY MEN'S SALON ~~~~~\n"
echo "Welcome to My Men's Salon, how can I assist you today?"

# Function to display available services
show_services() {
  SERVICES_LIST=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES_LIST" | while IFS="|" read service_id service_name; do
    echo "$service_id) $service_name"
  done
}

# Prompt the user to choose a service
while true; do
  show_services
  echo "Please Enter the service id for your today's appointment"
  read SERVICE_ID_SELECTED

  # Check if the chosen service exists
  selected_service_name=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z "$selected_service_name" ]]; then
    echo -e "\nI couldn't find that service. Please choose from the list below."
  else
    break
  fi
done

# Ask for the customer's phone number
echo -e "\nCould you provide your phone number?"
read CUSTOMER_PHONE

# Check if the customer already exists in the database
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

# If the customer isn't found, ask for their name and add them to the database
if [[ -z "$CUSTOMER_NAME" ]]; then
  echo -e "\nI don't have a record for that phone number. What's your name?"
  read CUSTOMER_NAME
  add_customer=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
fi

# Retrieve the customer's ID
customer_id=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

# Ask for the preferred appointment time
echo -e "\nWhat time would you like your $selected_service_name, $CUSTOMER_NAME?"
read SERVICE_TIME

# Save the appointment
add_appointment=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($customer_id, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

# Confirm the booking with the required message format
echo -e "\nI have put you down for a $selected_service_name at $SERVICE_TIME, $CUSTOMER_NAME. See you then!"