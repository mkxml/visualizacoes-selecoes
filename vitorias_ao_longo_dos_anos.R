library(ggimage)
library(purrr)
library(readr)
library(tibble)
library(magrittr)
library(dplyr)
library(ggplot2)

# Path onde fica o csv do dataset, relativo à pasta atual
pathCsv <- "dataset.csv"

# Path para armazenar o timelapse
pathGraficos <- "timelapse"

# Path com as bandeiras
pathBandeiras <- "bandeiras"

# Inicializa tibble partidas
partidas <- read.csv(pathCsv)

# Transformar o campo date em ano:
names(partidas)[1] <- "ano"
partidas$ano <- format(as.Date(partidas$ano), format="%Y")

# Lista de seleções para gerar os gráficos de barra de cada frame
listaSelecoes <- c('Argentina', 'Brazil', 'England', 'France', 'Germany', 'Italy', 'Sweden', 'Uruguay')
bandeirasSelecoes <- c('ar.png', 'br.png', 'en.png', 'fr.png', 'de.png', 'it.png', 'se.png', 'uy.png')
coresSelecoes <- c('#75AADB', '#FEDF00', '#D00C27', '#002395', '#000000', '#009246', '#FECC00', '#0038A8')

# Ajusta caminho das bandeiras
bandeirasSelecoes <- as.character(map(bandeirasSelecoes, function(arquivo) {
  paste(pathBandeiras, '/', arquivo, sep = "")
}))

# Ordena partidas por ano de forma ascendente
partidas <- arrange(partidas, ano)

# Calcula o ano da primeira partida para gerar o timelapse
anoPrimeiraPartida <- min(unlist(map(listaSelecoes, function(selecao) {
  subset(partidas, partidas$home_team == selecao | partidas$away_team == selecao, c(ano)) %>%
    slice(1) %>%
    as.numeric()
}), use.names = FALSE))

# Cria a pasta para jogar as imagens com os frames do timelapse
dir.create(pathGraficos)

# Gera frames para todos os anos até 2019
for (anoVigente in anoPrimeiraPartida:2019) {
  # Cria tabela vazia
  tSelecoes <- tibble(selecao = character(), vitorias = numeric())
  # Adiciona colunas de cada seleção ao tSelecoes
  for(selecao in listaSelecoes) {
    # DF com as partidas da selecão em foco
    partidasPais <- subset(partidas, home_team == selecao | away_team == selecao)
    # Atualiza o df definindo a coluna resultado
    partidasPais <- partidasPais %>% mutate(
      resultado = if_else(home_team == selecao,
        if_else(home_score > away_score,
                'vitoria',
                if_else(home_score < away_score, 'derrota', 'empate')
        ),
        if_else(home_score < away_score,
                'vitoria',
                if_else(home_score > away_score, 'derrota', 'empate')
        )
      )
    )
    # Faz um novo dataframe só com as colunas pertinentes
    partidasPais <- partidasPais[c('ano','resultado')]
    partidasPais$resultado <- as.factor(partidasPais$resultado)
    partidasPais$ano <- as.numeric(as.character(partidasPais$ano))
    
    # Filtrando vitórias até o ano vigente
    vitorias <- filter(partidasPais, partidasPais$ano <= anoVigente & partidasPais$resultado == "vitoria")
    
    # Agrupando vitórias até o ano vigente
    vitorias <- as.numeric(summarise(vitorias, numVitorias = n()))
    
    tSelecoes <- add_row(tSelecoes, 'selecao' = selecao, 'vitorias' = vitorias)
  }
  # Nome do arquivo do frame
  nomeArquivo <- paste(pathGraficos, '/', anoVigente, ".jpg", sep="")
  
  # Plota gráfico até o ano vigente (frame do timelapse)
  frame <- ggplot(tSelecoes, aes(x = selecao, y = vitorias, image = bandeirasSelecoes)) +
    ggtitle(anoVigente) + 
    geom_bar(stat = "identity", fill = coresSelecoes) +
    geom_image(aes(images = bandeirasSelecoes), size = 0.1, by = "width", position = position_nudge(y = 35)) +
    geom_text(aes(label = vitorias), position = position_dodge(width=0.9), vjust=-2.2, size = 10) +
    scale_y_continuous(name = "Vitórias acumuladas", limits = c(0, 750), breaks = seq(0, 750, 50)) +
    scale_x_discrete(name = "Seleção") +
    scale_fill_manual(values = coresSelecoes) +
    theme(plot.title = element_text(hjust = 0.5, size = 32)) +
    theme(text = element_text(size=18)) +
    theme(axis.line = element_line(colour = "black", size = 1, linetype = "solid")) +
    theme(legend.position="none")
  ggsave(nomeArquivo, frame, device = "jpeg", width = 21, height = 20, units = c('cm'))
}
