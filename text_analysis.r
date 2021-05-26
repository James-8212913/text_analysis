#------------------------------------------------------------------------------#
#                                                                              #
#    Title      : Text Analysis                                                        #
#    Purpose    : categorise .txt files following analysis                                                #
#    Notes      : Data is in file /data                                              #
#    Author     : James                                                     #
#    Created    : 24/May/2021                                                  #
#    References : References                                                   #
#    Sources    : Sources                                                      #
#    Edited     : 24/May/2021 - Initial creation                               #
#                                                                              #
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
# load packages####
#------------------------------------------------------------------------------#

library(tidyverse)
library(tidytext)
library(tidymodels)
library(readtext)
library(stopwords)
library(topicmodels)
library(textclean)
library(tm)

#------------------------------------------------------------------------------#
# Load Data                                                                  ####
#------------------------------------------------------------------------------#

file_list <- list.files(path = "." , recursive = TRUE,
                        pattern = ".*.txt",
                        full.names = TRUE) 

text_df <- readtext(paste0(file_list))
text_df # a df with each file as a 'row' against the file name

# view(text_df)

# Exploratory Analysis on each text file ----

## The text df was broken into tokens in an effort to get a better understanding of how many different words there were and what the counts of each of the words were. Stop_words have been removed as part of the analysis. The filter was set to 8 as part of trail and error - it isn't suitable for all files but is a good start point to sharpen the focus and get a feel for what is in each file. 

text_tidy <- text_df %>% 
   unnest_tokens(word, text) %>% 
   anti_join(stop_words) %>%
   group_by(doc_id) %>% 
   count(word,sort = TRUE) %>% 
   filter(n >8)

text_tidy

plot_list <- text_tidy %>% 
   group_split() %>% 
   map(~ggplot(., aes(n, word)) +
          geom_col() +
          labs(y = NULL,
               title = .$doc_id))
# View the Plots for each file as part of EDA - the plot number corresponds with the file number nfor future reference.

plot_list[[7]]

# Check the files for word importance using Zipf's Law which states that the most common words are those that are generally the least important in the documents. 

text_imp <- text_df %>% 
   unnest_tokens(word, text) %>% 
   count(doc_id, word, sort = TRUE) %>% 
   group_by(doc_id) %>% 
   bind_tf_idf(word, doc_id,n) %>% 
   arrange(desc(tf_idf)) 
   group_by(doc_id)

text_imp

text_df %>% 
   filter(str_detect(text, "_t")) %>% 
   select(text)

## Outcome - there appears to be 3-4 topics in the files - risk management/ organisational management/ machine learning and a general statistics flavour across the 42 files

## Continuing on to determine relationships between words in an n-gram format.


text_tidy_1 <- text_df %>% 
   unnest_tokens(bigram, text, token = "ngrams", n = 3) %>% 
   group_by(doc_id) %>% 
   count(bigram, sort = TRUE) 

text_tidy_1

# Separate the bigrams before removing the stop words to remove trivial collections of words

text_tidy_1_s <- text_tidy_1 %>% 
   separate(bigram, c("word1", "word2", "word3"), sep = " ")

text_tidy_1_s

plots_list_1 <- text_tidy_1_s %>% 
   filter(!word1 %in% stop_words$word) %>% 
   filter(!word2 %in% stop_words$word) %>% 
   filter(!word3 %in% stop_words$word) %>% 
   unite(bigram, word1, word2, word3, sep = " ") %>% 
   group_by(doc_id) %>% 
   filter(n > 2) %>% 
   group_split() %>% 
   map(~ggplot(., aes(n, bigram)) +
          geom_col() +
          labs(y = NULL,
               title = .$doc_id))

plots_list_1

## Outcome - The text needs a little more tidying but the next step will be to see if we can model into the topics.

# Topic modelling ----

# First step is to cast the tidy data into a document term matrix - this is the format that is used when using the LDA unsupervised techniques

text_dtm <- text_df %>% 
   unnest_tokens(word, text) %>% 
   anti_join(stop_words) %>% 
   count(doc_id, word) %>% 
   cast_dtm(doc_id, word, n)

text_dtm

text_topics <- LDA(text_dtm, k = 5, control = list(seed = 9864))

tidy_t_t_b <- tidy(text_topics, matrix = "beta")


text_top_10 <- tidy_t_t %>% 
   group_by(topic) %>% 
   slice_max(beta, n = 10) %>% 
   ungroup() %>% 
   arrange(topic, -beta)

## Graph the terms in the documents

text_top_10 %>% 
   mutate(term = reorder_within(term, beta, topic)) %>% 
   ggplot(aes(beta, term, fill = factor(topic))) +
   geom_col(show.legend = FALSE) +
   facet_wrap(~ topic, scales = "free") +
   scale_y_reordered()

tidy_t_t_g <- tidy(text_topics, matrix = "gamma")

tidy_t_t_g %>% 
   arrange(desc(gamma))




