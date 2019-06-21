# visualizacoes-selecoes

Projeto de demonstração em R para visualizar e determinar as melhores equipes nacionais de futebol masculino ao longo do tempo.

## Dataset

O `dataset.csv` utilizado foi criado e disponibilizado por [Mart Jürisoo](https://github.com/martj42) e está disponível [aqui](https://github.com/martj42/international_results).

## Requisitos

Para usar este projeto instale o [R](https://www.r-project.org/) e os seguintes pacotes:

- [ggplot2](https://cran.r-project.org/package=ggplot)
- [dplyr](https://cran.r-project.org/package=dplyr)
- [purrr](https://cran.r-project.org/package=purrr)
- [magrittr](https://cran.r-project.org/package=magrittr)
- [tibble](https://cran.r-project.org/package=tibble)
- [xtable](https://cran.r-project.org/package=xtable)
- [ggimage](https://cran.r-project.org/package=ggimage)
- [readr](https://cran.r-project.org/package=readr)

Para gerar o timelapse também é necessário o [ffmpeg](https://ffmpeg.org/).

## Objetivo

Criar visualizações da performance das seleções em determinados períodos, considerando os placares. O foco de cada script em R está descrito abaixo:

- `melhores_selecoes.R`: Script que calcula um índice de performance das seleções considerando todo o histórico, tentando descobrir qual a melhor seleção até aqui levando em conta seu desempenho nas principais competições (Copa do Mundo, UEFA Euro e Copa América). Pesos são considerados conforme a importância da competição.

- `aproveitamento_selecoes.R`: Mostra estatísticas de aproveitamento das seleções se todos os jogos do histórico fossem considerados. O percentual de aproveitamento simula um campeonato de pontos corridos para o cálculo.

- `ranking_de_vitorias_em_casa.R`: Ranqueia as cinco melhores seleções com base no seu número de vitórias quando jogando em casa.

- `ranking_de_vitorias_fora_de_casa.R`: Ranqueia as cinco melhores seleções com base no seu número de vitórias quando jogando fora de casa.

- `ranking_de_partidas_ganhas_em_copa_do_mundo.R`: Ranqueia as cinco melhores seleções com base no seu número de vitórias em Copa do Mundo FIFA.

- `vitorias_ao_longo_dos_anos.R`: Gera um gráfico com o número de vitórias das equipes selecionadas até o ano escolhido. Utilizamos este script para gerar os gráficos de todos os anos até o presente e montar um timelapse! Esse script também utiliza as bandeiras de cada país para decorar o gráfico.

## Montando o timelapse

Para montar o timelapse você precisa ter o [ffmpeg](https://ffmpeg.org/) instalado.

1. Rode o script R `vitorias_ao_longo_dos_anos.R`.
2. Ele cria a pasta `timelapse` no diretório em foco.
3. Ele exporta cada gráfico com o seu respectivo ano.
4. Vá até a pasta `timelapse` e rode `ffmpeg -framerate 2 -pattern_type glob -i '*.jpg' -c:v libx264 video.mp4`
5. Um vídeo chamado `video.mp4` será gerado na pasta, contendo o timelapse.

## Licença

[MIT](LICENSE)
