PANDOC=pandoc --data-dir=. --template=default.html --katex

all:
	$(PANDOC) -s intro.md -o intro.html

clean:
	rm intro.html