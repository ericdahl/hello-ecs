# TODO: fix date logic; avoid regen
#TAG = `date "+%Y%m%d-%H%M"`-`git rev-parse --short HEAD`
TAG = `git rev-parse --short HEAD`

build:
	docker build -t hello-ecs:$(TAG) .
	docker tag hello-ecs:$(TAG) ericdahl/hello-ecs:latest
	docker tag hello-ecs:$(TAG) ericdahl/hello-ecs:$(TAG)
	echo "Built hello-ecs:$(TAG)"

deploy: build
	docker push ericdahl/hello-ecs:$(TAG)
	echo "Pushed ericdahl/dockhello-ecs:$(TAG)"

test:
	echo $(C)