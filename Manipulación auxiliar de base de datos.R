#Manipulación auxiliar de bases de datos



### Población municipal CONAPO 2015-2030
#Población mun<icipios 2015-2030

setwd("C:/Users/Gib99/Documents/Unam/TEP/Base de datos")
library(pacman)

p_load(dplyr, readr, foreign, plotly, tidyverse, haven)

################################################################################
############################ Auxiliar Poblacion ################################
################################################################################


#Funciones auxiliares
substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}
#DF con población
lookup <- c(year ="AÑO")
poblac_2 <- read.csv("Poblacion/base_municipios_final_datos_02.csv", header=T, stringsAsFactors=FALSE, fileEncoding="latin1") %>% 
  rename(all_of(lookup))
poblac_1 <- read.csv("Poblacion/base_municipios_final_datos_01.csv", header=T, stringsAsFactors=FALSE, fileEncoding="latin1") %>% 
  rename(all_of(lookup))
poblac <- bind_rows(poblac_1, poblac_2)

poblac$ID_MUNICIPIO <- as.character(substrRight(poblac$CLAVE,3))
poblac$ID_ENTIDAD <- as.character(poblac$CLAVE_ENT)
poblac$year <- as.numeric(poblac$year)

poblacion <- aggregate(poblac$POB, by = list(poblac$year, poblac$ID_ENTIDAD, poblac$ID_MUNICIPIO, poblac$MUN), FUN = sum)
colnames(poblacion) <- c("ANIO", "ID_ENTIDAD", "ID_MUNICIPIO", "MUN", "POB")
poblacion <- poblacion %>% mutate(clvmun = paste0(ID_ENTIDAD, ID_MUNICIPIO))


#Exportación a DTA
write_dta(
  poblacion,
  "Pob2015_2030.dta.",
  version = 14,
  label = attr(data, "label"),
  strl_threshold = 2045,
  adjust_tz = TRUE
)

################################################################################
################# Auxiliar Aprovechamientos y Participaciones ##################
################################################################################

# Directorio donde se encuentran los archivos CSV
directorio <- "C:/Users/Gib99/Documents/Unam/TEP/Base de datos/efipem/conjunto_de_datos"

# Obtener la lista de archivos CSV en el directorio
archivos_csv <- list.files(directorio, pattern = "\\.csv$", full.names = TRUE)

# Crear una lista para almacenar los data frames
lista_data_frames <- lapply(archivos_csv, read_csv)

# Combinar los data frames en uno solo
conceptos <- c("Impuestos", "Contribuciones de Mejoras", "Derechos", "Productos", "Aprovechamientos", "Participaciones federales", "Aportaciones federales y estatales","Otros ingresos", "Otros ingresos extraordinarios", "Financiamiento", "Disponibilidad inicial", "Total de ingresos", "Impuesto predial", "Total de egresos")

efipem1321 <- bind_rows(lista_data_frames) 

#Creamos una base con solo los cconeptos que nos interesan
efipem1321filt <- efipem1321 %>% filter (DESCRIPCION_CATEGORIA %in% conceptos)
efipem1321filt <- subset(efipem1321filt, !(TEMA == "Egresos" & DESCRIPCION_CATEGORIA == "Derechos"))


#Cambiamos de nombre columnas de nuestro interés
aprov_part <- efipem1321filt %>% rename(cve_ent = ID_ENTIDAD, cve_mun = ID_MUNICIPIO, year = ANIO) %>%
  pivot_wider(names_from = DESCRIPCION_CATEGORIA, 
              values_from = VALOR, 
              id_cols = c(cve_ent, cve_mun, year),
              values_fill = NULL)

#efipem1321filt %>%
#  dplyr::group_by(ID_ENTIDAD, ID_MUNICIPIO, ANIO, DESCRIPCION_CATEGORIA) %>%
#  dplyr::summarise(n = dplyr::n(), .groups = "drop") %>%
#  dplyr::filter(n > 1L) 
 aprov_part <-  aprov_part %>% rename("Participaciones_federales" = "Participaciones federales", 
                                      "Total_ingresos" = "Total de ingresos", "Aportaciones" = "Aportaciones federales y estatales",
                                      "Impuesto_predial_efipem" = "Impuesto predial", 
                                      "Total_egresos" = "Total de egresos",
                                      "Contribuciones_de_Mejoras" = "Contribuciones de Mejoras", 
                                      "Otros_ingresos" = "Otros ingresos", 
                                      "Otros_ingresos_extraordinarios" = "Otros ingresos extraordinarios", 
                                      "Disponibilidad_inicial" = "Disponibilidad inicial") 
 
 write.dta(aprov_part, "Predial/efipem13_22.dta")












