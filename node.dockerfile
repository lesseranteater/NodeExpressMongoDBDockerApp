# Build: docker build -f node.dockerfile -t danwahlin/nodeapp .

# Option 1: Create a custom bridge network and add containers into it

# docker network create --driver bridge isolated_network
# docker run -d --net=isolated_network --name mongodb mongo

# NOTE: $(pwd) in the following line is for Mac and Linux. See https://blog.codewithdan.com/docker-volumes-and-print-working-directory-pwd/ for Windows examples.
# docker run -d --net=isolated_network --name nodeapp -p 3000:3000 -v $(pwd)/logs:/var/www/logs danwahlin/nodeapp

# Seed the database with sample database
# Run: docker exec nodeapp node dbSeeder.js

# Option 2 (Legacy Linking - this is the OLD way)
# Start MongoDB and Node (link Node to MongoDB container with legacy linking)

# docker run -d --name my-mongodb mongo
# docker run -d -p 3000:3000 --link my-mongodb:mongodb --name nodeapp danwahlin/nodeapp

# use an LTS version of node
FROM        node:16.13.1-alpine

LABEL       author="Dan Wahlin"

ARG         buildversion

ENV         NODE_ENV=production
ENV         PORT=3000
ENV         build=$buildversion

WORKDIR     /var/www
COPY        package.json package-lock.json ./
# we could have also used a wildcard: package*.json ./
RUN         npm install

# the second dot stands for the working directory
# we could have used the following instead but we use the dot to avoid duplication:
# COPY        . /var/www
# Copy everything except what is in .dockerignore
COPY        . ./
EXPOSE      $PORT

RUN         echo "Build version: $build"

ENTRYPOINT  ["npm", "start"]
