.PHONY: run
run:
	docker build -t pmchs . && docker run pmchs
