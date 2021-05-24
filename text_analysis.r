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

#------------------------------------------------------------------------------#
# Load Data                                                                  ####
#------------------------------------------------------------------------------#

file_list <- list.files(path = "." , recursive = TRUE,
                        pattern = ".*.txt",
                        full.names = TRUE)

text_df <- readtext(paste0(file_list))

# view(text_df)

# The plan is to analyse each file then consider the topics in each file ----

tidy_text <- text_df %>% 
  unnest_tokens(word, text)

tidy_text

tidy_text <- tidy_text %>% 
  anti_join(stop_words)
tidy_text %>% 
  count(word, sort = TRUE) 
 tidy_text %>% 
   count(word, sort = TRUE) %>%
   filter(n >100) %>% 
   mutate(word = reorder(word, n)) %>% 
   ggplot(aes(n,word)) +
   geom_col() +
   labs(y = NULL)
 