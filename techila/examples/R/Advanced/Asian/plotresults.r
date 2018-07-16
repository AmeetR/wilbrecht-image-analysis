# Copyright 2010-2013 Techila Technologies Ltd.

# plot the computation results in a graph

plotresults <- function(result) {
  total$price[result$j_index,result$i_index] = result$price
  jet.colors <- colorRampPalette(c("white","blue", "cyan", "yellow", "red"))
  color <- jet.colors(100)

  nrz <- nrow(total$price)
  ncz <- ncol(total$price)
  zfacet <- total$price[-1, -1] + total$price[-1, -ncz] + total$price[-nrz, -1] + total$price[-nrz, -ncz]
  facetcol <- cut(zfacet, 100)
  persp(total$price,
        zlim = range(min(total$price), max(total$price) * 2),
        col = color[facetcol],
        ylab = "Initial Stock Price",
        xlab = "Initial Volatility",
        zlab = "Price of Asian Call")

  result$price
}
