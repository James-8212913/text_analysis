#------------------------------------------------------------------------------#
#                                                                              #
#    Title      : Text Analysis                                                        #
#    Purpose    : Assessment Task                                                #
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

#------------------------------------------------------------------------------#
# Load Data                                                                  ####
#------------------------------------------------------------------------------#

file_list <- list.files(path = "." , recursive = TRUE,
                        pattern = ".*.txt",
                        full.names = TRUE) 

text_df <- readtext(paste0(file_list))
text_df # a df with each file as a 'row' agains the file name

# view(text_df)
text_tidy <- text_df %>% 
   unnest_tokens(word, text) 

text_tidy

data(stop_words)

text_tidy <- text_tidy %>% 
   anti_join(stop_words) %>% 
   group_by(doc_id) %>% 
   count(word, sort = TRUE) 
   

text_tidy

plot_list <- text_tidy %>% 
   group_split(doc_id) 
   filter(n > 5)
   map(~ggplot(., aes(n, word)) +
          geom_col() +
          labs(y = NULL))

   count(word, sort = TRUE) %>%
   filter(n >100) %>% 
   mutate(word = reorder(word, n)) %>% 
   ggplot(aes(n,word)) +
   geom_col() +
   labs(y = NULL)

text_tidy

tidy_text %>% 
   group_by(doc_id) %>% 
   count(word, sort = TRUE) %>%
   filter(n >100) %>% 
   mutate(word = reorder(word, n)) %>% 
   ggplot(aes(n,word)) +
   geom_col() +
   labs(y = NULL)

# The plan is to analyse each file then consider the topics in each file ----



tidy_text %>% 
  count(word, sort = TRUE) 
 tidy_text %>% 
   count(word, sort = TRUE) %>%
   filter(n >100) %>% 
   mutate(word = reorder(word, n)) %>% 
   ggplot(aes(n,word)) +
   geom_col() +
   labs(y = NULL)
 