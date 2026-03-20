#' Timeline Geom
#'
#' Plots earthquakes on a horizontal timeline, optionally stratified by a y-axis aesthetic.
#'
#' @inheritParams ggplot2::geom_point
#' @importFrom ggplot2 ggproto Geom aes draw_key_point layer
#' @importFrom grid polylineGrob pointsGrob gpar unit gList gTree
#' @export
#' @examples
#' \dontrun{
#' library(ggplot2)
#' ggplot(df, aes(x = Date, y = COUNTRY, color = DEATHS, size = EQ_PRIMARY)) +
#'   geom_timeline()
#' }
geom_timeline <- function(mapping = NULL, data = NULL, stat = "identity",
                          position = "identity", na.rm = FALSE,
                          show.legend = TRUE, inherit.aes = TRUE, ...) {
  ggplot2::layer(
    geom = GeomTimeline, mapping = mapping, data = data, stat = stat,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(na.rm = na.rm, ...)
  )
}

#' @rdname geom_timeline
#' @format NULL
#' @usage NULL
#' @importFrom scales alpha
#' @importFrom grid polylineGrob unit gpar pointsGrob gTree gList
#' @importFrom ggplot2 ggproto Geom aes draw_key_point
#' @export
GeomTimeline <- ggplot2::ggproto("GeomTimeline", Geom,
                                 required_aes = c("x"),
                                 default_aes = ggplot2::aes(y = 0, shape = 19, colour = "grey", size = 1.5, alpha = 0.5, stroke = 0.5),
                                 draw_key = ggplot2::draw_key_point,
                                 draw_panel = function(data, panel_params, coord) {
                                   coords <- coord$transform(data, panel_params)
                                   y_levels <- unique(coords$y)

                                   lines <- grid::polylineGrob(
                                     x = grid::unit(rep(c(0, 1), length(y_levels)), "npc"),
                                     y = grid::unit(rep(y_levels, each = 2), "npc"),
                                     id = rep(seq_along(y_levels), each = 2),
                                     gp = grid::gpar(col = "lightgrey", lwd = 1)
                                   )

                                   points <- grid::pointsGrob(
                                     x = grid::unit(coords$x, "npc"),
                                     y = grid::unit(coords$y, "npc"),
                                     pch = coords$shape,
                                     gp = grid::gpar(
                                       col = scales::alpha(coords$colour, coords$alpha),
                                       fill = scales::alpha(coords$colour, coords$alpha),
                                       fontsize = coords$size * .pt
                                     )
                                   )

                                   grid::gTree(children = grid::gList(lines, points))
                                 }
)
