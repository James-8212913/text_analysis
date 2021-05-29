#!/bin/bash

# Pandoc Conversion Script
echo 'Converting Markdown to PDF'
pandoc \
assignment_3_a.md \
ass_3.yaml \
--template eisvogel \
--listings \
--highlight-style pygments \
--citeproc \
--csl data-science-journal.csl \
-s \
-o assignment_3_a.pdf
echo 'Finished'


#pandoc -f markdown+yaml_meta_block\
#--filter=citeproc \
#--bibliography=Tax_biblio.bib \
#assignment_3_b.md dvn_assignment_3_b.yaml \
#-o assignment_3_b.pdf \
#--from markdown+table_captions+pipe_tables \
#--template eisvogel --listings
