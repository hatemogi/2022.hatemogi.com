PANDOC=pandoc --data-dir=. --template=default.html --katex

all:
	$(PANDOC) -s index.md -o docs/index.html
	$(PANDOC) -s note/intro.md -o docs/intro.html
	$(PANDOC) -s note/senior-dev.md -o docs/senior-dev.html
	$(PANDOC) -s note/developer-rank.md -o docs/developer-rank.html
	$(PANDOC) -s note/docker-spring.md -o docs/docker-spring.html
	cp -r img/* docs/img/

clean:
	rm docs/intro.html
	rm docs/index.html
	rm docs/senior-dev.html
	rm docs/developer-rank.html
	rm docs/docker-spring.html