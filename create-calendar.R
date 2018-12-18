pkg_chr <- c("fs", "magick", "lubridate", "tidyverse", "extrafont",
  "sugrrants", "patchwork", "ggpomological")
lapply(pkg_chr, library, quietly = TRUE, character.only = TRUE)

print_calendar <- function(year = NULL, width, height) {
  fr <- image_read("img/Rlogo.png")
  header <- tibble(x = 1:10, y = 1)
  g <- grid::rasterGrob(fr, interpolate = TRUE)
  r_logo <- header %>% 
    ggplot(aes(x, y)) +
    geom_blank() +
    annotation_custom(g, xmin = 8, xmax = 10, ymin = -Inf, ymax = Inf) +
    theme_void()

  if (is.null(year)) {
    year <- format(Sys.Date(), "%Y")
  }
  bday <- read_csv("data/birthday.csv") %>%
    mutate(birthday = dmy(paste(birthday, year, sep = "-"))) %>%
    drop_na(birthday) %>%
    group_by(birthday) %>%
    summarise(nickname = paste(nickname, collapse = "\n & \n"))

  min_date <- make_date(year)
  days <- if_else(leap_year(min_date), 365, 364)
  year_cal <-
    tibble(
      date = min_date + 0:days,
      x = 0L, y = 0L,
      text = substring(wday(date, label = TRUE), 1, 1),
      colour = as.factor(if_else(text == "S", 1, 0)),
      title = month(date, label = TRUE, abbr = FALSE)
    ) %>%
    left_join(bday, by = c("date" = "birthday")) %>%
    mutate(text = if_else(is.na(nickname), text, nickname))

  pdf(file = "calendar.pdf", width = width, height = height)
  for (i in seq_len(12)) {
    start_date <- make_date(year, i)
    end_date <- start_date + months(1)
    tbl_cal <- year_cal %>% 
      filter(date >= start_date, date < end_date)
    cal <- tbl_cal %>%
      ggplot(aes(x = x, y = y)) +
      geom_text(
        aes(x = x, y = y, label = text, colour = colour),
        data = tbl_cal %>% filter(is.na(nickname)),
        size = 8, alpha = 0.1
      ) +
      geom_text(
        aes(label = text, colour = colour),
        data = tbl_cal %>% filter(!is.na(nickname)),
        size = 4, alpha = 0.8, fontface = "bold.italic"
      ) +
      facet_calendar(~ date, format = "%e") +
      labs(
        x = "", y = "",
        title = tbl_cal$title[[1]]
      ) +
      scale_color_pomological() +
      theme_pomological_fancy() +
      theme(
        axis.ticks = element_blank(),
        axis.text = element_blank()
      ) +
      guides(colour = "none")

    page <- plot_spacer() + r_logo + cal +
      plot_layout(ncol = 1, heights = c(0.1, 0.2, 3))
    print(page)
  }
  dev.off()
  embed_fonts("calendar.pdf", outfile = "calendar.pdf")
}

print_calendar()
