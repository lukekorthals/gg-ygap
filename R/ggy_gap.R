#' gg.y_gap
#'
#' @import ggplot2
#' @import scales
#'
#' @description Create a gap in your ggplot y-axis.
#' @param p your ggplot
#' @param y_segment_start minimum y-value (numerical; e.g., 50)
#' @param y_segment_end maximum y-value (numerical; e.g., 100)
#' @param break_step step size between axis-ticks (numerical; e.g., 10)
#' @param gap_lines gap lines to the right/ left/ both (character string; i.e., "r", "l", "rl")
#' @param gap_line_length length of gap lines in percent (float; e.g., 0.02)
#' @param gap_width width of the gap in percent (float; e.g., 0.01)
#' @param x_min x-axis start value (numerical; e.g., 0)
#'
#' @return your ggplot
#'
#' @examples
#' gg.y_gap(p, 50, 100, 10)
#' gg.y_gap(p, 50, 100, 10, "r", 0.05, 0.04, 0)
#' @export
gg.y_gap <- function(p, y_segment_start, y_segment_end, break_step, gap_lines ="rl", gap_line_length=0.02, gap_width=0.01, x_min=NULL) {
  # get data from plot
  dat <- p$data
  # set values to draw lines, set breaks, etc.
  y_min = y_segment_start - 2*break_step
  y_breaks = seq(y_min,y_segment_end, by=break_step)
  y_segment_labels = seq(y_segment_start, y_segment_end, by=break_step)
  y_min_gap = y_min + break_step - (y_segment_end - y_min) * gap_width
  y_max_gap = y_min + break_step + (y_segment_end - y_min) * gap_width
  y_gap_center = (y_min_gap + (y_max_gap - y_min_gap)/2)
  y_gap_length = y_max_gap - y_min_gap
  y_gap_upper = y_max_gap + (y_segment_end - y_min) * 0.02
  y_gap_lower = y_min_gap - (y_segment_end - y_min) * 0.02
  # set x values depending on continuous or discrete
  x <- as.character(p$mapping[["x"]][2])
  if(length(levels(dat[[x]])) > 0){
    x_max = length(levels(dat[[x]])) + 1
    if(is.null(x_min)){
      x_min = 0
    }
  } else {
    x_max <- max(dat[[x]])
    if(is.null(x_min)){
      x_min <- min(dat[[x]])
    }
  }
  x_gap_lower = x_min - (x_max-x_min)*gap_line_length
  x_gap_upper = x_min + (x_max-x_min)*gap_line_length
  # define break lines
  gap_line_left_alpha = 1
  gap_line_right_alpha = 1
  if(gap_lines == "r") {
    gap_line_left_alpha = 0
  }
  if(gap_lines == "l") {
    gap_line_right_alpha = 0
  }
  # add y axis with break
  p <- p +
    # alter original y axis
    scale_y_continuous(
      limits = c(y_min, y_segment_end),
      breaks = c(y_breaks),
      labels = c(0, "", y_segment_labels),
      oob = oob_squish # prevents clipping for bar charts
    ) +
    theme(
      axis.line.y = element_blank(),
      axis.ticks.y = element_line(colour = c("black", "white", rep("black", length(y_segment_labels))),
                                  size=0.1)
    ) +
    # new y axis
    annotate("segment", x=x_min, xend=x_min, y=y_max_gap, yend=y_segment_end, color="black") +
    annotate("segment", x=x_min, xend=x_min, y=y_min, yend=y_min_gap, color="black") +
    # left
    annotate("segment", x=x_gap_lower, xend=x_min, y=y_gap_lower, yend=y_min_gap, color="black", alpha=gap_line_left_alpha) +
    annotate("segment", x=x_gap_lower, xend=x_min, y=y_gap_lower+y_gap_length, yend=y_max_gap, color="black", alpha=gap_line_left_alpha) +
    # right
    annotate("segment", x=x_min, xend=x_gap_upper, y=y_max_gap-y_gap_length, yend=y_gap_upper-y_gap_length, color="black", alpha=gap_line_right_alpha) +
    annotate("segment", x=x_min, xend=x_gap_upper, y=y_max_gap, yend=y_gap_upper, color="black", alpha=gap_line_right_alpha) +
    coord_cartesian(expand = FALSE, xlim = c(x_min,x_max), clip = "off")
  return(p)
}
