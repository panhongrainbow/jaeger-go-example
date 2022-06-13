all: start

orchestration ?= docker
builder ?= buildah

.PHONY: service-a
service-a:
ifeq (${orchestration}, podman)

ifeq (${builder}, buildah)
	@buildah bud -t service-a -f service-a/Dockerfile .
else
	@podman build -t service-a -f service-a/Dockerfile .
endif

else
	@docker build -t service-a -f service-a/Dockerfile .
endif

.PHONY: service-b
service-b:
ifeq (${orchestration}, podman)

ifeq (${builder}, buildah)
	@buildah bud -t service-b -f service-b/Dockerfile .
else
	@podman build -t service-b -f service-b/Dockerfile .
endif

else
	@docker build -t service-b -f service-b/Dockerfile .
endif

.PHONY: start
start: service-a service-b
ifeq (${orchestration}, podman)
	@podman-compose up -d --remove-orphans
else
	@docker-compose up -d --remove-orphans
endif

.PHONY: stop
stop:
ifeq (${orchestration}, podman)
	@podman-compose down
	podman rmi service-a service-b
	podman network rm jaeger-go-example_default
else
	@docker-compose down
	docker rmi service-a service-b
	docker network rm jaeger-go-example_default
endif
