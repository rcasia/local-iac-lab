.PHONY: up down build tf-init tf-plan tf-apply tf-destroy test

up:
	docker compose up -d --wait

down:
	docker compose down -v

build:
	./infra/lambda/build.sh

tf-init:
	cd infra && terraform init

tf-plan:
	cd infra && terraform plan

tf-apply:
	cd infra && terraform apply -auto-approve

tf-destroy:
	cd infra && terraform destroy -auto-approve

test:
	USE_LOCAL=true ./tests/smoke.sh
