# My Weight Loss Pal
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
This branch contains the code for the flask API, which hosts the back end algorithm responsible for coming up with the following day calories suggestion.
