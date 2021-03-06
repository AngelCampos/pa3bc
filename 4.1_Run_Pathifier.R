################################################################################
# Running PATHIFIER (Drier et al., 2013)
# Author: Miguel Angel Garcia-Campos https://github.com/AngelCampos
################################################################################

# Install/load package
source("http://bioconductor.org/biocLite.R")
if (!require("pathifier")) {
  biocLite("pathifier", ask =FALSE)
  library(pathifier)
}

# Load expression data for PATHIFIER
exp.matrix <- read.delim(file ="PATHIFIER_matriz_de_expresion_reducida.txt",
                         as.is = T, row.names = 1)

# Loading Genesets annotation
gene_sets <- as.matrix(read.delim(file = "genesets_apop_autop.txt",
                       header = F, sep = "\t", as.is = T))

#  Generate a list that contains genes in genesets
gs <- list()
for (i in 1:nrow(gene_sets)){
  a <- as.vector(gene_sets[i,3:ncol(gene_sets)])
  a <- head(unique(na.omit(a)), -1)
  a <- matrix(a, ncol = 1)
  gs[[length(gs)+1]] <- a
  rm(a,i)
}

# Generate a list that contains the names of the genesets used
pathwaynames <- as.list(gene_sets[,1])

# Generate a list that contains the previos two lists: genesets and their names
PATHWAYS <- list()
PATHWAYS$gs <- gs
PATHWAYS$pathwaynames <- pathwaynames

# Extract information from binary phenotypes. 1 = Normal, 0 = Tumor
normals <- as.vector(as.logical(exp.matrix[1,]))
data <- as.matrix(exp.matrix[-1, ])
dimnames(data) <- NULL
allgenes <- as.vector(rownames(exp.matrix))

# Generate a list that contains previous data: gene expression, normal status,
# and name of genes
DATASET <- list(); DATASET$allgenes <- allgenes[-1]
DATASET$normals <- normals
DATASET$data <- data

# Run Pathifier
PDS<-quantify_pathways_deregulation(DATASET$data, DATASET$allgenes,
                                    PATHWAYS$gs,
                                    PATHWAYS$pathwaynames,
                                    DATASET$normals, attempts = 100,
                                    logfile="logfile.txt", min_std = 0.3957552)
# Remove unnecesary data
rm(gene_sets, data, exp.matrix, allgenes, DATASET, allgenes, PATHWAYS)

# Save image into working directory
save.image("PDS.RData")
