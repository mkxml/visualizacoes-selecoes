# A ideia desse script é tentar descobrir as melhores seleções em relação
# aos seus desempenhos nas competições mais importantes

# A ideia é colocar pesos nas vitórias em competições importantes:
# Competição mundial (Copa do Mundo) = peso 4
# Competição continental (Copa América, UEFA Euro) = peso 3
# Eliminatórias (Copa do Mundo, Copa América, UEFA Euro) = peso 2
# Amistosos e outras competições = peso 1

library(xtable)
library(readr)
library(tibble)
library(magrittr)
library(dplyr)

# Path onde fica o csv do dataset
pathCsv <- "dataset.csv"

partidas <- read.csv(pathCsv)

names(partidas)[1] <- "ano"

partidas$ano <- format(as.Date(partidas$ano), format="%Y")


# Define a coluna vencedor
partidas <- partidas %>% mutate(vencedor = if_else((home_score == away_score),
  'empate',
  if_else((home_score > away_score),
         as.character(home_team), 
         as.character(away_team)
  )
))


# Tirando empates
partidas <- filter(partidas, vencedor != "empate")

# Recentes
# partidas <- filter(partidas, ano <= 2019 & ano >= 2010)

# Adicionando pesos nas partidas
partidas <- add_column(partidas, peso = 1)

# Peso Copa do Mundo
partidas <- mutate(partidas,
  peso = if_else(tournament == 'FIFA World Cup', 4, peso)
)

# Pesos competições continentais
partidas <- mutate(partidas,
  peso = if_else(
    tournament == 'UEFA Euro' |
    tournament == "Copa América", 3, peso)
)

# Pesos eliminatórias
partidas <- mutate(partidas,
  peso = if_else(
    tournament == 'FIFA World Cup qualification' |
    tournament == 'UEFA Euro qualification' |
    tournament == "Copa América qualification", 2, peso)
)

listaSelecoes <- unique(
  c(as.character(partidas$home_team), as.character(partidas$away_team))
)

# Cria tabela para os índices de qualidade
tIndice <- tibble(selecao = partidas$vencedor, indice = partidas$peso)

# Agrupa os pesos para calcular o indice
tIndice <- tIndice %>% group_by(selecao) %>% summarise(indice = sum(indice))

# Ordena pelo melhor indice
tIndice <- arrange(tIndice, desc(indice))

melhores <- slice(tIndice, 1:10)

# Gera tabela com os 10 melhores
names(melhores) <- c("País", "Índice de desempenho")
xtable(melhores, digits = c(0), caption = "Índice de desempenho histórico das equipes de 1872 até 2019")
