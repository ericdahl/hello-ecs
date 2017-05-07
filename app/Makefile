C = `date "+%Y%m%d-%H%M"`-`git rev-parse --short HEAD`

compile:
	mvn package

login:
	`aws ecr get-login --region us-west-2`

build: compile login
	docker build -t hello-ecs:$(C) .
	docker tag hello-ecs:$(C) hello-ecs:latest
	docker tag hello-ecs:$(C) 689973912904.dkr.ecr.us-west-2.amazonaws.com/hello-ecs:$(C)
	echo "Built hello-ecs:$(C)"

deploy: build
	docker push 689973912904.dkr.ecr.us-west-2.amazonaws.com/hello-ecs:$(C)
	echo "Pushed 689973912904.dkr.ecr.us-west-2.amazonaws.com/hello-ecs:$(C)"

test:
	echo $(C)