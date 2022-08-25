PANDOC=pandoc --data-dir=. --template=default.html --katex --highlight-style=kate

all:
	$(PANDOC) -s index.md -o docs/index.html
	$(PANDOC) -s note/intro.md -o docs/intro.html
	$(PANDOC) -s note/senior-dev.md -o docs/senior-dev.html
	$(PANDOC) -s note/developer-rank.md -o docs/developer-rank.html
	$(PANDOC) -s note/docker-spring.md -o docs/docker-spring.html
	$(PANDOC) -s note/amazon-sqs.md -o docs/amazon-sqs.html
	$(PANDOC) -s note/amazon-eks-1.md -o docs/amazon-eks-1.html
	cp docs/amazon-eks-1.html docs/amazon-eks.html
	$(PANDOC) -s note/amazon-eks-2.md -o docs/amazon-eks-2.html
	$(PANDOC) -s note/haskell-challenging.md -o docs/haskell-challenging.html
	$(PANDOC) -s note/salary-developer.md -o docs/salary-developer.html
	cp -r img/* docs/img/

md: note/*.md
	echo $@

clean:
	rm docs/intro.html
	rm docs/index.html
	rm docs/senior-dev.html
	rm docs/developer-rank.html
	rm docs/docker-spring.html
	rm docs/amazon-sqs.html
	rm docs/amazon-eks.html