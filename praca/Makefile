.PHONY: all mgr lab clean

all: mgr

mgr: mgr.tex
	latexmk -pdf -pdflatex="pdflatex -interaction=nonstopmode" -use-make mgr.tex

lab: lab.tex
	latexmk -pdf -pdflatex="pdflatex -interaction=nonstopmode" -use-make lab.tex

clean:
	latexmk -CA
