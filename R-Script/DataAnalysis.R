#Install required packages
if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("DESeq2")
library("DESeq2")

library("RColorBrewer")

BiocManager::install("org.Hs.eg.db")
library(org.Hs.eg.db)

BiocManager::install('EnhancedVolcano')
library(EnhancedVolcano)

install.packages('pheatmap')
library("pheatmap")

BiocManager::install('clusterProfiler')
library("clusterProfiler")


#read modified featureCounts table into R
data <- read.csv('featureCounts_table_modified.txt', header=TRUE, sep='\t', row.names = 'Geneid')

#rename column names
col_names <- colnames(data)
col_names_split <- strsplit(col_names, split='.', -1)
new_col_names <- col_names_split[[1]][7]
for (i in seq(2,12)) {
  new_col_names <- c(new_col_names, col_names_split[[i]][7])
}
new_col_names <- strsplit(new_col_names, split='_')
new_col_names_2 <- new_col_names[[1]][1]
for (i in seq(2,12)) {
  new_col_names_2 <- c(new_col_names_2, new_col_names[[i]][1])
}

names(data) <- new_col_names_2  



#Create the DESeqDataSet object
##read group file
groups <- read.csv('Grouping.csv', header=TRUE, row.names='Sample')
groups2 <- read.csv('Grouping2.csv', header=TRUE, row.names='Sample')

##check if column order of data same as row order of groups
if (!all(rownames(groups) == colnames(data))) {
  data <- data[, rownames(groups)]
}else{
  all(rownames(groups) == colnames(data))
}

##create DESeqDataSet
dds <- DESeqDataSetFromMatrix(countData = data,
                              colData = groups,
                              design = ~ Group)

dds2 <- DESeqDataSetFromMatrix(countData = data,
                               colData = groups2,
                               design = ~ Group2)
#Run DESeq2:DESeq
dds <- DESeq(dds)
results(dds)

dds2 <- DESeq(dds2)
results(dds2)

#Remove dependence of the variance on the mean
rld <- rlog(dds, blind=TRUE)
head(assay(rld), 3)

rld2 <- rlog(dds2, blind=TRUE)
head(assay(rld2), 3)

#Quality Check: cluster of samples based on gene expression
plotPCA(rld, intgroup=c("Group"))

pcaData <- plotPCA(rld2, intgroup=c("Group2", "Group"), returnData=TRUE)
percentVar <- round(100 * attr(pcaData, "percentVar"))
ggplot(pcaData, aes(PC1, PC2, shape=Group2, color=Group, )) + 
  geom_point(size=3)+
  xlab(paste0("PC1: ",percentVar[1],"% variance")) +
  ylab(paste0("PC2: ",percentVar[2],"% variance")) + 
  coord_fixed()



#6

#-----------NonTNBC vs TNBC -------------------------
res_nontnbc_vs_tnbc <- results(dds, contrast = c("Group", "NonTNBC", "TNBC"))
nrow(res_nontnbc_vs_tnbc)
ens <- rownames(res_nontnbc_vs_tnbc)
symbols <- mapIds(org.Hs.eg.db, keys = ens,
                  column = c('SYMBOL'), keytype = 'ENSEMBL')
symbols <- symbols[!is.na(symbols)]
symbols <- symbols[match(rownames(res_nontnbc_vs_tnbc), names(symbols))]

res_nontnbc_vs_tnbc['gene_name']<- symbols
nrow(res_nontnbc_vs_tnbc)

#all
EnhancedVolcano(res_nontnbc_vs_tnbc,
                lab = res_nontnbc_vs_tnbc$gene_name,
                x = 'log2FoldChange',
                y = 'pvalue',
                title='NonTNBC vs TNBC')

#select only genes where padj < 0.05
res_nontnbc_vs_tnbc_padj <- res_nontnbc_vs_tnbc[which(res_nontnbc_vs_tnbc$padj < 0.05), ]
nrow(res_nontnbc_vs_tnbc_padj)
#only p-adj <0.05
EnhancedVolcano(res_nontnbc_vs_tnbc_padj,
                lab = res_nontnbc_vs_tnbc_padj$gene_name,
                x = 'log2FoldChange',
                y = 'pvalue',
                title='NonTNBC vs TNBC; p-adj < 0.05')

#total number of DE genes
nr_nontnbc_vs_tnbc <- nrow(res_nontnbc_vs_tnbc_padj)

#number of DE genes up-regulated
nr_up_nontnbc_vs_tnbc <- nrow(res_nontnbc_vs_tnbc_padj[which(res_nontnbc_vs_tnbc_padj$log2FoldChange > 0), ])

#number of DE genes down-regulated
nr_down_nontnbc_vs_tnbc <- nrow(res_nontnbc_vs_tnbc_padj[which(res_nontnbc_vs_tnbc_padj$log2FoldChange < 0), ])


#take log2FoldChange absolute values
res_nontnbc_vs_tnbc_padj
res_nontnbc_vs_tnbc_padj['log2FoldChangeAbs'] <- abs(res_nontnbc_vs_tnbc_padj$log2FoldChange)
df_res_nontnbc_vs_tnbc_padj <-as.data.frame(res_nontnbc_vs_tnbc_padj)

#ordered by log2FoldChangeAbs decreasing order (most extrem cases)
df_nontnbc_vs_tnbc <- df_res_nontnbc_vs_tnbc_padj[order(df_res_nontnbc_vs_tnbc_padj$log2FoldChangeAbs, decreasing=TRUE),]
df_nontnbc_vs_tnbc_top_100 <- head(df_nontnbc_vs_tnbc, 100)
df_nontnbc_vs_tnbc_top_10 <- head(df_nontnbc_vs_tnbc, 10)



#ordered by padj increasing order
df_nontnbc_vs_tnbc_by_padj <- df_res_nontnbc_vs_tnbc_padj[order(df_res_nontnbc_vs_tnbc_padj$padj, decreasing=FALSE),]
df_nontnbc_vs_tnbc_top_100_by_padj <- head(df_nontnbc_vs_tnbc_by_padj, 100)
df_nontnbc_vs_tnbc_top_10_by_padj <- head(df_nontnbc_vs_tnbc_by_padj, 10)


#investigate expression level of top genes
normalized_counts <- counts(dds, normalized=TRUE)
expression_levels <- normalized_counts[rownames(df_nontnbc_vs_tnbc_top_10_by_padj), ]
expression_levels_nontnbc_tnbc <- subset(expression_levels, select=c(NonTNBC1, NonTNBC2, NonTNBC3, TNBC1, TNBC2, TNBC3))


heatmap(expression_levels, main='Heatmap of Gene Expression')
heatmap(expression_levels_nontnbc_tnbc, main='Heatmap of Gene Expression')

#genes from paper

normalized_counts_paper_genes <- normalized_counts[c('ENSG00000113140', 'ENSG00000127022', 'ENSG00000087086'), ]
normalized_counts_paper_genes <- subset(normalized_counts_paper_genes, select=c(NonTNBC1, NonTNBC2, NonTNBC3, TNBC1, TNBC2, TNBC3, Normal1, Normal2, Normal3))
ens_2 <- rownames(normalized_counts_paper_genes)
symbols_2 <- mapIds(org.Hs.eg.db, keys = ens_2,
                  column = c('SYMBOL'), keytype = 'ENSEMBL')
symbols_2 <- symbols_2[!is.na(symbols_2)]
symbols_2 <- symbols_2[match(rownames(normalized_counts_paper_genes), names(symbols_2))]

rownames(normalized_counts_paper_genes) <- symbols_2

##heatmap
heatmap(normalized_counts_paper_genes, main='Heatmap of Gene Expression', Colv=NA, cexRow = 1, cexCol=1, cex.main=1)






#7. Over-representation analysis
nontnbc_tnbc_gene <- rownames(res_nontnbc_vs_tnbc_padj)
nontnbc_tnbc_gene
all_orgDB <- org.Hs.eg.db
nontnbc_tnbc_universe <- rownames(res_nontnbc_vs_tnbc)
nontnbc_tnbc_universe
nontnbc_tnbc_ont <- "BP" #Biological Process
nontnbc_tnbc_keyType <- "ENSEMBL"

ego <- enrichGO(gene = nontnbc_tnbc_gene,
         universe = nontnbc_tnbc_universe,
         OrgDb = all_orgDB,
         keyType = nontnbc_tnbc_keyType,
         ont = nontnbc_tnbc_ont,
         
         
         )
ego
head(ego)

#Bar plots
library(enrichplot)
barplot(ego, showCategory = 10)


