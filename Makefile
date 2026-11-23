.PHONY: test lint docker-build run ansible-check deploy

test:
	pytest -q

lint:
	flake8 app tests --max-line-length 100

docker-build:
	docker build -t whoami:local .

run:
	docker compose up --build

ansible-check:
	ansible-playbook -i ansible/inventory/hosts.ini ansible/site.yml --syntax-check

deploy:
	ansible-playbook -i ansible/inventory/hosts.ini ansible/site.yml
