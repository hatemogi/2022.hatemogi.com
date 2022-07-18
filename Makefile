PANDOC=pandoc --data-dir=. --template=default.html --katex

all:
	$(PANDOC) -s index.md -o docs/index.html
	$(PANDOC) -s intro.md -o docs/intro.html

clean:
	rm docs/intro.html
	rm docs/index.html