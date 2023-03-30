build:
	docker.exe compose up build
	docker.exe build -t s:1 .

test:
	docker.exe compose up example