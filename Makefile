build:
	docker compose up build
	docker build -t s:1 .

gem:
	docker compose up build
	
test:
	docker compose up example