build:
	@docker build -t ${REGISTRY}/${IMAGE}:${VERSION} .
run:
	@docker run --rm -p ${HOST_PORT}:22 ${REGISTRY}/${IMAGE}:${VERSION}
push:
	@docker push ${REGISTRY}/${IMAGE}:${VERSION}