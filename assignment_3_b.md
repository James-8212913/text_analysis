## What does Text Analysis and Modelling offer the modern workplace?

If you just want the code it is at this link: https://github.com/James-8212913/text_analysis/blob/master/text_analysis.r . Please comment on this code and offer any suggestions or ways to improve it.

### The Problem - The case of the unnamed text files...

Your boss has just sent you an email - he has 42 text files that are unhelpfully named doc01.txt through to doc42.txt. In his email he is asking if you can help sort them out as he doesn't have time to take care of it and likely wont have time in the near future.

At first glance this seems like yet another *great day in the office*, seriously 42 text files that are unlabelled with no indication of what could possibly be in them. Where to start....

### The Solution - Text Analysis and a little unsupervised machine learning

Once we finish griping about the random task the boss has just given you there is a hint of opportunity that starts to surface in the back of your mind. You've recently been working on a little machine learning with R and this is just the chance you've been looking for to take what you've learned for a spin - importantly on a real world *problem*.

### The Plan

Of course, before you start this process you decide to make sure with the boss that there isn't likely to be anything sensitive of compromising in the files, they assure you that it's not likely and you can put the information on your local machine. You'd hate to take sensitive information off site potentially leaking it to the world by accident... Once the boss gives you the all clear you try to create a bit of a method for this. Cross Industry Standard Process for Data Mining (CRISP-DM)[^6d2f] is something your lecturers have been banging on about so you decide to give the process a chance and see how it turns out. This is the broad format we will use below.

The six steps of the process are:
-   Business Understanding
-   Data Understanding
-   Data preparation
-   Modeling
-   Evaluation

#### Business Understanding

You have a set of files, the contents are unknown, the value is not known. You have been given the task to offer some insights on the contents. Your assessment is that the situation isn't dire, there doesn't seem to be any time imperative or particularly sensitive information contained within. You don't need to get any more Data from any other sources (which is always helpful).

The initial plan is to break the files into words then see which words seem to go together before finally seeing if there is a chance that there are groups of topics that they will fit into. The mighty 'R' will be the language/ tool that we settle on to do this with.

#### Data Understanding

After we load the data up:

```{.r}
file_list <- list.files(path = "data" , recursive = TRUE,
                        pattern = "*.txt",
                        full.names = TRUE)
file_list

text_df <- readtext(paste0(file_list))
text_df # a df with each file as a 'row' against the file name
```
You've now got the files all lined up - one per row against each file name.
```
# Description: df[,2] [42 × 2]
  doc_id    text               
  <chr>     <chr>              
1 Doc01.txt "\"In practic\"..."
2 Doc02.txt "\"Enterprise\"..."
3 Doc03.txt "\"The discus\"..."
4 Doc04.txt "\"Project ma\"..."
5 Doc05.txt "\"I've writt\"..."
6 Doc06.txt "\"Most appro\"..."
# … with 36 more rows
```
As with all good Data Science Projects you decide to take a bit of time *walking around the Data* after loading it up - give yourself a bit of time for this as time spent in exploration is seldom wasted - run some summary stats, have a skim read of a few of the files to get an understanding of the contents. The table below gives a little insight into the length of the files.

To do this we need to break the text down into words and sentences to get a better idea of what we have.

```
text_df_suummary <- text_df %>%
   mutate(doc_id = as_factor(doc_id)) %>%  
   mutate(length_words = str_count(text, boundary("word"))) %>%
   mutate(length_sentences = str_count(text, boundary("sentence"))) %>%
   mutate(length_paragraphs = str_count(text, boundary("line_break"))) %>%
   arrange(desc(length_words))
```
By running `summary()` on the `text_df_summary` we get the following results. It turns out the length of the paragraphs wasn't that helpful for the purposes here which tells us that the formatting of the files is likely all run together with no line breaks. Following a quick inspection of a couple of documents we find this to be the case. The boss wasn't lying - these really are just .txt files from somewhere and with an average length of a little of 2000 words this is no small task.

```
| Item      | Minimum | Mean | Maximum |
|:--------- |:------- | ---- | ------- |
| Words     | 508     | 2235 | 5785    |
| Sentences | 32      | 100  | 263     |
```
Next step in the process is to remove the stopwords[^6ced] and see what we have. We also removed the numbers from the df as well following a quick inspection of the initial results. The files that were riddled with numbers painted a picture in themselves.

```
text_tidy_s <- text_df %>%
   mutate(doc_id = as_factor(doc_id),
          text = str_remove_all(text, "[:digit:]")) %>%
   unnest_tokens(word, text) %>%
   anti_join(stop_words) %>%
   group_by(doc_id) %>%
   count(word,sort = TRUE)

```




[^6d2f]: https://www.datascience-pm.com/crisp-dm-2/

[^6ced]: https://kavita-ganesan.com/what-are-stop-words/#.YLNyUi8RphE
