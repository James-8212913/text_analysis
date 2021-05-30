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
library(SnowballC)
library(cowplot)
library(wordcloud2)
library(knitr)
library(igraph)
library(ggraph)

#------------------------------------------------------------------------------#
# Load Data                                                                  ####
#------------------------------------------------------------------------------#

file_list <- list.files(path = "data" , recursive = TRUE,
                        pattern = "*.txt",
                        full.names = TRUE) 

file_list

text_df <- readtext(paste0(file_list))
text_df # a df with each file as a 'row' against the file name

# view(text_df)

# Exploratory Analysis on each text file ----

text_df_suummary <- text_df %>% 
   mutate(doc_id = as_factor(doc_id)) %>% 
   mutate(length_words = str_count(text, boundary("word"))) %>%
   mutate(length_sentences = str_count(text, boundary("sentence"))) %>% 
   mutate(length_paragraphs = str_count(text, boundary("line_break"))) %>% 
   arrange(desc(length_words)) 
summary(text_df_suummary)

## The text df was broken into tokens in an effort to get a better understanding of how many different words there were and what the counts of each of the words were. Stop_words have been removed as part of the analysis. The filter was set to 8 as part of trail and error - it isn't suitable for all files but is a good start point to sharpen the focus and get a feel for what is in each file. 



mystopwords <- as_tibble_col(c("t_", "_t", "docs", "figure", "min"), column_name = 'word')
mystopwords

stop_words <- get_stopwords(language = 'en', source = "smart")
stop_words <- bind_rows(stop_words, mystopwords)
stop_words

text_tidy_s <- text_df %>% 
   mutate(doc_id = as_factor(doc_id),
          text = str_remove_all(text, "[:digit:]")) %>% 
   unnest_tokens(word, text) %>% 
   anti_join(stop_words) %>%
   group_by(doc_id) %>% 
   count(word,sort = TRUE) 

## Wordcloud as part of term frequency across the entire folder - this is not specific to any of the individual files. 

wc <- text_df %>% 
   mutate(text = str_remove_all(text, "[:digit:]")) %>% 
   unnest_tokens(word, text) %>% 
   anti_join(stop_words) %>% 
   count(word, sort = TRUE)

wc
wc_p <- wordcloud2(data = wc)
wc_p

## Generate a table with the top 5 terms for each of the files for an annex in the finel report. 

tables <- text_tidy_s %>% 
   group_by(doc_id) %>% 
   slice_max(order_by = n, n = 5) %>% 
   nest() %>% 
   mutate(
      tables = map2(data, doc_id,
                    ~ kable(x = data)))

## To view the top 5 words for each file 
tables$tables

## Create a filtered tidy df that is filtered to the level for graphing withing the published environment. 

text_tidy <- text_tidy_s %>% filter(n >8)

text_tidy

## Plot the words that appear the most often in each of the files
# Term Frequency Plots ----

plot_list1 <- text_tidy %>% 
   nest() %>% 
   mutate(
      plot = map2(data, doc_id, 
                  ~ggplot(data = .x, aes(n, reorder(word, -n))) +
                     geom_col(aes(fill = n)) +
                     labs(y = NULL,
                          title = .y,
                          subtitle = "Term Frequency") +
                     theme_light() +
                     theme(legend.position = "none")))
                       
plot_list1 #inspect the DF that includes doc-id, data and the plots

plot_list1$plot[[1]] #Run this to view all plots in the viewing window

## Save the plots for future publication purposes 

map2(paste0('images/',plot_list1$doc_id, ".png"), plot_list1$plot, ggsave)

# Check the files for word importance using Zipf's Law which states that the most common words are those that are generally the least important in the documents. The top 5 terms have been taken to assess the context for each of the files. 

text_imp <- text_df %>% 
   unnest_tokens(word, text) %>% 
   anti_join(stop_words) %>%
   count(doc_id, word, sort = TRUE) %>% 
   group_by(doc_id) %>% 
   bind_tf_idf(word, doc_id,n) %>%
   slice_max(order_by = tf_idf, n = 5)

view(text_imp)

text_imp %>% 
   ggplot(aes(x = tf_idf, y = doc_id)) +
   geom_text(aes(label = word, colour = doc_id),size = 3, check_overlap =TRUE) +
   theme_light() +
   theme(legend.position = "none") +
   labs(title = "Zipf's top terms for each file") +
   xlab ("Term Frequency - Inverse Document Frequency (TF_IDF)") +
   ylab ("Document ID")

ggsave("zipfs.png", path = 'images')

## Select any strange or different terms that may need to be added to the stop words as part of ongoing analysis. 

text_df %>% 
   filter(str_detect(text, "_t")) %>% 
   select(text)

## Outcome - there appears to be between 4 and 6 broad topics in the files - risk management/ organisational management/ machine learning/ application of ML to risk management/ application of Data to management practices across the 42 files

## Continuing on to determine relationships between words in an n-gram format.

text_df

text_tidy_1 <- text_df %>% 
   mutate(doc_id = as_factor(doc_id),
          text = str_remove_all(text, "[:digit:]")) %>% 
   unnest_tokens(bigram, text, token = "ngrams", n = 2) %>%
   group_by(doc_id) %>% 
   count(bigram, sort = TRUE) 

text_tidy_1 

# Plot Bigrams ----
# Separate the bigrams before removing the stop words to remove trivial collections of words

text_tidy_1_s <- text_tidy_1 %>% 
   separate(bigram, c("word1", "word2"), sep = " ")

network_1 <- text_tidy_1_s %>% filter(!word1 %in% stop_words$word) %>% 
   filter(!word2 %in% stop_words$word) %>% 
   filter(n > 5) %>% 
   ungroup() %>% 
   select(word1, word2, n) %>% 
   graph_from_data_frame()

network_1
   
set.seed(12457)

network1_plot <- ggraph(network_1, layout = "fr") +
   geom_edge_link() +
   geom_node_point() +
   geom_node_text(aes(label = name, vjust = 1, hjust = 1))

network1_plot

ggsave(filename = "network1_plot.png", path = "images")


plots_list_1 <- text_tidy_1_s %>% 
   filter(!word1 %in% stop_words$word) %>% 
   filter(!word2 %in% stop_words$word) %>% 
   unite(bigram, word1, word2, sep = " ") %>% 
   group_by(doc_id) %>% 
   filter(n > 2) %>% 
   nest() %>% 
   mutate(plots = map2(data, doc_id,
                   ~ggplot(data = .x, aes(n, reorder(bigram, -n)))+
                              geom_col(aes(fill = n)) +
                      labs(y = NULL,
                           x = "Number of Occurences",
                           title = .y) +
                      theme_light() +
                      theme(legend.position = "none")))

plots_list_1$plots[[1]]

## Save the Plots for future reference and publishing 

map2(paste0('images/',plots_list_1$doc_id, "bi.png"), plots_list_1$plots, ggsave)

## Outcome - The text needs a little more tidying but the next step will be to see if we can model into the topics.

# Topic modelling ----

# First step is to cast the tidy data into a document term matrix - this is the format that is used when using the LDA unsupervised techniques

text_dtm <- text_df %>%  
   mutate(text = str_remove_all(text, "[:digit:]")) %>% 
   mutate(text = str_trim(text, side = "both")) %>% 
   mutate(text = str_to_lower(text)) %>% 
   mutate(text = str_remove_all(text, "[:punct:]")) %>% 
   unnest_tokens(word, text) %>% 
   anti_join(stop_words) %>% 
   mutate(stem = wordStem(word)) %>%
   count(doc_id, stem) %>% 
   cast_dtm(doc_id, stem, n)

text_dtm

text_topics <- LDA(text_dtm, k = 6, control = list(seed = 9864))

tidy_t_t_b <- tidy(text_topics, matrix = "beta")

text_top_10 <- tidy_t_t_b %>% 
   group_by(topic) %>% 
   slice_max(beta, n = 15) %>% 
   ungroup() %>% 
   arrange(topic, -beta)

# Visualise the LDA findings ----

text_top_10 %>% 
   mutate(term = reorder_within(term, beta, topic)) %>% 
   ggplot(aes(beta, term, fill = factor(topic))) +
   geom_col(show.legend = FALSE) +
   facet_wrap(~ topic, scales = "free") +
   scale_y_reordered() 

ggsave(filename = "top_10_terms_topic.png", path = "images")

tidy_t_t_g <- tidy(text_topics, matrix = "gamma")

text_top_10_g <- tidy_t_t_g %>% 
   group_by(topic) %>% 
   slice_max(gamma, n = 20) %>% 
   ungroup() %>% 
   arrange(topic, -gamma) 

text_top_10_g

class_facet <- text_top_10_g %>% 
   ggplot(aes(factor(topic), gamma)) +
   geom_boxplot() +
   facet_wrap(~ document) +
   theme_light() +
   labs(title = "Classification of Documents into topics") +
   xlab("Topic") +
   ylab("Gamma")

class_facet

ggsave(filename = "topic_facet.png", path = "images")

## This is to gather files into topics where the gamma is greater than .7. This offers a reasonable amount of confidence that the file is in the correct topic. 

tables_1 <- text_top_10_g %>% 
   group_by(topic) %>% 
   arrange(desc(gamma)) %>% 
   filter(gamma > .7) %>% 
   nest() %>% 
   mutate(
      tables = map2(data, topic,
                    ~ kable(x = data)))

tables_1$tables

# Create Suggested file names to go in the topic folders ----

file_names <- text_imp %>% arrange(desc(tf_idf), doc_id) %>%  
   nest()

file_names <- file_names %>% 
   mutate(sug_name = map2(doc_id, data, ~ data %>%  
                             str_flatten() %>% 
                             str_remove_all("[:punct:]") %>% 
                             str_remove_all("[:digit:]") %>% 
                             str_match(" = c(.*) n ") %>% 
                             str_replace_all(" ", "_"))) %>% 
   select(doc_id, sug_name) %>% 
   unnest() %>% 
   filter(!grepl("=", sug_name)) %>% 
   mutate(
      file_name_sug = paste0(sug_name,"_", doc_id)
   ) %>%  
   select(file_name_sug) %>% 
   arrange(doc_id) %>% 
   kable()
                             
view(file_names)

