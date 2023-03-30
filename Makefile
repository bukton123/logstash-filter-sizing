build:
	docker.exe compose up build
	docker.exe build -t ls:1 .

test:
	docker.exe compose up example