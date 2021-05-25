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

# Exploratory Analysis on each text file ----

## The text df was broken into tokens in an effor to get a better understanding of how many different word there were and what the counts of each of the words were. Stop_words have been removed as part of the analysis. The filter was set to 8 as part of trail and error - it isn't suitable for all files but is a good start point to sharpen the focus and get a feel for what is in each file. 

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
# View the Plots for each file as part of EDA
plot_list





