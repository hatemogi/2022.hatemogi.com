PANDOC=pandoc --data-dir=. --template=default.html --katex

all:
	$(PANDOC) -s intro.md -o docs/intro.html

clean:
	rm docs/intro.html