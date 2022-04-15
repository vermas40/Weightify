# Weightify
It is a web app that helps users track their weight & calories consumed on a daily basis, and in turn suggests how many calories to eat the next day to stay true to their weight change goal.

## Motivation
My motivation to take on this project was to create a centrally hosted web app that anyone can access from anywhere using any device to enter the relevant details and continue their weight change journey. 

## Problem Statement
There are various tools in the market that provide users with the functionality to track their weight and calories consumed, however, there is no tool that can suggest how many calories to eat the following day. With my web app and the basic backend algorithm, I intend to provide a solution for the same.

## Learnings
Aside from creating the web app, a secondary goal was to learn the tech stack that goes into making a web app. The tech stack used here is:
- R Shiny
- Flask
- Docker

While I was already aware of how to use flask and R Shiny, through this project I was able to understand the inner workings of docker and deploy it.

## Way around the repository
There are 3 branches present in this repository:
- master
- python-api
- shiny-app

### master
This branch contains the docker compose file that brings up the containers for the API & web app. Alongside this, it also includes the SQLite database that stores the data used in the application.

### python-api
This branch contains the code for the flask API, which helps in serving the back end algorithm responsible for coming up with the following day calories suggestion. Some of the important files to take note of in this branch are:
- Dockerfile: This file helps in setting up the python environment and installing the required libraries for the smooth functioning of the flask API
- helper_functions.py: This file contains all the python functions that help in implementing the backend algorithm
- app.py: This file helps in defining the API URLs and bringing up the API itself

### shiny-app
This branch contains the code for the web app. Some of the important files to take note of in this branch are:
- Dockerfile: This file helps in setting up the R environment and installing the required libraries for the smooth functioning of the R Shiny web app
- functions/helper_functions.R: This file contains all the R functions that help with the inner workings of the web app
- app.R: This file orchestrates the whole web app by calling numerous user defines shiny modules and bringing up the application

# Quick Look
<p align="center">
  <img src="https://media.giphy.com/media/tHsQu2fjMsWq6S9IA9/giphy.gif" alt="animated" />
</p>

# Current State & Offline set up process
The application is currently not deployed on the web, owing to time limitations and other commitments. However, it can still be setup on any machine fairly easily. To achieve that, the below steps would have to be followed:
- Install docker on the machine you would like to run the app on and make sure it is running
- Open a terminal or CMD on the machine
- Clone the repository using this command on the terminal/CMD:
<br> git clone --recurse-submodules https://github.com/vermas40/Weightify.git
- Go inside the application folder using cd
- Run the below command once inside the folder & wait for docker to set up the environment as well as install dependencies:
<br> docker-compose up
- Put this address: http://0.0.0.0:4567 in your browser and you are ready to go!
