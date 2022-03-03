PWD=$(shell pwd)
login:
	@echo 'login to acr'
	@echo '${DOCKER_PWD}' | docker login -u '${DOCKER_USER}' --password-stdin '${DOCKER_REMOTE_HOST}'
build:
	@echo 'building image'
	@docker build -t '${DOCKER_REMOTE_HOST}'/sftp-imagen:${IMAGE_VERSION} ${PWD}/sftp-image
push:
	@echo 'pushing image'
	@docker push '${DOCKER_REMOTE_HOST}'/sftp-imagen:${IMAGE_VERSION}
all: login build push