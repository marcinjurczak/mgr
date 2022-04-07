.PHONY: all clean

all: mgr.pdf

mgr.pdf: mgr.tex
	latexmk -pdf -pdflatex="pdflatex -interaction=nonstopmode" -use-make mgr.tex

clean:
	latexmk -CA
