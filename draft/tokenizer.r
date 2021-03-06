library(dplyr)
library(janeaustenr)
library(stringr)
library(tidytext)

DEBUG = TRUE

#---------------------------------MAIN-----------------------------------#

#################################MAIN 1 AUSTEN
#get the example
original_books <- austen_books() %>%
  group_by(book) %>%
  mutate(line = row_number(),
         chapter = cumsum(str_detect(text, regex("^chapter [\\divxlc]",
                                                 ignore_case = TRUE)))) %>%
  ungroup()

if (DEBUG == TRUE) {original_books}

#################################MAIN 2 TWITTER

twitter <- read.csv("C:/Users/rubik/Desktop/Intership_NLP_CU/Document/Twitter-Data/Twitter-Data/#cancer+smoking.csv", sep=",", encoding = "UTF-8", header = FALSE, col.names = "text", stringsAsFactors = FALSE)
original_books <- as_data_frame(twitter)
#original_books <- as.character(original_books1)

if (DEBUG == TRUE) {original_books}

#################################MAIN 3 ARTICLE SCIENTIFIQUE

article1 <- read.csv("C:/Users/rubik/Desktop/Intership_NLP_CU/Document/craft-2.0/articles/txt/11532192.txt", sep="\n", fill = TRUE , header = FALSE,  col.names = "text", stringsAsFactors = FALSE)
article2 <- read.csv("C:/Users/rubik/Desktop/Intership_NLP_CU/Document/craft-2.0/articles/txt/11597317.txt", sep="\n", fill = TRUE , header = FALSE,  col.names = "text", stringsAsFactors = FALSE)
article3 <- read.csv("C:/Users/rubik/Desktop/Intership_NLP_CU/Document/craft-2.0/articles/txt/11897010.txt", sep="\n", fill = TRUE , header = FALSE,  col.names = "text", stringsAsFactors = FALSE)
article4 <- read.csv("C:/Users/rubik/Desktop/Intership_NLP_CU/Document/craft-2.0/articles/txt/12079497.txt", sep="\n", fill = TRUE , header = FALSE,  col.names = "text", stringsAsFactors = FALSE)

article <- merge(article1,article2,all=TRUE)
article <- merge(article,article3,all=TRUE)
article <- merge(article,article4,all=TRUE)

original_books <- as_data_frame(article)

if (DEBUG == TRUE) {original_books}


#------------------------------------WORD------------------------------------#

#############################TOKEN 1

tokenizer.word.1 <- function(my.texte) {
  tidy_books <- my.texte %>%
    unnest_tokens(word, text)
  if (DEBUG == TRUE) {tidy_books}
  tidy_books_count = tidy_books %>%
    count(word, sort = TRUE) 
  if (DEBUG == TRUE) {tidy_books_count}
  nb.of.words <- sum(tidy_books_count[2])
  nb.of.types <- dim(tidy_books_count[2])[1]
  return(c(nb.of.words, nb.of.types))
  #725055-14520
}

tokenizer.word.1(original_books)

###############################TOKEN 2

library("tm")

tokenizer.word.2 <- function(my.texte) {
  
  # Load the data as a corpus
  docs <- Corpus(VectorSource(my.texte[1]))
  if (DEBUG == TRUE) {docs}
  
  inspect(docs)
  
  toSpace <- content_transformer(function (x , pattern ) gsub(pattern, " ", x))
  docs <- tm_map(docs, toSpace, "/")
  docs <- tm_map(docs, toSpace, "@")
  docs <- tm_map(docs, toSpace, "\\|")
  
  # Convert the text to lower case
  docs <- tm_map(docs, content_transformer(tolower))
  # Remove numbers
  docs <- tm_map(docs, removeNumbers)
  # Remove english common stopwords
  #docs <- tm_map(docs, removeWords, stopwords("english"))
  # Remove your own stop word
  # specify your stopwords as a character vector
  #docs <- tm_map(docs, removeWords, c("blabla1", "blabla2"))
  # Remove punctuations
  docs <- tm_map(docs, removePunctuation)
  # Eliminate extra white spaces
  docs <- tm_map(docs, stripWhitespace)
  # Text stemming
  # docs <- tm_map(docs, stemDocument)
  
  dtm <- TermDocumentMatrix(docs)
  if (DEBUG == TRUE) {dtm}
  
  m <- as.matrix(dtm)
  v <- sort(rowSums(m),decreasing=TRUE)
  d <- data.frame(word = names(v),freq=v)
  
  nb.of.words <- sum(d[2])
  nb.of.types <- dim(d[2])[1]
  return(c(nb.of.words, nb.of.types))
  #562815  13679
  #557777  18954
}

tokenizer.word.2(original_books)


###############################TOKEN 3
library("tm")

tokenizer.word.3 <- function(my.texte) {
  tokens <- Boost_tokenizer(my.texte[1])
  if (DEBUG == TRUE) {tokens} 
  nb.of.words <- length(tokens)
  return(nb.of.words)
  #728907
}

tokenizer.word.3(original_books)


###############################TOKEN 4

library(tokenizers)

tokenizer.word.4 <- function(my.texte) {
  tokens <- tokenize_words(paste0(my.texte[1]), lowercase = TRUE)
  if (DEBUG == TRUE) {tokens} 
  nb.of.words <- dim(as.data.frame(tokens))[1]
  return(nb.of.words)
    #725056
}

tokenizer.word.4(original_books)

##############################TOKEN 5

library(tokenizers)

tokenizer.word.5 <- function(my.texte) {
  tokens <- tokenize_tweets(paste0(my.texte[1]), lowercase = TRUE)
  if (DEBUG == TRUE) {tokens} 
  nb.of.words <- dim(as.data.frame(tokens))[1]
  return(nb.of.words)
    #717497
}

tokenizer.word.5(original_books)

###########################TOKEN 6

#install.packages("stringr", dependencies = TRUE)
library(stringr)

Clean_String <- function(string){
  # Lowercase
  temp <- tolower(string)
  # Remove everything that is not a number or letter (may want to keep more 
  # stuff in your actual analyses). 
  temp <- stringr::str_replace_all(temp,"[^a-zA-Z\\s]", " ")
  # Shrink down to just one white space
  temp <- stringr::str_replace_all(temp,"[\\s]+", " ")
  # Split it
  temp <- stringr::str_split(temp, " ")[[1]]
  # Get rid of trailing "" if necessary
  indexes <- which(temp == "")
  if(length(indexes) > 0){
    temp <- temp[-indexes]
  } 
  return(temp)
}

# function to clean text
Clean_Text_Block <- function(text){
  # Get rid of blank lines
  indexes <- which(text == "")
  if (length(indexes) > 0) {
    text <- text[-indexes]
  }
  # See if we are left with any valid text:
  if (length(text) == 0) {
    cat("There was no text in this document! \n")
    to_return <- list(num_tokens = 0, 
                      unique_tokens = 0, 
                      text = "")
  } else {
    # If there is valid text, process it.
    # Loop through the lines in the text and combine them:
    clean_text <- NULL
    for (i in 1:length(text)) {
      # add them to a vector 
      clean_text <- c(clean_text, Clean_String(text[i]))
    }
    # Calculate the number of tokens and unique tokens and return them in a 
    # named list object.
    num_tok <- length(clean_text)
    num_uniq <- length(unique(clean_text))
    to_return <- list(num_tokens = num_tok, 
                      unique_tokens = num_uniq, 
                      text = clean_text)
  }
  
  return(to_return)
}

tokenizer.word.6 <- function(my.texte) {
  clean_speech <- Clean_Text_Block(my.texte)
  str(clean_speech)
  #729324-13731
}

tokenizer.word.6(original_books)

#-----------------------------------------SENTENCE---------------------------#

############################TOKEN 1

library(tokenizers)

tokenizer.sentence.1 <- function(my.texte) {
  tokens <- tokenize_sentences(paste0(my.texte[1]), lowercase = TRUE)
  if (DEBUG == TRUE) {tokens} 
  nb.of.words <- dim(as.data.frame(tokens))[1]
  return(nb.of.words)
  #31396
}

tokenizer.sentence.1(original_books)

##########################TOKEN 2

library(tm)
library(NLP)
library(openNLP)


convert_text_to_sentences <- function(text, lang = "en") {
  # Function to compute sentence annotations using the Apache OpenNLP Maxent sentence detector employing the default model for language 'en'. 
  sentence_token_annotator <- Maxent_Sent_Token_Annotator(language = lang)
  
  # Convert text to class String from package NLP
  text <- as.String(text)
  
  # Sentence boundaries in text
  sentence.boundaries <- annotate(text, sentence_token_annotator)
  
  # Extract sentences
  sentences <- text[sentence.boundaries]
  
  # return sentences
  return(length(sentences))
  #30844
}

convert_text_to_sentences(original_books)

#########################TOKEN 3

library("quanteda")

tokenizer.sentence.3 <- function(my.texte) {
  token <- unlist(my.texte, recursive=FALSE)
  sentence <- tokens(token, what = "sentence", remove_numbers = FALSE, remove_punct = FALSE,
                     remove_symbols = FALSE, remove_separators = TRUE,
                     remove_twitter = FALSE, remove_hyphens = FALSE, remove_url = FALSE,
                     ngrams = 1L, skip = 0L, concatenator = "_",
                     verbose = quanteda_options("verbose"), include_docvars = TRUE)
  nb.of.words <-   length(sentence)
  return(nb.of.words)
  #31396
}

tokenizer.sentence.3(original_books[1]) #pour austen
#pour article

#------------------------------------NOMALIZATION----------------------------#

#########################NORMALIZE 1

library(tokenizers)

normalize.1 <- function(my.texte) {
  tokens1 <- tokenize_word_stems(paste0(my.texte[1]))
  tokens2 <- unlist(tokens1, recursive=FALSE)
  tokens <- unique(tokens2)
  if (DEBUG == TRUE) {tokens} 
  nb.of.words <- dim(as.data.frame(tokens))
  return(nb.of.words[1])
  #725056
}

normalize.1(original_books)

##########################NORMALIZE 2

library("tm")

normalize.2 <- function(my.texte) {
  
  # Load the data as a corpus
  docs <- Corpus(VectorSource(my.texte[1]))
  if (DEBUG == TRUE) {docs}
  
  inspect(docs)
  
  toSpace <- content_transformer(function (x , pattern ) gsub(pattern, " ", x))
  docs <- tm_map(docs, toSpace, "/")
  docs <- tm_map(docs, toSpace, "@")
  docs <- tm_map(docs, toSpace, "\\|")
  
  # Convert the text to lower case
  docs <- tm_map(docs, content_transformer(tolower))
  # Remove numbers
  docs <- tm_map(docs, removeNumbers)
  # Remove english common stopwords
  #docs <- tm_map(docs, removeWords, stopwords("english"))
  # Remove your own stop word
  # specify your stopwords as a character vector
  #docs <- tm_map(docs, removeWords, c("blabla1", "blabla2"))
  # Remove punctuations
  docs <- tm_map(docs, removePunctuation)
  # Eliminate extra white spaces
  docs <- tm_map(docs, stripWhitespace)
  # Text stemming
  docs <- tm_map(docs, stemDocument)
  
  dtm <- TermDocumentMatrix(docs)
  if (DEBUG == TRUE) {dtm}
  
  m <- as.matrix(dtm)
  v <- sort(rowSums(m),decreasing=TRUE)
  d <- data.frame(word = names(v),freq=v)
  
  nb.of.words <- sum(d[2])
  nb.of.types <- dim(d[2])[1]
  return(c(nb.of.words, nb.of.types))
  #12801
}

normalize.2(original_books)

#################################NORMALIZE 3
library("corpus")
tweet = TRUE
#attention ici avec meme tokenization de base pour tweet

normalize.3 <- function(my.texte) {
  if(tweet == TRUE)#TO DO a mieux faire
  {
    tokens0 <- my.texte %>%
      unnest_tokens(text, text)
    if (DEBUG == TRUE) {tokens0} 
  } else {
    tokens0 <- my.texte
  }
  tokens1 <- text_tokens(tokens0[1], stemmer = "en")
  tokens2 <- unlist(tokens1, recursive=FALSE)
  tokens <- unique(tokens2)
  if (DEBUG == TRUE) {tokens} 
  nb.of.words <- length(tokens)
  return(nb.of.words)
  #725056
}

normalize.3(original_books[1])


#############################NORMALIZE 4

library(hunspell)
#attention ici avec meme tokenization de base pour tweet

stem_hunspell <- function(my.texte) {
  # look up the term in the dictionary
  tokens <- unlist(my.texte, recursive=FALSE)
  stems <- hunspell_stem(tokens)[[1]]
  #print(stems)
  if (length(stems) == 0) { # if there are no stems, use the original term
    stem <- my.texte
    } else { # if there are multiple stems, use the last one
    stem <- stems[[length(stems)]]
  }
  
  stem
}

normalize.4 <- function(my.texte) {
  if(tweet == TRUE)#TO DO a mieux faire
  {
    tokens0 <- my.texte %>%
      unnest_tokens(text, text)
    if (DEBUG == TRUE) {tokens0} 
  } else {
    tokens0 <- my.texte
  }
  tokens1 <- text_tokens(tokens0, stemmer = stem_hunspell)
  tokens2 <- unlist(tokens1, recursive=FALSE)
  tokens <- unique(tokens2)
  if (DEBUG == TRUE) {tokens} 
  nb.of.words <- length(tokens)
  return(nb.of.words)
  #725056
}

normalize.4(original_books)

###########################NORMALIZE 5

#attention ici avec meme tokenization de base pour tweet


# download the list
url <- "http://www.lexiconista.com/Datasets/lemmatization-en.zip"
tmp <- tempfile()
download.file(url, tmp)

# extract the contents
con <- unz(tmp, "lemmatization-en.txt", encoding = "UTF-8")
tab <- read.delim(con, header=FALSE, stringsAsFactors = FALSE)
names(tab) <- c("stem", "term")

head(tab)

stem_list <- function(term) {
  i <- match(term, tab$term)
  if (is.na(i)) {
    stem <- term
  } else {
    stem <- tab$stem[[i]]
  }
  stem
}

normalize.5 <- function(my.texte) {
  if(tweet == TRUE)#TO DO a mieux faire
  {
    tokens0 <- my.texte %>%
      unnest_tokens(text, text)
    if (DEBUG == TRUE) {tokens0} 
  } else {
    tokens0 <- my.texte
  }
  tokens1 <- text_tokens(tokens0, stemmer = stem_list)
  tokens2 <- unlist(tokens1, recursive=FALSE)
  tokens <- unique(tokens2)
  if (DEBUG == TRUE) {tokens} 
  nb.of.words <- length(tokens)
  return(nb.of.words)
  #725056
}

normalize.5(original_books)

#----------------------------------STOP WORDS-------------------------------#

###########################STOP WORDS 1
library(tidytext)

stop.word.1 <- function(my.texte) {

  cleaned_books <- my.texte[1] %>%
    anti_join(get_stopwords(),by = "word")
  if (DEBUG == TRUE) {cleaned_books} 
  cleaned_books_count = cleaned_books %>%
    count(word, sort = TRUE)
  if (DEBUG == TRUE) {cleaned_books_count} 
  nb.of.words <- sum(cleaned_books_count[2])
  return(nb.of.words)
  # 325084
}

stop.word.1(original_books)



