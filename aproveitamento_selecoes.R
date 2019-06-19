library(xtable)
library(readr)
library(tibble)
library(magrittr)
library(dplyr)

# Path onde fica o csv do dataset

pathCsv <- "dataset.csv"

partidas <- read.csv(pathCsv)

# Define a coluna 'vencedor'
partidas <- partidas %>% mutate(vencedor = if_else((home_score == away_score),
  'empate',
  if_else((home_score > away_score),
         as.character(home_team), 
         as.character(away_team)
  )
))

# Criamos uma tabela contendo:
# A seleção 
# O número de jogos que disputou 
# O seu percentual de vitória
# Seu número de pontos (veja abaixo)
# Aproveitamento (pontos em relação ao total)

tabelaResultados = tibble(
  "Seleção" = character(),
  "Número de jogos" = numeric(),
  "Número de pontos" = numeric(),
  "Percentual de vitória" = numeric(),
  "Aproveitamento" = numeric()
)

# O sistema de pontos considera 0 derrota, 1 empate e 3 vitória

# Lista com todas as seleções existentes no dataset
listaSelecoes <- unique(
  c(as.character(partidas$home_team), as.character(partidas$away_team))
)

# Popula a tabela
for (selecao in listaSelecoes) {
  # Cria um subset com todas partidas do país em foco
  partidasPais <- subset(partidas,
    home_team == selecao | away_team == selecao
  )
  
  # Pega o número de jogos que este país disputou
  numero_jogos <- nrow(partidasPais)
  
  # Calcula o máximo de pontos possíveis
  pontosPossiveis <- numero_jogos * 3
  
  # Pega o numero de vitórias deste país
  numero_vitorias <- partidasPais %>%
    filter(vencedor == selecao) %>%
    nrow() %>%
    reduce('+')
  
  # Pega o número de empates
  numero_empates <- partidasPais %>%
    filter(vencedor == 'empate') %>%
    nrow() %>%
    reduce('+')
  
  numero_pontos <- numero_vitorias * 3 + numero_empates
  
  percentual_vitoria <- (numero_vitorias / numero_jogos) * 100
  
  aproveitamento <- (numero_pontos / pontosPossiveis) * 100
  
  tabelaResultados <- add_row(tabelaResultados,
    "Seleção" = selecao,
    "Número de jogos" = numero_jogos,
    "Número de pontos" = numero_pontos,
    "Percentual de vitória" = percentual_vitoria,
    "Aproveitamento" = aproveitamento
  )
}

# Ordenando por aproveitamento
porAproveitamento <- arrange(tabelaResultados, desc(tabelaResultados$Aproveitamento))

# Filtrando seleções com mais de 500 jogos (evitar seleções com jogos esporádicos)
porAproveitamento500 <- filter(porAproveitamento, porAproveitamento$`Número de jogos` > 500)

# Gerando tabela dos melhores (LATEX), sem número total de pontos
xtable(head(select(porAproveitamento500, -c("Número de pontos"))), caption = "Tabela de aproveitamento das melhores seleções")
