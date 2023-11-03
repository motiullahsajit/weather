#!/bin/bash

API_KEY="749e653329bff5752709850321d33a27"

DEFAULT_LOCATION="Dhaka"
DEFAULT_TEMP_UNIT="metric"
DEFAULT_WIND_UNIT="m/s"

# To store to-do tasks with weather conditions
TODO_LIST_FILE="todo.txt"
EVENTS_FILE="events.txt"

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -h, --help       Display this help message"
    echo "  -l, --location   Specify the location (e.g., city name, ZIP code, coordinates)"
    echo "  -t, --temperature-unit  Specify the temperature unit (Celsius or Fahrenheit)"
    echo "  -w, --wind-unit  Specify the wind speed unit (m/s or mph)"
    exit 1
}

set_user_preferences() {
    echo "User Preferences:"
    read -p "Enter default location: " DEFAULT_LOCATION
    read -p "Enter default temperature unit (Celsius or Fahrenheit): " DEFAULT_TEMP_UNIT
    read -p "Enter default wind speed unit (m/s or mph): " DEFAULT_WIND_UNIT

    echo "DEFAULT_LOCATION=\"$DEFAULT_LOCATION\"" > preferences.conf
    echo "DEFAULT_TEMP_UNIT=\"$DEFAULT_TEMP_UNIT\"" >> preferences.conf
    echo "DEFAULT_WIND_UNIT=\"$DEFAULT_WIND_UNIT\"" >> preferences.conf
    echo "Preferences saved."
}

load_user_preferences() {
    if [ -f "preferences.conf" ]; then
        source "preferences.conf"
    fi
}

get_weather() {
    load_user_preferences

    if [ -z "$DEFAULT_LOCATION" ]; then
        DEFAULT_LOCATION="Dhaka"
    fi

    API_URL="http://api.openweathermap.org/data/2.5/weather?q=$(tr '[:upper:]' '[:lower:]' <<< "$DEFAULT_LOCATION")&appid=$API_KEY&units=$DEFAULT_TEMP_UNIT"

    wget -qO- "$API_URL" > weather_data.json

    if [ $? -ne 0 ]; then
        echo "Error fetching weather data. Please check your internet connection or API key."
        exit 1
    fi

    description=$(grep -o '"description":"[^"]*' weather_data.json | cut -d'"' -f4)
    temperature=$(grep -o '"temp":[^,]*' weather_data.json | cut -d':' -f2)
    humidity=$(grep -o '"humidity":[^,]*' weather_data.json | cut -d':' -f2)
    wind_speed=$(grep -o '"speed":[^,]*' weather_data.json | cut -d':' -f2)
    wind_deg=$(grep -o '"deg":[^,]*' weather_data.json | cut -d':' -f2)

    echo "Location: $DEFAULT_LOCATION"
    echo "Description: $description"
    echo "Temperature: $temperature°C"
    echo "Humidity: $humidity%"
    echo "Wind Speed: $wind_speed $DEFAULT_WIND_UNIT"
    echo "Wind Direction: $wind_deg°"

    rm weather_data.json
}

show_main_menu() {
    while true; do
        echo "Main Menu:"
        echo "1. Current Weather"
        echo "2. Set User Preferences"
        echo "3. Enter Custom Location"
        echo "4. Weather-Dependent To-Do List"
        echo "5. Weather-Based Gardening Planner"
        echo "6. List Scheduled Events"
        echo "7. Add Event"
        echo "8. List Scheduled Events and To-Do Tasks"
        echo "9. Exit"
        read -p "Select an option (1/2/3/4/5/6/7/8/9): " choice
        case "$choice" in
            1) get_weather ;;
            2) set_user_preferences ;;
            3) read -p "Enter custom location: " DEFAULT_LOCATION; get_weather ;;
            4) todo_list_menu ;;
            5) gardening_planner ;;
            6) list_events ;;
            7) add_event ;;
            8) list_events_and_tasks ;;
            9) exit ;;
            *) echo "Invalid choice. Please select a valid option." ;;
        esac
    done
}

todo_list_menu() {
    while true; do
        echo "Weather-Dependent To-Do List Menu:"
        echo "1. Add a To-Do Task"
        echo "2. List To-Do Tasks"
        echo "3. Exit to Main Menu"
        read -p "Select an option (1/2/3): " choice
        case "$choice" in
            1) add_todo_task ;;
            2) list_todo_tasks ;;
            3) return ;;
            *) echo "Invalid choice. Please select a valid option." ;;
        esac
    done
}

add_todo_task() {
    read -p "Enter task description: " task_description
    read -p "Enter task location: " task_location
    read -p "Enter weather condition (e.g., sunny, rainy): " task_condition

    # Save the task details to the to-do list file
    echo "Task Description: $task_description, Location: $task_location, Weather Condition: $task_condition" >> "$TODO_LIST_FILE"

    echo "To-Do Task Added:"
    echo "Description: $task_description"
    echo "Location: $task_location"
    echo "Weather Condition: $task_condition"
}

list_todo_tasks() {
    if [ -f "$TODO_LIST_FILE" ]; then
        echo "Weather-Dependent To-Do Tasks:"
        cat "$TODO_LIST_FILE"
    } else {
        echo "No to-do tasks added."
    }
}

gardening_planner() {
    load_user_preferences
    echo "Weather-Based Gardening Planner:"
    read -p "Enter the type of gardening task you want to plan (e.g., 'water plants', 'fertilize garden'): " gardening_task

    echo "Weather Condition for Gardening Task:"
    read -p "Enter the desired weather condition (e.g., sunny, rainy) for your task: " desired_weather_condition

    echo "Gardening Task: $gardening_task"
    echo "Desired Weather Condition: $desired_weather_condition"

    current_weather_description=$(get_weather_description)

    echo "Current Weather Description: $current_weather_description"

    if [ "$current_weather_description" == "$desired_weather_condition" ]; then
        echo "The weather is suitable for your gardening task: $gardening_task"
    else {
        echo "The weather is not suitable for your gardening task: $gardening_task"
    }
}

get_weather_description() {
    # Fetch weather data from the API for the specified location
    API_URL="http://api.openweathermap.org/data/2.5/weather?q=$(tr '[:upper:]' '[:lower:]' <<< "$DEFAULT_LOCATION")&appid=$API_KEY&units=$DEFAULT_TEMP_UNIT"

    wget -qO- "$API_URL" > weather_data.json

    if [ $? -ne 0 ]; then
        echo "Error fetching weather data. Please check your internet connection or API key."
        exit 1
    fi

    description=$(grep -o '"description":"[^"]*' weather_data.json | cut -d'"' -f4)

    rm weather_data.json

    echo "$description"
}

list_events() {
    if [ -f "$EVENTS_FILE" ]; then
        echo "Scheduled Events:"
        cat "$EVENTS_FILE"
    } else {
        echo "No events scheduled."
    }
}

add_event() {
    read -p "Enter event name: " event_name
    read -p "Enter event date (YYYY-MM-DD): " event_date
    read -p "Enter event location: " event_location

    # Save the event details to the events file
    echo "Event Name: $event_name, Event Date: $event_date, Event Location: $event_location" >> "$EVENTS_FILE"

    echo "Event Scheduled:"
    echo "Event Name: $event_name"
    echo "Event Date: $event_date"
    echo "Event Location: $event_location"
}

list_events_and_tasks() {
    echo "Scheduled Events:"
    list_events

    echo "Weather-Dependent To-Do Tasks:"
    list_todo_tasks
}

show_main_menu
