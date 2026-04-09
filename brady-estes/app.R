#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)

library(pool)
library(RPostgres)
pool <- dbPool(
  Postgres(),
  host = Sys.getenv("SUPABASE_HOST"),
  port = as.integer(Sys.getenv("SUPABASE_PORT")),
  dbname = Sys.getenv("SUPABASE_DB"),
  user = Sys.getenv("SUPABASE_USER"),
  password = Sys.getenv("SUPABASE_PASS"),
  sslmode = "require"
)
# Automatically closes pool when session or Shiny app ends
onStop(function() {
  poolClose(pool)
})


df_tm <- dbGetQuery(pool, "SELECT *
FROM core_level.trackman_event
WHERE pitcher = $1
LIMIT 200",
params = list("Estes, Brady")
)

# Same query on cal_mus_event
df_mus <- dbGetQuery(pool, "SELECT *
FROM core_level.cal_mus_event
WHERE pitcher = $1
LIMIT 200",
params = list("Estes, Brady")
)
# Combine both sources
df_all <- rbind(
  transform(df_tm, source = "trackman"),
  transform(df_mus, source = "cal_mus")
)
# Write / modify data
dbExecute(pool, "UPDATE core_level.trackman_event
SET reviewed = TRUE
WHERE pitchuid = $1",
          params = list('abc-123')
)
