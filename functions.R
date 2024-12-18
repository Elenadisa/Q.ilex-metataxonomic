

################################################################################
#                          ALPHA DIVERSITY                                     #
################################################################################

# This function calculate alpha diversity metrics for a phyloseq object
# 
# phy_objetc <- Phyloseq object created with qiime2 data
# group <- metadata column you want to use to separate data.
# alfa_metrics <- vector with the statistical metrics to calculate alfa diversity
# my comparision <- a list of pairs of condition you want to compare
# stat_metrics <- statistica metric do you want to use to see if there is a significant difference between conditions
# asterisk <- if yes show astherisks in accordance to significance level, if no write the pvalue

alpha_diversity_plot <- function(phy_object, group, alfa_metrics, my_comparisons, stat_metric, asterisk, title){
  library(ggpubr)
  symnum.args <- list(cutpoints = c(0.001, 0.01, 0.05, Inf), symbols = c("***", "**", "*", "ns"))
  #alpha diversity plot
  p <- plot_richness(phy_object, x=group, measures=alfa_metrics) 
  p <- p + geom_boxplot(alpha=9)
  p <- p + theme_light()
  
  if (asterisk == TRUE){
    p <- p + stat_compare_means(method = stat_metrics, comparisons = my_comparisons, label = "p.signif", symnum.args,  p.adjust.method = "BH")
  }else{
    p <- p + stat_compare_means(method = stat_metrics, p.adjust.method = "BH")  
    
  }
  p <- p + ggtitle(label = title) + theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    panel.border = element_rect(colour = "black", fill=NA, size=1),
    axis.title=element_text(size=14,face="bold"),
    axis.text=element_text(size=12),
    strip.text = element_text(size = 14),
    axis.title.x=element_blank())
  
  return(p)
}
  

################################################################################
#                           ABUNDANCE                                          #
################################################################################

filter_abundance_table <- function(phyobj, filter_type, filter){
  if (tolower(filter_type) == "top"){
    top_taxa <- top_taxa(phyobj, n = filter)
    filter_ps <- prune_taxa(top_taxa, phyobj)
    filter.df <- phyloseq::psmelt(filter_ps)
  }else if (tolower(filter_type) == "percentage"){
    filter_ps <- filter_taxa(phyobj, function(x){ mean(x) > filter}, prune = TRUE)
    filter.df <- phyloseq::psmelt(filter_ps)
  }else{
    print("Not valid filter type. Only top and percentage filter available \n
          top = obtain most abundant taxa \n
          percentage = obtain the taxa with more than certain abundance")
  }
  
  return(list(filter_ps, filter.df))
}

plot_abundance_by_taxa <- function(df, taxa, metric, group){
  plt <- ggplot(df ,aes(x=reorder(get(taxa), get(metric)), y=get(metric), group=get(group), fill=get(group))) +
    geom_bar(stat="identity",position="dodge")  +
    theme_classic() +
    theme(axis.text.x = element_text(angle = 90, hjust = 1), 
          legend.title = element_blank(),
          axis.title=element_text(size=14,face="bold"),
          axis.text=element_text(size=12),
          legend.text=element_text(size=12)) +
    scale_fill_grey() +
    geom_errorbar(aes(ymin=get(metric), ymax=get(metric)+sd),
                  width=.2,                    # Width of the error bars
                  position=position_dodge(.9)) +
    ylab(metric) + xlab(taxa) 
  
  return(plt)
  
}

plot_abundance_by_sample <- function(df, sample, metric, taxa_level, x_lab){
  n <- length(unique(df[[taxa_level]]))
  ggplot(df, aes(x=get(sample), y=get(metric), fill=get(taxa_level))) +
    geom_bar(stat='identity') +
    scale_fill_manual(values=rainbow(n))+
    theme_classic() +
    geom_col(color = "black") +
    ylab(metric) +
    xlab(x_lab) +
    theme(axis.text.x  = element_text(angle=90, vjust=0.5),
          panel.border = element_rect(colour = "black", fill=NA, size=1),
          axis.title=element_text(size=14,face="bold"),
          axis.text=element_text(size=12),
          legend.text=element_text(size=12),
          legend.title=element_text(size=14, face="bold")) +
    labs(fill = taxa_level)
}

plot_stacked_abundance <- function(df, metric, taxa_level, group){
  ggplot(df, aes(x=get(group), y=get(metric), fill=get(taxa_level))) +
    geom_bar(stat='identity') +
    geom_col(color = "black") +
    ylab(metric) +
    xlab(taxa_level)+
    theme_grey(base_size = 12) +
    theme(panel.background = element_blank(), 
          axis.text.x  = element_text(angle=90, vjust=0.5),
          panel.border = element_rect(colour = "black", fill=NA, size=1),
          axis.title=element_text(size=14,face="bold"),
          axis.text=element_text(size=12),
          legend.text=element_text(size=12)) +
    labs(fill = taxa_level)
  
}

plot_abundance_heatmap<- function(df, metric, taxa_level, group){
  ggplot(df, aes(get(group), get(taxa_level), fill= get(metric))) + 
    geom_tile() +
    scale_fill_distiller(palette = "Spectral", name = metric) +
    ylab(taxa_level)+
    theme(panel.background = element_blank(),
          axis.title.x=element_blank(),
          axis.text.x  = element_text(angle=90, vjust=0.5),
          panel.border = element_rect(colour = "black", fill=NA, size=1),
          axis.title=element_text(size=14,face="bold"),
          axis.text=element_text(size=12),
          legend.text=element_text(size=12))
}

################################################################################
#                          DIFFERENTIAL ABUNDANCE DESEQ2                       #
################################################################################

daa_point_plot <- function(df, contrast, title){
  
  theme_set(theme_bw())
    #Transform data
  # Phylum order
  x = tapply(df$log2FoldChange, df$Phylum, function(x) max(x))
  x = sort(x, TRUE)
  df$Phylum = factor(as.character(df$Phylum), levels=names(x))
  # Genus order
  x = tapply(df$log2FoldChange, df$Genus, function(x) max(x))
  x = sort(x, TRUE)
  df$Genus = factor(as.character(df$Genus), levels=names(x))
  
    #Create plot
  ggplot(df, aes(y=Genus, x=log2FoldChange, color=Phylum)) + 
    ggtitle(title) +
    geom_vline(xintercept = 0.0, color = "Black", size = 0.5) +
    geom_point(size=3) + 
    theme(axis.text.x = element_text(angle = -90, hjust = 0, vjust=0.5),
          panel.border = element_rect(colour = "black", fill=NA, size=1),
          axis.title=element_text(size=14,face="bold"),
          axis.text=element_text(size=12),
          legend.text=element_text(size=12)) +
    theme_minimal()
}

daa_bar_plot <- function(df, contrast, title){
  theme_set(theme_bw())
  
    #Transform data
  # Phylum order
  x = tapply(df$log2FoldChange, df$Phylum, function(x) max(x))
  x = sort(x, TRUE)
  df$Phylum = factor(as.character(df$Phylum), levels=names(x))
  # Genus order
  x = tapply(df$log2FoldChange, df$Genus, function(x) max(x))
  x = sort(x, TRUE)
  df$Genus = factor(as.character(df$Genus), levels=names(x))
  
    #Generate plot
  ggplot(df) +
    geom_col(aes(x = log2FoldChange, y = Genus, fill = Phylum)) + 
    geom_vline(xintercept = 0.0, color = "Black", size = 0.7)  +
    ggtitle(title) +
    theme(
      panel.border = element_rect(colour = "black", fill=NA, size=1),
      axis.title=element_text(size=14,face="bold"),
      axis.text=element_text(size=12),
      legend.text=element_text(size=12)) +
    theme_minimal()
}

################################################################################
#                          DIFFERENTIAL ABUNDANCE                              #
################################################################################

lefse_lda_plot <- function(df, title){
 ggplot(df) +
 geom_bar(aes(x = ef_lda, y = feature, fill = enrich_group), stat="identity",position="dodge", width = 0.5) +
 xlab("LDA score (log10)") + ylab(" ") +
 ggtitle(title) + 
 theme(legend.title=element_blank())
}

logfoldchange_plot <- function(df, title){
  ggplot(df) +
    geom_col(aes(x = ef_logFC, y = feature, fill = enrich_group)) + 
    geom_vline(xintercept = 0.0, color = "Black", size = 0.7)  +
    xlab("Log Fold Change") + ylab(" ")+ 
    ggtitle(title) +
    theme_minimal()+
    theme(legend.title=element_blank(),
          panel.background = element_blank(),
          axis.text.x  = element_text(angle=90, vjust=0.5),
          panel.border = element_rect(colour = "black", fill=NA, size=1),
          axis.title=element_text(size=14,face="bold"),
          axis.text=element_text(size=12),
          legend.text=element_text(size=12))
}

importance_score_plot <- function(df, title){
  ggplot(df, aes(x = ef_imp, y = feature, fill = enrich_group)) +
    geom_bar(stat="identity",position="stack", width = 0.5) +
    xlab("Importance score") + ylab(" ") +
    ggtitle(title) + 
    theme(legend.title=element_blank(),
          panel.border = element_rect(colour = "black", fill=NA, size=1),
          axis.title=element_text(size=14,face="bold"),
          axis.text=element_text(size=12),
          legend.text=element_text(size=12))
}


aldex_logfoldchange_plot <- function(df, title){
  ggplot(df) +
    geom_col(aes(x = ef_aldex, y = feature, fill = enrich_group)) + 
    geom_vline(xintercept = 0.0, color = "Black", size = 0.7)  +
    xlab("ef_aldex") + ylab(" ")+ 
    ggtitle(title) +
    theme_minimal()+
    theme(legend.title=element_blank(),
          panel.border = element_rect(colour = "black", fill=NA, size=1),
          axis.title=element_text(size=14,face="bold"),
          axis.text=element_text(size=12),
          legend.text=element_text(size=12))
}

CLR_diff_mean_plot <- function(df, title){
  ggplot(df, aes(x = ef_CLR_diff_mean, y = feature, fill = enrich_group)) +
    geom_bar(stat="identity",position="stack", width = 0.5) +
    xlab("CLR_diff_mean") + ylab(" ") +
    ggtitle(title) + 
    theme(legend.title=element_blank(),
          panel.border = element_rect(colour = "black", fill=NA, size=1),
          axis.title=element_text(size=14,face="bold"),
          axis.text=element_text(size=12),
          legend.text=element_text(size=12))
}

################################################################################
#                          RELATIVE ABUNDANCE                                  #
################################################################################

relative_abundance_by_taxa <- function(phyob, taxa_level){
  #group by taxonomic level
  ps_taxa <- phyloseq::tax_glom(phyob, taxa_level)
  #calculate the relative abundance
  ps_rel_abund = transform_sample_counts(ps_taxa, function(x){100*x / sum(x)})
  #obtain a dataframe object from relative abundance table
  taxa.rel.df <- phyloseq::psmelt(ps_rel_abund)
  names(taxa.rel.df)[3] <- paste("Rel_Abundance")
  taxa.rel.df <- taxa.rel.df[!taxa.rel.df$Rel_Abundance == 0,]
  
  return(list(ps_rel_abund, taxa.rel.df))
}



################################################################################
#                          BETA DIVERSITY                                      #
################################################################################

betadiversity_analysis <- function(pseq, method, distance, weighted = FALSE){
  if(tolower(distance) == "unifrac"){
    if(weighted == TRUE){
      phyloseq::ordinate(pseq, method = method, distance = distance, weighted=T)
    }else{
      phyloseq::ordinate(pseq, method = method, distance = distance, weighted=F)
    }
  }else{
    if(weighted == FALSE){
      phyloseq::ordinate(pseq, method = method, distance = distance)
    }else{
      print("These metrics do not use weight")
    }
  }
}

plot_distance <- function(pseq, bd, color, shape=NULL, elipse = TRUE){
  if(is.null(shape) == FALSE){
    plt <- plot_ordination(pseq, bd, color= color, shape=shape) + geom_point(size=3)
  }else{
    plt <- plot_ordination(pseq, bd, color= color) + geom_point(size=3)
  }
  
  plt <- plot_ordination(pseq, bd, color= color, shape=shape) + geom_point(size=3)
  if (elipse ==TRUE){
    plt <- plt + stat_ellipse() 
  }
  
  plt <- plt + theme_classic() +theme(axis.title=element_text(size=14,face="bold"),
                     axis.text=element_text(size=12),
                     legend.text=element_text(size=12),
                     legend.title=element_text(size=14))
  return(plt)
}

plot_distance_network <- function(pseq, distance, color, shape){
  ig <- phyloseq::make_network(pseq, dist.fun=distance, max.dist=0.8)
  phyloseq::plot_network(ig, pseq, color=color, shape=shape, line_weight=0.4, label=NULL)
}


################################################################################
#                   FUNCTIONAL TRAIT ANALYSIS                                  #
################################################################################

obtain_significance_df <- function(diff_t, abund_t){
  library(magrittr)
  if(is.factor(diff_t[, "Significance"])){
    diff_t[, "Significance"] %<>% as.character
  }else{
    if(is.numeric(diff_t[, "Significance"])){
      diff_t[, "Significance"] %<>% round(., 4)
    }
  }
  all_taxa <-levels(reorder(abund_t$Taxa, abund_t$Mean))
  add_letter_text <- diff_t[match(all_taxa, diff_t$Taxa), "Significance"]
  y_start <- 1.01
  y_start_use <- max((abund_t$Mean + abund_t$SE)) * y_start
  textdf <- data.frame(
    x = all_taxa, 
    y = y_start_use, 
    add = add_letter_text, 
    stringsAsFactors = FALSE
  )
  
  return(textdf)
  
}

fta_abundance_barplot <- function(abund_data, text_data, Group){
  ggplot(abund_data, aes(x=Mean, y=reorder(Taxa,Mean), fill = get(Group))) +
    geom_bar(colour="black", stat="identity", position=position_dodge()) +
    geom_errorbar(aes(xmin=Mean, xmax=Mean+SE), width=.2,position=position_dodge(.9)) +
    xlab("Abundance") +
    theme_classic() +
    theme(axis.title.y = element_blank(),
          axis.text=element_text(size=14),
          legend.text=element_text(size=14),
          legend.title=element_blank(),
          axis.title=element_text(size=14,face="bold")) +
    scale_fill_grey(start=0, end=1) +
    geom_text(aes(x = y, y = x, label = add), data = text_data, size = 6, color = "black", inherit.aes = FALSE)
  
}
