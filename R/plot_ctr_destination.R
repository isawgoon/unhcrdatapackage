# WARNING - Generated by {fusen} from /dev/flat_full.Rmd: do not edit by hand

#' Tree map of Population Groups within a country
#'
#' @param year Numeric value of the year (for instance 2020)
#' @param country_origin_iso3c Character value with the ISO-3 character code of the Country of Asylum
#' @param pop_type Vector of character values. Possible population type (e.g.: REF, IDP, ASY, VDA, OOC, STA)
#' 
#' @export
#'

#' @examples
#' # 
#' plot_ctr_destination(year = 2021,
#'                      country_origin_iso3c = "COL",
#'                      pop_type = c("REF", "ASY")
#'          )
#' 
plot_ctr_destination <- function(year = 2021,
                                 country_origin_iso3c = country_origin_iso3c,
                                  pop_type = pop_type) {
  require(ggplot2)
  require(tidyverse)
  require(scales)
  
  
Destination <- dplyr::left_join( x= unhcrdatapackage::end_year_population_totals_long, 
                                                     y= unhcrdatapackage::reference, 
                                                     by = c("CountryAsylumCode" = "iso_3"))  |>
  dplyr::filter(CountryOriginCode  == country_origin_iso3c  & 
                 Year == year &
                Population.type  %in% as.vector(pop_type)  )  |>  
   dplyr::mutate(CountryAsylumName = str_replace(CountryAsylumName, " \\(Bolivarian Republic of\\)", ""),
         CountryAsylumName = str_replace(CountryAsylumName, "Iran \\(Islamic Republic of\\)", "Iran"),
         CountryAsylumName = str_replace(CountryAsylumName, "United States of America", "USA"),
         CountryAsylumName = str_replace(CountryAsylumName, "United Kingdom of Great Britain and Northern Ireland", "UK")) |> 
   
   dplyr::group_by( CountryAsylumName) |>
   dplyr::summarise(DisplacedAcrossBorders = sum(Value) )  |>
   dplyr::mutate( DisplacedAcrossBordersRound =  ifelse(DisplacedAcrossBorders > 1000, 
                            paste(scales::label_number( accuracy = .1,
                                   scale_cut = scales::cut_short_scale())(DisplacedAcrossBorders)),
                            as.character(DisplacedAcrossBorders) ) ) |>
   dplyr::arrange(desc(DisplacedAcrossBorders)) |>
   head(10) |>
   dplyr::filter(DisplacedAcrossBorders >0)

if( nrow(Destination) ==  0 ){
  cat(paste0("There's no recorded countries of destination for ",country_origin_iso3c ))
  
} else {


#Make plot
p <- ggplot(Destination, aes(x = reorder(CountryAsylumName, DisplacedAcrossBorders), ## Reordering country by Value
                           y = DisplacedAcrossBorders)) +
  geom_bar(stat = "identity", 
           position = "identity", 
           fill = "#0072bc") + # here we configure that it will be bar chart+
## Format axis number
  scale_y_continuous( label = scales::label_number(scale_cut = cut_short_scale())) + 
  
  ## Position label differently in the bar in white - outside bar in black
  geom_label( data = subset(Destination, DisplacedAcrossBorders < max(DisplacedAcrossBorders) / 1.5),
              aes(x = reorder(CountryAsylumName, DisplacedAcrossBorders), 
                  y = DisplacedAcrossBorders,
                  label= DisplacedAcrossBordersRound),
              hjust = -0.1 ,
              vjust = 0.5, 
              colour = "black", 
              fill = NA, 
              label.size = NA, 
              #family = "Lato", 
              size = 4   ) +  

  geom_label( data = subset(Destination, DisplacedAcrossBorders >= max(DisplacedAcrossBorders) / 1.5),
              aes(x = reorder(CountryAsylumName, DisplacedAcrossBorders), 
                  y = DisplacedAcrossBorders,
                  label= DisplacedAcrossBordersRound),
              hjust = 1.1 ,
              vjust = 0.5, 
              colour = "white", 
              fill = NA, 
              label.size = NA, 
              # family = "Lato", 
              size = 4   ) +   
  # Add `coord_flip()` to make your vertical bars horizontal:
  coord_flip() + 
  
  ## and the chart labels
  labs(title = paste0("What are the main destinations for Forcibly Displaced People?" ),
       
       subtitle = paste0("Top Destination Countries - Data as of ",year, " for population from ",country_origin_iso3c ), 
       x = "",
       y = "",
       caption = "Data: UNHCR Refugee Population Statistics Database; Visualisation: UnhcrDataPackage.\n Forced Displacement includes Refugees, Asylym Seekers and Venezuelan Displaced Abroad Population Group.") +
    
  # Style  
  geom_hline(yintercept = 0, size = 1.1, colour = "#333333") +
 #  unhcRstyle::unhcr_theme(base_size = 12)  + ## Insert UNHCR Style
  theme(panel.grid.major.x = element_line(color = "#cbcbcb"), 
        panel.grid.major.y = element_blank()) ### changing grid line that should appear
  
  print(p)
  
  }
}

