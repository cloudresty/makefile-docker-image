# Makefile for Docker Images
This *Makefile* can be used to speed up the process of building, running, interacting and publishing your Docker images.

## Requirements
- Dockerfile
- .env

## Usage
This *Makefile* must be placed in the same folder where your *Dockerfile* is.
```
help                           This help output
build                          Build Docker image based on the environment variables provided
run                            Run the image in a Docker container
stop                           Stop the Docker container that runs on this image
restart                        Restart the container that runs the the image
status                         Check if any container is running using the current image version
shell                          Shell access the running container based on this image
log                            Show container log output
release                        Tag the image as new release (Example: latest, 1.10, 1.10.19)
push                           Push the image to your repository defined in the .env file
clean                          Remove all Docker containers that are not running and were using this image
login                          Docker registry login, credentials must be defined within .env file
```

### Contributors
- Sebastian Gogoasa (GitHub: [SebastianGogoasa](https://github.com/SebastianGogoasa))