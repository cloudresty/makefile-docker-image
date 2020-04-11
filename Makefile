#   ____ _                 _               _         
#  / ___| | ___  _   _  __| |_ __ ___  ___| |_ _   _ 
# | |   | |/ _ \| | | |/ _` | '__/ _ \/ __| __| | | |
# | |___| | (_) | |_| | (_| | | |  __/\__ \ |_| |_| |
#  \____|_|\___/ \__,_|\__,_|_|  \___||___/\__|\__, |
#                                              |___/ 
#
#  Makefile for Docker Images - v1.0.0
#  https://github.com/cloudresty/makefile-docker-image
#

# Import environment variables from .env file
include .env
export

# Docker Image
IMG_NAME 			= $(ENV_REP_NAME)/$(ENV_REP_IMG_NAME)
IMG_LATEST_VER		= $(IMG_NAME):latest
IMG_MINOR_VER 		= $(IMG_NAME):$$(PATCH=$(ENV_REP_IMG_TAG); MINOR="$$(cut -d '.' -f 1 <<< "$$PATCH")"."$$(cut -d '.' -f 2 <<< "$$PATCH")"; echo $$MINOR;)
IMG_PATCH_VER		= $(IMG_NAME):$(ENV_REP_IMG_TAG)

IMG_DET_IMG_VENDOR 	= $(ENV_DET_IMG_VENDOR)
IMG_DET_IMG_NAME 	= $(ENV_DET_IMG_NAME)
IMG_DET_IMG_DESC	= $(ENV_DET_IMG_DESC)
IMG_DET_IMG_URL		= $(ENV_DET_IMG_URL)
IMG_DET_IMG_VER 	= $(ENV_DET_IMG_VER)
IMG_DET_BLD_DATE 	= $$(date -u +"%Y-%m-%dT%H:%M:%SZ")
IMG_DET_VCS_REF 	= $$(git rev-parse --short HEAD)
IMG_DET_VCS_URL 	= $$(git config --get remote.origin.url)
IMG_DET_IMG_DCK_CMD	= $(ENV_DET_IMG_DCK_CMD)
IMG_DET_IMG_SCH_VER = $(ENV_DET_IMG_SCH_VER)

# Docker Container Shortcuts
CON_GENERAL_FILTER 	= docker ps -q --filter ancestor="$(IMG_PATCH_VER)"
CON_RUNNING_FILTER 	= $(CON_GENERAL_FILTER) --filter status="running"
CON_EXITED_FILTER 	= $(CON_GENERAL_FILTER) --filter status="exited"

# Commands to be executed
CMD_DOCKER_BUILD 	= docker build --no-cache -t $(IMG_PATCH_VER) \
					--label=org.label-schema.vendor=$(IMG_DET_IMG_VENDOR) \
					--label=org.label-schema.name=$(IMG_DET_IMG_NAME) \
					--label=org.label-schema.description=$(IMG_DET_IMG_DESC) \
					--label=org.label-schema.url=$(IMG_DET_IMG_URL) \
					--label=org.label-schema.version=$(IMG_DET_IMG_VER) \
					--label=org.label-schema.build-date=$(IMG_DET_BLD_DATE) \
					--label=org.label-schema.vcs-ref=$(IMG_DET_VCS_REF) \
					--label=org.label-schema.vcs-url=$(IMG_DET_VCS_URL) \
					--label=org.label-schema.docker.cmd=$(IMG_DET_IMG_DCK_CMD) \
					--label=org.label-schema.schema-version=$(IMG_DET_IMG_SCH_VER) \
					.
CMD_DOCKER_RUN 		= docker run -d -p $(ENV_CON_PORTS) $(IMG_PATCH_VER) >> /dev/null 2>&1
CMD_DOCKER_STOP 	= docker stop $$($(CON_RUNNING_FILTER)) >> /dev/null 2>&1
CMD_DOCKER_RESTART 	= $(CMD_DOCKER_STOP); \
					  docker start $$($(CON_EXITED_FILTER) | sed -n 1p) >> /dev/null 2>&1
CMD_DOCKER_STATUS 	= $(CON_RUNNING_FILTER)
CMD_DOCKER_SHELL 	= docker exec -it $$($(CON_RUNNING_FILTER)) /bin/sh
CMD_DOCKER_LOG 		= docker logs -f $$($(CON_RUNNING_FILTER))
CMD_DOCKER_RELEASE 	= echo $(MSG_INFO) "Creating 'Latest Version Release' tag: $(IMG_LATEST_VER)..." && \
					  docker tag $(IMG_PATCH_VER) $(IMG_LATEST_VER) && \
					  echo $(MSG_INFO) "Tag has been successfully created..." && \
					  echo $(MSG_INFO) "Creating 'Minor Version Release' tag: $(IMG_MINOR_VER)..." && \
					  docker tag $(IMG_PATCH_VER) $(IMG_MINOR_VER) && \
					  echo $(MSG_INFO) "Tag has been successfully created..."
CMD_DOCKER_PUSH 	= echo $(MSG_INFO) "Pushing $(IMG_LATEST_VER)..." && \
					  docker push $(IMG_LATEST_VER) && \
					  echo $(MSG_INFO) "Completed..." && \
					  echo $(MSG_INFO) "Pushing $(IMG_MINOR_VER)..." && \
					  docker push $(IMG_MINOR_VER) && \
					  echo $(MSG_INFO) "Completed..." && \
					  echo $(MSG_INFO) "Pushing $(IMG_PATCH_VER)..." && \
					  docker push $(IMG_PATCH_VER) && \
					  echo $(MSG_INFO) "Completed..."
CMD_DOCKER_CLEAN 	= echo $(MSG_INFO) "Removing container(s):" $$($(CON_EXITED_FILTER)) && \
					  $(CON_EXITED_FILTER) | xargs docker container rm --force >> /dev/null 2>&1
CMD_DOCKER_LOGIN 	= docker login -u $(REG_USERNAME) -p $(REG_PASSWORD)

# Message type
MSG_INFO 			= "\033[32mINFO\033[0m\t | "
MSG_DONE 			= "\033[32mDONE\033[0m\t | "
MSG_WARNING 		= "\033[33mWARNING\033[0m\t | "
MSG_ERROR 			= "\033[31mERROR\033[0m\t | "

.PHONY: help build run stop restart status shell log release push clean login

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

build: ## Build Docker image based on the environment variables provided
	@echo $(MSG_INFO) "Image $(IMG_NAME) build started..."
	@$(CMD_DOCKER_BUILD) && echo $(MSG_DONE) "Build successfully completed..." && exit 0 || echo $(MSG_ERROR) "Something went wrong, cannot build specificed image..."

run: ## Run the image in a Docker container
	@echo $(MSG_INFO) "Starting a Docker container using $(IMG_PATCH_VER) image..."
	@$(CMD_DOCKER_RUN) && echo $(MSG_DONE) "Container $$($(CON_GENERAL_FILTER)) has been successfully started..." && exit 0 || echo $(MSG_ERROR) "Requested container cannot be started. Check if the image is present or if the container isn't already running..."

stop: ## Stop the Docker container that runs on this image
	@echo $(MSG_INFO) "Stoping container $$($(CON_RUNNING_FILTER))..."
	@$(CMD_DOCKER_STOP) && echo $(MSG_DONE) "Container has been successfully stoped..." && exit 0 || echo $(MSG_ERROR) "No running container found based on $(IMG_NAME) image..."

restart: ## Restart the container that runs the the image
	@echo $(MSG_INFO) "Trying to restart the container..."
	@$(CMD_DOCKER_RESTART) && echo $(MSG_DONE) "Container $$($(CON_GENERAL_FILTER)) has been successfully restarted..." && exit 0 || echo $(MSG_WARNING) "Can't find any containers using this image (running or not). I'll try "'"make run"'"..." && make run

status: ## Check if any container is runing using the current image version
	@echo $(MSG_INFO) "Checking Docker status..."
	@$(CMD_DOCKER_STATUS)

shell: ## Access the running container based on this image
	@echo $(MSG_INFO) "Opening Docker shell for container $$($(CON_RUNNING_FILTER))..."
	@$(CMD_DOCKER_SHELL) && echo "\n"$(MSG_DONE) "Shell succesfully closed..." || echo $(MSG_ERROR) "Cannot open the shell, ther's no container running..."

log: ## Show container log output
	@echo "\n"$(MSG_INFO) "Showing container $$($(CON_RUNNING_FILTER)) logs:\n"
	@$(CMD_DOCKER_LOG) && echo "\n"$(MSG_DONE) "Logging succesfully closed..." || echo $(MSG_ERROR) "Cannot open the logs, ther's no container running..."

release: ## Tag the image as new release (Example: latest, 1.10, 1.10.19)
	@echo $(MSG_INFO) "Starting releases tagging..."
	@$(CMD_DOCKER_RELEASE) && echo $(MSG_DONE) "Tagging process completed..." || echo $(MSG_ERROR) "Cannot apply tagging for releases..."

push: ## Push the image to your repository defined in the .env file
	@echo $(MSG_INFO) "Starting image push process..."
	@$(CMD_DOCKER_PUSH) && echo $(MSG_DONE) "All images were successfully pushed to Docker repository..." || echo $(MSG_ERROR) "Cannot push images to Docker registry..."

clean: ## Remove all Docker containers that are not running and were using this image
	@echo $(MSG_INFO) "Removing all unused / inactive containers based on $(IMG_PATCH_VER)..."
	@$(CMD_DOCKER_CLEAN) && echo $(MSG_DONE) "Cleaning completed..." || echo $(MSG_ERROR) "Cannot remove some unused containers..."

login: ## Docker registry login, this have to be defined within .env file
	@$(CMD_DOCKER_LOGIN)