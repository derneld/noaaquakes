GeomTimelineLabel <- ggproto("GeomTimelineLabel", Geom,
                             required_aes = c("x", "label"),
                             default_aes = aes(y = 0.5, colour = "black", size = 0.5, alpha = 1, magnitude = 1),
                             draw_panel = function(data, panel_params, coord) {
                               coords <- coord$transform(data, panel_params)
                               line_height <- 0.1

                               lines <- segmentsGrob(
                                 x0 = unit(coords$x, "npc"), y0 = unit(coords$y, "npc"),
                                 x1 = unit(coords$x, "npc"), y1 = unit(coords$y + line_height, "npc"),
                                 gp = gpar(col = "grey", lwd = 1)
                               )

                               labels <- textGrob(
                                 label = coords$label,
                                 x = unit(coords$x, "npc"), y = unit(coords$y + line_height, "npc"),
                                 just = c("left", "bottom"), rot = 45,
                                 gp = gpar(fontsize = 9, fontface = "italic")
                               )

                               gTree(children = gList(lines, labels))
                             }
)

geom_timeline_label <- function(mapping = NULL, data = NULL, stat = "TimelineLabel",
                                position = "identity", na.rm = FALSE,
                                show.legend = NA, inherit.aes = TRUE,
                                n_max = NULL, ...) {
  if (is.null(mapping)) mapping <- aes(magnitude = Mag)
  if (is.null(mapping$magnitude)) mapping$magnitude <- aes(m = Mag)$m

  layer(geom = GeomTimelineLabel, mapping = mapping, data = data, stat = stat,
        position = position, show.legend = show.legend, inherit.aes = inherit.aes,
        params = list(na.rm = na.rm, n_max = n_max, ...))
}
