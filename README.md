# README

This is my ruby on rails webiste

The site is dockerized, and can be run locally by
- clone the repo: 
$ git@github.com:rysc3/web.git
- create docker comopse 
$ cp docker-compose.yml.tmpl docker-compose.yml
- Build docker container 
$ docker compose build
- Run local instance 
$ docker compose up 

### Other important docker commands:
# connect to the running container
$ docker exec web-web-1 -i -t bash

# Run docker container just in command line
$ docker compose run web bash


- Implemented theme via bootstrap
- Connect to github repo
- Connect to heroku w/ github CI (program auto builds/deploys each time a push is made to main branch)
- Connect to custom domain, ryanscherbarth.com via google domains
- Configure SSL certificates through *.heroku-app.com

To Precompile all assets in the /assets dir:
$ bundle exec rake assets:precompile
