VERSION := $(shell cat VERSION)
IMAGE   := rubykube/redmine:$(VERSION)

.PHONY: default build push run ci deploy

default: build run

build:
	@echo '> Building "redmine" docker image...'
	@docker build -t $(IMAGE) .

push: build
	docker push $(IMAGE)

run:
	@echo '> Starting "redmine" container...'
	@docker run -d --env=MYSQL_ROOT_PASSWORD=changeme --name=redmine-mariadb -p 3306:3306 mysql:5.7
	@docker run -p 8080:8080 --link redmine-mariadb:redmine-mariadb -e "DATABASE_HOST=redmine-mariadb" -e "DATABASE_USER=root" -e "DATABASE_PASSWORD=changeme" -d $(IMAGE)

ci:
	@fly -t ci set-pipeline -p redmine -c config/pipelines/review.yml -n
	@fly -t ci unpause-pipeline -p redmine

deploy: push
	@helm install ./config/charts/redmine --set "image.tag=$(VERSION)"
