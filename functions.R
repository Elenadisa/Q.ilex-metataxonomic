

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
