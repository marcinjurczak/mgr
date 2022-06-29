.PHONY: all mgr clean

all: mgr

mgr: mgr.tex
	latexmk -pdf -pdflatex="pdflatex -interaction=nonstopmode" -use-make mgr.tex

clean:
	latexmk -CA
