# Make birthday calendar with R

R for everything, including making a birthday calendar.

* `data/birthday.csv`: CSV containing birthdays (months and days required)
* `img/Rlogo.png`: Logo placed on the header
* `calendar.pdf`: Calendar output file ([preview here](https://github.com/earowang/calendar-maker/blob/master/calendar.pdf))

## Usage

1. Clone the repo and open `calendar-maker.Rproj` with RStudio
2. Run `devtools::install_deps()` to install packages required for making calendar
3. `source("create-calendar.R")`
4. Edit `create-calendar.R` to make your own calendar
