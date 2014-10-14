# Variables that can be put on the x and y axes
axis_vars <- c(
  "Resolution"="resolution",
  "Area"="area",
  "Core surface score" = "csScore",
  "Core rim score" = "crScore",
  "GM score"="gmScore",
  "Core surface 1"="cs1",
  "Core surface 2"="cs2",
  "Core rim 1"="cr1",
  "Core rim 2"="cr2",
  "delta cs"="dcs",
  "delta cr"="dcr",
  "Homologs1"="h1",
  "Homologs2"="h2"
)
color_vars <- c(
  "Final call"="final",
  "Core-rim call"="cr",
  "Core-surface call"="cs",
  "GM call"="gm",
  "Space group"="spaceGroup",
  "Operator type"="operatorType",
  "Operator"="operator",
  "Assembly"="bio_size_tag",
  "Authors"="authors",
  "PISA"="pisa",
  "Taxonomy1"="tax1",
  "Taxonomy2"="tax2",
  "Exp. method"="expMethod"
  )
calls <-c(
  "All"="xtal|bio|nopred",
  "Xtal"="xtal",
  "Bio"="bio",
  "Nopred"="nopred")
tax<-c(
  "All"="Archaea|Bacteria|Eukaryota|Viruses|unclassified sequences|other sequences|unknown",
  "All(meaningful)"="Archaea|Bacteria|Eukaryota|Viruses",
  "Archaea"="Archaea",
  "Bacteria"="Bacteria",
  "Eukaryota"="Eukaryota",
  "Viruses"="Viruses",
  "unclassified sequences"="unclassified sequences",
  "other sequences"="other sequences",
  "unknown"="unknown"
  )
