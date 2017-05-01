build:
	mvn clean package
	docker build -t hello-ecs:latest -t 689973912904.dkr.ecr.us-west-2.amazonaws.com/hello-ecs:latest .

deploy: build
	docker push 689973912904.dkr.ecr.us-west-2.amazonaws.com/hello-ecs:latest
