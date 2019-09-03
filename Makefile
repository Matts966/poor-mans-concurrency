.PHONY: run
run:
	docker build -t pmchs . && docker run --rm pmchs
