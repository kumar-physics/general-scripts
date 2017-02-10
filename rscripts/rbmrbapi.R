library(httr)
library(rjson)


getEntry<-function(query){
  api_url="http://webapi.bmrb.wisc.edu/v0.3/jsonrpc"
  out<-fromJSON(content(POST(api_url,encode="json",body = query),'text'))
  if (!is.null(out$error)){
    message(out$error$message)
    message(out$error$data$message)
  }else{
    as.data.frame(out)
  }
}

a<-POST("http://webapi.bmrb.wisc.edu/v0.3/jsonrpc",encode="json",body=query)

q<-list(
  method = "select",
  jsonrpc = 2.0,
  params = list(
    where = list(
      Entry_ID="16000"),
    select="*",
    from="Atom_chem_shift"
  ),
  id=1
)
query<-toJSON(q)
df<-getEntry(query)
query<-s
POST(api_url,encode="json",body = query)
api_url="http://webapi-master.bmrb.wisc.edu/query"
df<-POST(api_url,encode="json",body = toJSON(q))

cs_query<-function(res,atm){
q<-list(
  id=34,
  jsonrpc="2.0",
  method="select",
  params=list(
    #database="bmrb",
    query=list(
      select=list("Entry_ID","Comp_ID","Comp_index_ID","Atom_ID","Atom_type","Assigned_chem_shift_list_ID","Val","Ambiguity_code"),
      from="Atom_chem_shift",
      where=list(Comp_ID=res,Atom_ID=atm)
    )
  )
)
q
}

s<-cs_query('ALA','CA')
dd<-getEntry(s)

show_condition <- function(code) {
  tryCatch(code,
           error = function(c) "error",
           warning = function(c) "warning",
           message = function(c) "message"
  )
}

show_condition(stop("!"))

read.csv2 <- function(file, ...) {
  tryCatch(read.csv(file, ...), error = function(c) {
    c$message <- paste0(c$message, " (in ", file, ")")
    stop(c)
  })
}
read.csv("code/dummy.csv")
paste0("Something wrong in query",toJSON(q))

urls <- c(
  "http://stat.ethz.ch/R-manual/R-devel/library/base/html/connections.html",
  "http://en.wikipedia.org/wiki/Xz",
  "xxxxx"
)
readUrl <- function(url) {
  out <- tryCatch(
    {
      # Just to highlight: if you want to use more than one
      # R expression in the "try" part then you'll have to
      # use curly brackets.
      # 'tryCatch()' will return the last evaluated expression
      # in case the "try" part was completed successfully

      message("This is the 'try' part")

      readLines(con=url, warn=FALSE)
      # The return value of `readLines()` is the actual value
      # that will be returned in case there is no condition
      # (e.g. warning or error).
      # You don't need to state the return value via `return()` as code
      # in the "try" part is not wrapped insided a function (unlike that
      # for the condition handlers for warnings and error below)
    },
    error=function(cond) {
      message(paste("URL does not seem to exist:", url))
      message("Here's the original error message:")
      message(cond)
      # Choose a return value in case of error
      return(NA)
    },
    warning=function(cond) {
      message(paste("URL caused a warning:", url))
      message("Here's the original warning message:")
      message(cond)
      # Choose a return value in case of warning
      return(NULL)
    },
    finally={
      # NOTE:
      # Here goes everything that should be executed at the end,
      # regardless of success or error.
      # If you want more than one expression to be executed, then you
      # need to wrap them in curly brackets ({...}); otherwise you could
      # just have written 'finally=<expression>'
      message(paste("Processed URL:", url))
      message("Some other message at the end")
    }
  )
  return(out)
}

y <- lapply(urls, readUrl)


s<-content(df,'text')
