library(ggplot2)
library(readr)
library(tibble)
library(magrittr)
library(dplyr)

# Path onde fica o csv do dataset

pathCsv <- "dataset.csv";

# Path para armazenar os graficos dos países

pathGraficos <- "graficos";

partidas <- read.csv(pathCsv)

# Transformar o campo date em ano

names(partidas)[1] <- "ano"

partidas$ano <- format(as.Date(partidas$ano), format="%Y")

# Elimina todas as partidas onde nenhum dos dois países jogou em casa

partidas <- filter(partidas, partidas$neutral == FALSE)

# Define a coluna 'timeCasaGanhou', que é um boolean informando se o time da casa ganhou a partida

partidas <- partidas %>% mutate(timeCasaGanhou = ifelse((home_score > away_score), TRUE, FALSE))
                                
# Pega todas as partidas onde o time da casa ganhou

vitoriasCasa <- filter(partidas, timeCasaGanhou == TRUE)

# Agrupa os times e contabiliza o numero de vitórias

vitoriasCasa <- vitoriasCasa %>% group_by(home_team) %>% summarise(vitorias = n())

# Ordena em ordem decrescente pelo número de vitórias
vitoriasCasa <- vitoriasCasa[order(-vitoriasCasa$vitorias),]

# Adiciona posicao no ranking para os registros (para exibir no gráfico)
posicoesRank <- as.vector(unlist(map(1:nrow(vitoriasCasa), function(n) {
  paste(n, "º", sep = "")  
})))

# Adiciona coluna rank no df
vitoriasCasa <- add_column(vitoriasCasa, rank = posicoesRank)

# Cores das seleções para uso no gráfico
coresSelecoes <- c('#D00C27', '#002395', '#000000', '#009246', '#FECC00')

# Plota os 5 times que mais venceram em casa
ggplot(vitoriasCasa[1:5,1:3], aes(x=home_team, y=vitorias, rank = rank)) +
  ggtitle("Ranking de vitórias em casa") +
  geom_bar(stat = "identity", fill = coresSelecoes) +
  geom_text(aes(label = rank), position = position_dodge(width=0.9), vjust=-0.5, size = 10) +
  scale_y_continuous(name = "Vitórias", limits = c(0, 300), breaks = seq(0, 300, 50)) +
  scale_x_discrete(name = "Seleção anfitriã") +
  scale_fill_manual(values = coresSelecoes) +
  theme(text = element_text(size=18)) +
  theme(plot.title = element_text(size = 18))
