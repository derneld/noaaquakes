#' Timeline Label Geom
#'
#' Adds vertical lines and labels to the top earthquakes in a timeline.
#'
#' @param n_max Integer. The number of largest earthquakes (by magnitude) to label.
#' @inheritParams ggplot2::geom_text
#' @importFrom ggplot2 ggproto Stat Geom aes layer
#' @importFrom dplyr group_by slice_max ungroup
#' @importFrom grid segmentsGrob textGrob gpar unit gList gTree
#' @export
geom_timeline_label <- function(mapping = NULL, data = NULL, stat = "TimelineLabel",
                                position = "identity", na.rm = FALSE,
                                show.legend = NA, inherit.aes = TRUE,
                                n_max = NULL, ...) {

  if (is.null(mapping)) {
    mapping <- ggplot2::aes(magnitude = EQ_PRIMARY)
  } else if (is.null(mapping$magnitude)) {
    mapping$magnitude <- ggplot2::aes(m = Mag)$m
  }

  ggplot2::layer(
    geom = GeomTimelineLabel, mapping = mapping, data = data, stat = stat,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(na.rm = na.rm, n_max = n_max, ...)
  )
}

#' @rdname geom_timeline_label
#' @format NULL
#' @usage NULL
#' @export
StatTimelineLabel <- ggplot2::ggproto("StatTimelineLabel", ggplot2::Stat,
                                      required_aes = c("x", "label", "magnitude"),
                                      compute_panel = function(data, scales, n_max = NULL) {
                                        if (!is.null(n_max)) {
                                          data <- data %>%
                                            dplyr::group_by(y) %>%
                                            dplyr::slice_max(order_by = magnitude, n = n_max, with_ties = FALSE) %>%
                                            dplyr::ungroup()
                                        }
                                        data
                                      }
)

#' @rdname geom_timeline_label
#' @format NULL
#' @usage NULL
#' @export
GeomTimelineLabel <- ggplot2::ggproto("GeomTimelineLabel", ggplot2::Geom,
                                      required_aes = c("x", "label"),
                                      default_aes = ggplot2::aes(y = 0, colour = "black", size = 0.5, alpha = 1, magnitude = 1),
                                      draw_panel = function(data, panel_params, coord) {
                                        coords <- coord$transform(data, panel_params)
                                        line_height <- 0.1

                                        lines <- grid::segmentsGrob(
                                          x0 = grid::unit(coords$x, "npc"),
                                          y0 = grid::unit(coords$y, "npc"),
                                          x1 = grid::unit(coords$x, "npc"),
                                          y1 = grid::unit(coords$y + line_height, "npc"),
                                          gp = grid::gpar(col = "grey", lwd = 1)
                                        )

                                        labels <- grid::textGrob(
                                          label = coords$label,
                                          x = grid::unit(coords$x, "npc"),
                                          y = grid::unit(coords$y + line_height, "npc"),
                                          just = c("left", "bottom"),
                                          rot = 45,
                                          gp = grid::gpar(fontsize = 8)
                                        )

                                        grid::gTree(children = grid::gList(lines, labels))
                                      }
)
