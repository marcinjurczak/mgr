# Praca magisterska

[![build-elm](https://github.com/marcinjurczak/mgr/actions/workflows/build_elm.yml/badge.svg)](https://github.com/marcinjurczak/mgr/actions/workflows/build_elm.yml)
[![build-latex](https://github.com/marcinjurczak/mgr/actions/workflows/build_latex.yml/badge.svg)](https://github.com/marcinjurczak/mgr/actions/workflows/build_latex.yml)

To repozytorium będzie zawierać wyniki mojej pracy magisterskiej, której tematem jest "Wykorzystanie języka ELM do tworzenia aplikacji frontendowych". Praca jest wykonywana na Politechnice Gdańskiej, w Katedrze Algorytmów i Modelowania Systemów, pod przewodnictwem dra inż. Krzysztofa Manuszewskiego.

## Część praktyczna

W ramach części praktycznej wytworzona zostanie aplikacja internetowa typu *startpage*, czyli strony startowej przeglądarki zawierającej, w moim przypadku, takie funkcjonalności jak:

- [x] Aktualny czas
- [x] Pogoda w Gdańsku (opis pogody + temperatura)
- [x] Wyszukiwarka Google
- [x] Zbiór zakładek składających się z najczęściej używanych stron internetowych
- [ ] //TODO

Całość implementacji zostanie wykonana z wykorzystaniem funkcyjnego języka Elm.

Aby uruchomić aplikację należy skompilować kod, używając komendy:
```sh
elm make src/Main.elm --output=assets/main.js
```
Następnie uruchomić ją poleceniem `elm reactor`.

Aktualny stan aplikacji można zobaczyć z użyciem [Github Pages](https://marcinjurczak.github.io/mgr/).

## Część teoretyczna

Część opisowa pracy magisterskiej zostanie napisana z użyciem LaTeX'a na podstawie [szablonu](https://www.overleaf.com/latex/templates/gdansk-university-of-technology-thesis-template/tngwxnzvzzqb) przygotowanego przez dra inż. Tomasza Boińskiego z Politechniki Gdańskiej.
