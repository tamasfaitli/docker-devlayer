# Introduction

A docker image that can be built on top of existing images, bringing one's Neovim developent setup inside the container. Write, debug and test code straight where all your dependencies are available and easily parseble.

# Workflow:

1. During project setup:
    1. Create a docker image with all project-related dependencies installed
    2. Define a new service node in the docker compose file, where you build a new image using the devlayer dockerfile on top of the one created in :1
2. Development:
    1. Run docker compose up detached
    2. Join the container using "docker exec -it container bash"
    3. Launch tmux for session control (if you leave the container, you can join back any time while docker compose is up)
    4. Enjoy!



