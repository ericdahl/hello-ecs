build:
	mvn clean install
	docker build --tag 'hello-ecs-app:latest' --tag 'gcr.io/striped-weaver-161318/hello-k8s-app' .

deploy: build
	gcloud docker -- push gcr.io/striped-weaver-161318/hello-ecs-app
