NAME=$(shell basename $(PWD))

PYTHON:=3.7

DOCKER=docker run \
	   --rm -it \
	   --name $(NAME)-tests \
	   -v $(PWD):/$(NAME) \
	   --rm $(NAME):latest

.PHONY: docker
docker:
	docker build \
	--build-arg PYTHON=$(PYTHON) \
	--build-arg NAME=$(NAME) \
	-t $(NAME):latest \
	-f Dockerfile \
	.

.PHONY: pytest
pytest:
	rm -f docs/source/tutorials/out_files/*.txt
	poetry run pytest --nbval -vs ${ARGS} docs/source/tutorials

.PHONY: black
black:
	poetry run black --check .

.PHONY: pylama
pylama:
	poetry run pylama .

.PHONY: mypy
mypy:
	poetry run mypy nornir_utils

.PHONY: tests
tests: black pylama mypy pytest

.PHONY: docker-tests
docker-tests: docker
	$(DOCKER) make tests

.PHONY: jupyter
jupyter:
	docker run \
	--name $(NAME)-jupyter --rm \
	-v $(PWD):/$(NAME) \
	-p 8888:8888 \
	$(NAME):latest \
		jupyter notebook \
			--allow-root \
			--ip 0.0.0.0

.PHONY: docs
docs:
	make -C docs html
