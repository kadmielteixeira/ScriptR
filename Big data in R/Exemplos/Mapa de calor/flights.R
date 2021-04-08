#Os dados utilizados nesse repositório podem ser encontrados na URL "https://www.kaggle.com/usdot/flight-delays?select=flights.csv"

#Importando os pacotes

##install.packages("readr")
##install.packages("tidyverse")
##devtools::install_github("jayjacobs/ggcal")

library(readr)
library(tidyverse)
library(ggcal)

#Criando funções 

##A função getStats seleciona as companhias aéreas, remove os NA's, calcula o número de voos e a quantidade de voos com atraso maior que 10 minutos
getStats = function(input, pos){
  vetor = c("AA", "DL", "UA", "US") #CIA area de interesse
  input %>% filter(AIRLINE %in% vetor) %>%
    filter(!is.na(DAY), !is.na(MONTH), !is.na(AIRLINE), !is.na(ARRIVAL_DELAY)) %>% #removendo os NA's
    group_by(DAY, MONTH, AIRLINE) %>% #Agrupando por dia, mês e CIA
    summarise(num = sum(ARRIVAL_DELAY > 10),n=n()) #Calculando a quantidade de voos com atraso maior que 10 min e o número de voos
}

#A função computeStats recebe o data frame stats, agrupa os dados, realiza a soma da quantidade de voos com atraso maior que 10 min e o total de voos, e seleciona as informações desejadas
computeStats = function(stats){
  stats %>% #Recebe o data frame originado através da função getStats
    group_by(DAY, MONTH, AIRLINE) %>% #Agrupa os dados por dia, mês e CIA
    summarise(soma = sum(num), total = sum(n)) %>% #Calcula a soma da qauntidade de voos com atraso e o total de voos
    ungroup %>% #Agrupa
    mutate(Cia = AIRLINE, Data = as.Date(paste(2015, MONTH, DAY, sep="/"), format = "%Y/%m/%d"), Perc = soma / total) %>% #Editando as variáveis de interesse
    select(Cia, Data, Perc) #Seleciona as variáveis de interesse
  
}


#Importar os dados

##Diretório onde os dados estão
path = "C:/Users/User/Desktop/ME315"

##Colunas de interesse
mycols = cols_only(DAY='i', MONTH='i', AIRLINE='c', ARRIVAL_DELAY = 'i')

##Importando os dados de 10 em 10 mil e executando a função getStats a cada lote de 10 mil
dados = read_csv_chunked(file.path(path, "flights.csv"),
                       callback=DataFrameCallback$new(getStats), #Executa a função getStats a cada lote
                       chunk_size = 1e5, #Seleciona o tamanho de cada lote
                       col_types=mycols) #Colunas de interesse

dados = computeStats(dados) #Recebendo o data frame gerado pela função getStats

#Criar um mapa de calor em formato de calendário para cada CIA aérea

##Criando a paleta de cores para o mapa de calor

pal = scale_fill_gradient(name = "% de atraso", low = "#4575b4", high = "#d73027")

##Criando a função que cria o mapa de calor no formato de calendário

basecalendário = function(stats,cia){
  cia = as.character(cia) #Transforma o argumento cia em character
  
  dados = stats %>% #filtra o data frame, ficamos apenas com a CIA de interesse
    filter(Cia == cia)
  
  titulo = paste("Calendário com os atrasos da companhia aérea", cia)
  
  ggcal(dados$Data, dados$Perc) + pal + ggtitle(titulo)+ theme(legend.title = element_text())#Cria o mapa de calor no formato de calendário e com a paleta de cores desejada
}

basecalendário(dados,"US") #Testando a função que cria o mapa de calor com a CIA "US"
