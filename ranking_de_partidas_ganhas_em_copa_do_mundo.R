library(ggplot2)
library(readr)
library(tibble)
library(magrittr)
library(dplyr)

# Path onde fica o csv do dataset

pathCsv <- "dataset.csv"

# Path para armazenar os graficos dos países

pathGraficos <- "graficos"

partidas <- read.csv(pathCsv)

# Transformar o campo date em ano:

names(partidas)[1] <- "ano"

partidas$ano <- format(as.Date(partidas$ano), format="%Y")

# Filtra todas as partidas da copa do mundo
partidasCopa <- filter(partidas, partidas$tournament == 'FIFA World Cup')

# Define a coluna 'vencedor'
partidasCopa <- partidasCopa %>% mutate(vencedor = ifelse((home_score == away_score),
                                                          'empate',
                                                           ifelse((home_score > away_score),
                                                                   as.character(home_team), 
                                                                  as.character(away_team)
                                                                  )))

# Retira todos os empates do data frame
partidasCopa <- filter(partidasCopa, partidasCopa$vencedor != 'empate')

# Faz um agrupamento por país contabilizando o número de vitórias
agrupamentoVitorias <- partidasCopa %>% group_by(vencedor) %>% summarise(vitorias= n())

# Ordena pelo número de vitórias do maior ou menor
agrupamentoVitorias <- agrupamentoVitorias[order(-agrupamentoVitorias$vitorias),]

# Adiciona posicao no ranking para os registros (para exibir no gráfico)
posicoesRank <- as.vector(unlist(map(1:nrow(agrupamentoVitorias), function(n) {
  paste(n, "º", sep = "")  
})))

# Adiciona coluna rank no df
agrupamentoVitorias <- add_column(agrupamentoVitorias, rank = posicoesRank)

# Cores das seleções para o gráfico
coresSelecoes <- c('#75AADB', '#FEDF00', '#002395', '#000000', '#009246')

# Plota o gráfico
ggplot(agrupamentoVitorias[1:5,], aes(x=vencedor, y=vitorias, rank = rank)) +
  ggtitle("Ranking de partidas ganhas em Copa do Mundo FIFA") +
  geom_bar(stat = "identity", fill = coresSelecoes) +
  geom_text(aes(label = rank), position = position_dodge(width=0.9), vjust=-0.5, size = 10) +
  scale_y_continuous(name = "Vitórias", limits = c(0, 80), breaks = seq(0, 80, 10)) +
  scale_x_discrete(name = "Seleção") +
  scale_fill_manual(values = coresSelecoes) +
  theme(text = element_text(size=18)) +
  theme(plot.title = element_text(size = 18))
