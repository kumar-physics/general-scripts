# Variables that can be put on the x and y axes
axis_vars <- c(
  "Resolution"="resolution",
  "Area"="area",
  "Core surface score" = "csScore",
  "Core rim score" = "crScore",
  "GM score"="gmScore"
)
color_vars <- c(
  "Final call"="final",
  "Core-rim call"="cr",
  "Core-surface call"="cs",
  "GM call"="gm",
  "Core-surface score"="csScore",
  "Core-rim score"="crScore",
  "GM score"="gmScore",
  "Resolution"="resolution",
  "Homologs side 1"="h1",
  "Homologs side 2"="h2",
  "Area"="area",
  "Space group"="spaceGroup",
  "Operator type"="operatorType",
  "Operator"="operator",
  "Assembly"="bio_size_tag",
  "Authors"="authors",
  "PISA"="pisa"
  )
calls <-c(
  "All"="xtal|bio|nopred",
  "Xtal"="xtal",
  "Bio"="bio",
  "Nopred"="nopred")
