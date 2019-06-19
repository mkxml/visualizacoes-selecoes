library(readr)
library(tibble)
library(magrittr)
library(dplyr)

# Path onde fica o csv do dataset

pathCsv <- "dataset.csv"

# Path para armazenar os graficos dos países

pathGraficos <-  "graficos"

partidas <- read.csv(pathCsv)

# Transformar o campo date em ano

names(partidas)[1] <- "ano"

partidas$ano <- format(as.Date(partidas$ano), format="%Y")

# Define a coluna 'timeVisitanteGanhou', que é um boolean informando se o time visitante ganhou a partida

partidas <- partidas %>% mutate(timeVisitanteGanhou = ifelse((home_score < away_score), TRUE, FALSE))

# Pega todas as partidas onde o time visitante ganhou

vitoriasVisitante <- filter(partidas, timeVisitanteGanhou == TRUE)

# Agrupa os times e contabiliza o numero de vitórias

vitoriasVisitante <- vitoriasVisitante %>% group_by(away_team) %>% summarise(vitorias = n())

# Ordena em ordem decrescente pelo número de vitórias

vitoriasVisitante <- vitoriasVisitante[order(-vitoriasVisitante$vitorias),]

# Adiciona posicao no ranking para os registros (para exibir no gráfico)
posicoesRank <- as.vector(unlist(map(1:nrow(vitoriasVisitante), function(n) {
  paste(n, "º", sep = "")  
})))

# Adiciona coluna rank no df
vitoriasVisitante <- add_column(vitoriasVisitante, rank = posicoesRank)

# Cores das seleções para uso no gráfico
coresSelecoes <- c('#FEDF00', '#D00C27', '#000000', '#FECC00', '#002395')

# Plota os 5 times que mais venceram fora de casa
ggplot(vitoriasVisitante[1:5,], aes(x=away_team, y=vitorias, rank = rank)) +
  ggtitle("Ranking de vitórias fora de casa") +
  geom_bar(stat = "identity", fill = coresSelecoes) +
  geom_text(aes(label = rank), position = position_dodge(width=0.9), vjust=-0.5, size = 10) +
  scale_y_continuous(name = "Vitórias", limits = c(0, 300), breaks = seq(0, 300, 50)) +
  scale_x_discrete(name = "Seleção visitante") +
  scale_fill_manual(values = coresSelecoes) +
  theme(text = element_text(size=18)) +
  theme(plot.title = element_text(size = 18))
