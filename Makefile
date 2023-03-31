build:
	docker compose up build
	docker build -t s:1 .

test:
	docker compose up example