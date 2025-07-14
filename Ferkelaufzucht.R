### Statistisches Praktikum WiSe 2019/20 ###
### Schwanzbeißen in der Ferkelaufzucht ###
### Kommilitone A, Kommilitone B, Thi Thuy Pham und Kommilitone C ### 

# Einlesen der Daten
# Hier in den Anführungszeichen muss der Ordner reinkopiert werden, in dem
# sich alle Datensätze befinden müssen, die verwendet werden
setwd("C:/Uni/05_WiSe 2019_20/Statistisches Praktikum/Daten_24.10.2019/Daten_end")

# Farben für Plots
color_Sverletz <- c("#fcbba1", "#fb6a4a", "#cb181d", "#67000d")

# Installieren der Pakete
# Alle install.packages("...") Befehle müssen auf jedem Computer einmal ohne
# Raute davor ausgeführt werden, damit die jeweiligen Pakete auf dem Computer
# installiert werden

# install.packages("tidyverse")
# install.packages("tibble")
# install.packages("ISLR") für glm()
# install.packages("sjPlot")
# install.packages("sjlabelled")
# install.packages("sjmisc")
# install.packages("effects")
# install.packages("jtools")
# install.packages("ggstance")
# install.packages("lme4")
# install.packages("ROCR")
# install.packages("caret")
# install.packages("xlsx")
# install.packages("RColorBrewer")
# install.packages("car")


# Jedes Paket, das verwendet wird, muss bei jeden Start des Programms neu 
# geladen werden

library(tidyverse)
library(tibble)
library(ISLR)
library(sjPlot)
library(sjlabelled)
library(sjmisc)
library(effects)
library(ggstance)
library(lme4)
library(ROCR)
library(caret)
library(xlsx)
library(RColorBrewer)
library(car)

# Hier wird eine Funktion definiert, die hilft,
# Excel-Datensätze mit mehreren Sheets einzulesen

read_excel_allsheets <- function(filename, tibble = FALSE) {
  sheets <- readxl::excel_sheets(filename)
  x <- lapply(sheets, function(X) readxl::read_excel(filename, sheet = X))
  if(!tibble) x <- lapply(x, as.data.frame)
  names(x) <- sheets
  x
}

# Vektor, der später bei Wiederholungsschleifen verwendet wird.
# Da für K12 die Struktur der Daten anders ist (überhaupt nicht vorhanden), 12 nicht in for loop verwendbar.
numvec_12 <- c(1:11, 13:19)

# Einlesen des Hauptdatensatzes mit den Bonituren für K1-K19
# Daten K1-K19
Daten_K1_K19 <- read_excel_allsheets("Daten_K1-K19_ohne_Grafiken.xlsx")


# In  R gibt es verschiedene Variablentypen.
# Wir wollen, dass jede Variable in allen 19 Durchgängen denselben Typen hat.
# Deshalb wird hier die Variable Sverletz in eine numerische Variable umgewandelt.
# Variable Sverletz in numeric umwandeln
for (i in numvec_12) {
  Daten_K1_K19[[i]]$Sverletz <- as.numeric(Daten_K1_K19[[i]]$Sverletz)
}

#Variable Tier_Nr in double umwandeln
for (i in numvec_12) {
  Daten_K1_K19[[i]]$Tier_Nr <- as.double(Daten_K1_K19[[i]]$Tier_Nr)
}

# Hier wird mithilfe der Variable Bucht, die Variable Abteil erstellt.
# Abteil hinzufügen

for (i in c(1:11, 13, 16, 18:19)) {
  Daten_K1_K19[[i]]$Abteil <- "F6"
  Daten_K1_K19[[i]]$Abteil[Daten_K1_K19[[i]]$Bucht %in% c("F5 B1", "F5 B2", "F5 B3", "F5 B4")] <- "F5"
}

for (i in c(14, 15, 17)) {
  Daten_K1_K19[[i]]$Abteil <- "F3" 
}

# Jetzt wird mithilfe der variable Bucht überprüft, ob es sich um 
# Fensterbuchten handelt und dann an den Datensatz hinzugefügt.
# Fensterbucht hinzufügen
for (i in numvec_12) {
  Daten_K1_K19[[i]]$Fensterbucht <- "nein"
  Daten_K1_K19[[i]]$Fensterbucht[Daten_K1_K19[[i]]$Bucht %in% c("F5 B4", "F6 B4")] <- "ja"
  Daten_K1_K19[[i]]$Fensterbucht <- factor(Daten_K1_K19[[i]]$Fensterbucht, levels = c("nein", "ja"))
}


# Im folgenden wird aus dem Gesamtdatensatz der Bonituren für jeden Durchgang ein
# einzelner Datensatz erstellt, um z.B. auf die Variable Behandlung zugreifen zu können,
# die im folgenden auch bearbeitet wird, dass gleiche Behandlungen die gleiche 
# Benennung haben.
# Z.B. sollen unterschiedliche Benennungen im Datensatz, wie z.B. "BW" und "Bewegung"
# zur Bezeichnung "Bewegung" vereinheitlicht werden.

Daten_K1 <- Daten_K1_K19$K1
Daten_K2 <- Daten_K1_K19$K2
Daten_K3 <- Daten_K1_K19$K3
Daten_K3$Behandlung[Daten_K3$Behandlung == "Tierwohl"] <- "Tierwohl 20"

Daten_K4 <- Daten_K1_K19$K4
Daten_K4$Behandlung[Daten_K4$Behandlung == "Tierwohl"] <- "Tierwohl 20"

Daten_K5 <- Daten_K1_K19$K5
Daten_K6 <- Daten_K1_K19$K6
Daten_K7 <- Daten_K1_K19$K7
Daten_K8 <- Daten_K1_K19$K8

Daten_K9 <- Daten_K1_K19$K9
Daten_K10 <- Daten_K1_K19$K10
Daten_K10$Behandlung[Daten_K10$Behandlung == "Tierwohl20"] <- "Tierwohl 20"
Daten_K10$Behandlung[Daten_K10$Behandlung == "Tierwohl27"] <- "Tierwohl 27"
Daten_K10$Behandlung[Daten_K10$Behandlung == "Standard28"] <- "Standard"
Daten_K10$Behandlung[Daten_K10$Behandlung == "Standard21"] <- "Standard 21"

Daten_K11 <- Daten_K1_K19$K11
Daten_K11$Behandlung[Daten_K11$Behandlung == "Standard 28"] <- "Standard"

Daten_K12 <- Daten_K1_K19$K12
Daten_K13 <- Daten_K1_K19$K13
Daten_K13$Behandlung[Daten_K13$Behandlung == "kurz"] <- "kupiert"
Daten_K13$Behandlung[Daten_K13$Behandlung == "lang"] <- "zweidrittel"

Daten_K14 <- Daten_K1_K19$K14
Daten_K14$Behandlung[Daten_K14$Behandlung == "TW 20"] <- "Tierwohl 20 F3"
Daten_K14$Behandlung[Daten_K14$Behandlung == "TW 20+"] <- "Tierwohl 20+ F3"

Daten_K15 <- Daten_K1_K19$K15
Daten_K15$Behandlung[Daten_K15$Behandlung == "BW"] <- "Bewegung"
Daten_K15$Behandlung[Daten_K15$Behandlung == "Fix"] <- "Fixierung"

Daten_K16 <- Daten_K1_K19$K16
Daten_K17 <- Daten_K1_K19$K17
Daten_K17$Behandlung[Daten_K17$Behandlung == "BW"] <- "Bewegung"
Daten_K17$Behandlung[Daten_K17$Behandlung == "Fix"] <- "Fixierung"

Daten_K18 <- Daten_K1_K19$K18
Daten_K19 <- Daten_K1_K19$K19


# Eingabefehler im Datensatz beheben
# Im Datensatz war bei K17 die Variable Durchgang immer 18 und nicht 17.
Daten_K17$DG <- 17

Daten_K13$Bonitur_Lt <- as.character(Daten_K13$Bonitur_Lt)
Daten_K14$Bonitur_Lt <- as.character(Daten_K14$Bonitur_Lt)
Daten_K17$`Bonitur Lt` <- as.character(Daten_K17$`Bonitur Lt`)
Daten_K18$Bonitur_Lt <- as.character(Daten_K18$Bonitur_Lt)
Daten_K19$Bonitur_Lt <- as.character(Daten_K19$Bonitur_Lt)


# Datum hinzufügen für alle Versuchsdurchgänge
# Hier wurde auf Basis des Endberichts gearbeitet.
# Wichtig ist das Datum später für das Zusammenführen mit dem Klimadatensatz.

# K1
Daten_K1$Datum <- NA
Daten_K1$Datum[Daten_K1$Bonitur_Lt == "Tag 29"] <- "2011-11-24"
Daten_K1$Datum[Daten_K1$Bonitur_Lt == "Tag 34"] <- "2011-11-29"
Daten_K1$Datum[Daten_K1$Bonitur_Lt == "Tag 37"] <- "2011-12-02"
Daten_K1$Datum[Daten_K1$Bonitur_Lt == "Tag 41"] <- "2011-12-06"
Daten_K1$Datum[Daten_K1$Bonitur_Lt == "Tag 44"] <- "2011-12-09"
Daten_K1$Datum[Daten_K1$Bonitur_Lt == "Tag 48"] <- "2011-12-13"
Daten_K1$Datum[Daten_K1$Bonitur_Lt == "Tag 51"] <- "2011-12-16"
Daten_K1$Datum[Daten_K1$Bonitur_Lt == "Tag 55"] <- "2011-12-20"
Daten_K1$Datum[Daten_K1$Bonitur_Lt == "Tag 58"] <- "2011-12-23"
Daten_K1$Datum[Daten_K1$Bonitur_Lt == "Tag 62"] <- "2011-12-27"
Daten_K1$Datum[Daten_K1$Bonitur_Lt == "Tag 65"] <- "2011-12-30"
Daten_K1$Datum[Daten_K1$Bonitur_Lt == "Tag 69"] <- "2012-01-03"
Daten_K1$Datum[Daten_K1$Bonitur_Lt == "Tag 72"] <- "2012-01-05"


# K2
Daten_K2$Datum <- NA
Daten_K2$Datum[Daten_K2$Bonitur_Lt == "Tag 29"] <- "2012-01-26"
Daten_K2$Datum[Daten_K2$Bonitur_Lt == "Tag 34"] <- "2012-01-31"
Daten_K2$Datum[Daten_K2$Bonitur_Lt == "Tag 37"] <- "2012-02-03"
Daten_K2$Datum[Daten_K2$Bonitur_Lt == "Tag 41"] <- "2012-02-07"
Daten_K2$Datum[Daten_K2$Bonitur_Lt == "Tag 44"] <- "2012-02-10"
Daten_K2$Datum[Daten_K2$Bonitur_Lt == "Tag 48"] <- "2012-02-14"
Daten_K2$Datum[Daten_K2$Bonitur_Lt == "Tag 51"] <- "2012-02-17"
Daten_K2$Datum[Daten_K2$Bonitur_Lt == "Tag 55"] <- "2012-02-21"
Daten_K2$Datum[Daten_K2$Bonitur_Lt == "Tag 58"] <- "2012-02-24"
Daten_K2$Datum[Daten_K2$Bonitur_Lt == "Tag 62"] <- "2012-02-28"
Daten_K2$Datum[Daten_K2$Bonitur_Lt == "Tag 65"] <- "2012-03-02"
Daten_K2$Datum[Daten_K2$Bonitur_Lt == "Tag 69"] <- "2012-03-06"
Daten_K2$Datum[Daten_K2$Bonitur_Lt == "Tag 72"] <- "2012-03-08"


# K3
Daten_K3$Datum <- NA
Daten_K3$Datum[Daten_K3$Bonitur_Lt == "Tag 29"] <- "2012-05-10"
Daten_K3$Datum[Daten_K3$Bonitur_Lt == "Tag 34"] <- "2012-05-15"
Daten_K3$Datum[Daten_K3$Bonitur_Lt == "Tag 37"] <- "2012-05-18"
Daten_K3$Datum[Daten_K3$Bonitur_Lt == "Tag 41"] <- "2012-05-22"
Daten_K3$Datum[Daten_K3$Bonitur_Lt == "Tag 44"] <- "2012-05-25"
Daten_K3$Datum[Daten_K3$Bonitur_Lt == "Tag 48"] <- "2012-05-29"
Daten_K3$Datum[Daten_K3$Bonitur_Lt == "Tag 51"] <- "2012-06-01"
Daten_K3$Datum[Daten_K3$Bonitur_Lt == "Tag 55"] <- "2012-06-05"
Daten_K3$Datum[Daten_K3$Bonitur_Lt == "Tag 58"] <- "2012-06-08"
Daten_K3$Datum[Daten_K3$Bonitur_Lt == "Tag 62"] <- "2012-06-12"
Daten_K3$Datum[Daten_K3$Bonitur_Lt == "Tag 65"] <- "2012-06-15"
Daten_K3$Datum[Daten_K3$Bonitur_Lt == "Tag 69"] <- "2012-06-19"
Daten_K3$Datum[Daten_K3$Bonitur_Lt == "Tag 72"] <- "2012-06-21"


# K4
Daten_K4$Datum <- NA
Daten_K4$Datum[Daten_K4$Bonitur_Lt == "Tag 30"] <- "2012-10-05"
Daten_K4$Datum[Daten_K4$Bonitur_Lt == "Tag 34"] <- "2012-10-09"
Daten_K4$Datum[Daten_K4$Bonitur_Lt == "Tag 37"] <- "2012-10-12"
Daten_K4$Datum[Daten_K4$Bonitur_Lt == "Tag 41"] <- "2012-10-16"
Daten_K4$Datum[Daten_K4$Bonitur_Lt == "Tag 44"] <- "2012-10-19"
Daten_K4$Datum[Daten_K4$Bonitur_Lt == "Tag 48"] <- "2012-10-23"
Daten_K4$Datum[Daten_K4$Bonitur_Lt == "Tag 51"] <- "2012-10-26"
Daten_K4$Datum[Daten_K4$Bonitur_Lt == "Tag 55"] <- "2012-10-30"
Daten_K4$Datum[Daten_K4$Bonitur_Lt == "Tag 58"] <- "2012-11-02"
Daten_K4$Datum[Daten_K4$Bonitur_Lt == "Tag 62"] <- "2012-11-06"
Daten_K4$Datum[Daten_K4$Bonitur_Lt == "Tag 65"] <- "2012-11-09"
Daten_K4$Datum[Daten_K4$Bonitur_Lt == "Tag 69"] <- "2012-11-13"
Daten_K4$Datum[Daten_K4$Bonitur_Lt == "Tag 71"] <- "2012-11-15"


# K5
Daten_K5$Datum <- NA
Daten_K5$Datum[Daten_K5$Bonitur_Lt == "Tag 30"] <- "2013-06-14"
Daten_K5$Datum[Daten_K5$Bonitur_Lt == "Tag 34"] <- "2013-06-18"
Daten_K5$Datum[Daten_K5$Bonitur_Lt == "Tag 37"] <- "2013-06-21"
Daten_K5$Datum[Daten_K5$Bonitur_Lt == "Tag 41"] <- "2013-06-25"
Daten_K5$Datum[Daten_K5$Bonitur_Lt == "Tag 44"] <- "2013-06-28"
Daten_K5$Datum[Daten_K5$Bonitur_Lt == "Tag 48"] <- "2013-07-02"
Daten_K5$Datum[Daten_K5$Bonitur_Lt == "Tag 51"] <- "2013-07-05"
Daten_K5$Datum[Daten_K5$Bonitur_Lt == "Tag 55"] <- "2013-07-09"
Daten_K5$Datum[Daten_K5$Bonitur_Lt == "Tag 58"] <- "2013-07-12"
Daten_K5$Datum[Daten_K5$Bonitur_Lt == "Tag 62"] <- "2013-07-16"
Daten_K5$Datum[Daten_K5$Bonitur_Lt == "Tag 65"] <- "2013-07-19"
Daten_K5$Datum[Daten_K5$Bonitur_Lt == "Tag 69"] <- "2013-07-23"
Daten_K5$Datum[Daten_K5$Bonitur_Lt == "Tag 72"] <- "2013-07-26"
Daten_K5$Datum[Daten_K5$Bonitur_Lt == "Tag 76"] <- "2013-07-30"


# K6
Daten_K6$Datum <- NA
Daten_K6$Datum[Daten_K6$Bonitur_Lt == "Tag 29"] <- "2013-10-17"
Daten_K6$Datum[Daten_K6$Bonitur_Lt == "Tag 34"] <- "2013-10-22"
Daten_K6$Datum[Daten_K6$Bonitur_Lt == "Tag 37"] <- "2013-10-25"
Daten_K6$Datum[Daten_K6$Bonitur_Lt == "Tag 41"] <- "2013-10-29"
Daten_K6$Datum[Daten_K6$Bonitur_Lt == "Tag 44"] <- "2013-11-01"
Daten_K6$Datum[Daten_K6$Bonitur_Lt == "Tag 48"] <- "2013-11-05"
Daten_K6$Datum[Daten_K6$Bonitur_Lt == "Tag 51"] <- "2013-11-08"
Daten_K6$Datum[Daten_K6$Bonitur_Lt == "Tag 55"] <- "2013-11-12"
Daten_K6$Datum[Daten_K6$Bonitur_Lt == "Tag 58"] <- "2013-11-15"
Daten_K6$Datum[Daten_K6$Bonitur_Lt == "Tag 62"] <- "2013-11-19"
Daten_K6$Datum[Daten_K6$Bonitur_Lt == "Tag 65"] <- "2013-11-22"
Daten_K6$Datum[Daten_K6$Bonitur_Lt == "Tag 69"] <- "2013-11-26"
Daten_K6$Datum[Daten_K6$Bonitur_Lt == "Tag 72"] <- "2013-11-29"
Daten_K6$Datum[Daten_K6$Bonitur_Lt == "Tag 76"] <- "2013-12-03"


# K7
Daten_K7$Datum <- NA
Daten_K7$Datum[Daten_K7$Bonitur_Lt == "Tag 29"] <- "2014-01-09"
Daten_K7$Datum[Daten_K7$Bonitur_Lt == "Tag 35"] <- "2014-01-15"
Daten_K7$Datum[Daten_K7$Bonitur_Lt == "Tag 37"] <- "2014-01-17"
Daten_K7$Datum[Daten_K7$Bonitur_Lt == "Tag 41"] <- "2014-01-21"
Daten_K7$Datum[Daten_K7$Bonitur_Lt == "Tag 44"] <- "2014-01-24"
Daten_K7$Datum[Daten_K7$Bonitur_Lt == "Tag 48"] <- "2014-01-28"
Daten_K7$Datum[Daten_K7$Bonitur_Lt == "Tag 51"] <- "2014-01-31"
Daten_K7$Datum[Daten_K7$Bonitur_Lt == "Tag 55"] <- "2014-02-04"
Daten_K7$Datum[Daten_K7$Bonitur_Lt == "Tag 58"] <- "2014-02-07"
Daten_K7$Datum[Daten_K7$Bonitur_Lt == "Tag 62"] <- "2014-02-11"
Daten_K7$Datum[Daten_K7$Bonitur_Lt == "Tag 65"] <- "2014-02-14"
Daten_K7$Datum[Daten_K7$Bonitur_Lt == "Tag 69"] <- "2014-02-18"
Daten_K7$Datum[Daten_K7$Bonitur_Lt == "Tag 72"] <- "2014-02-21"
Daten_K7$Datum[Daten_K7$Bonitur_Lt == "Tag 76"] <- "2014-02-25"


# K8
Daten_K8$Datum <- NA
Daten_K8$Datum[Daten_K8$Bonitur_Lt == "Tag 29"] <- "2014-03-13"
Daten_K8$Datum[Daten_K8$Bonitur_Lt == "Tag 34"] <- "2014-03-18"
Daten_K8$Datum[Daten_K8$Bonitur_Lt == "Tag 37"] <- "2014-03-21"
Daten_K8$Datum[Daten_K8$Bonitur_Lt == "Tag 41"] <- "2014-03-25"
Daten_K8$Datum[Daten_K8$Bonitur_Lt == "Tag 44"] <- "2014-03-28"
Daten_K8$Datum[Daten_K8$Bonitur_Lt == "Tag 48"] <- "2014-04-01"
Daten_K8$Datum[Daten_K8$Bonitur_Lt == "Tag 51"] <- "2014-04-04"
Daten_K8$Datum[Daten_K8$Bonitur_Lt == "Tag 55"] <- "2014-04-08"
Daten_K8$Datum[Daten_K8$Bonitur_Lt == "Tag 58"] <- "2014-04-11"
Daten_K8$Datum[Daten_K8$Bonitur_Lt == "Tag 62"] <- "2014-04-15"
Daten_K8$Datum[Daten_K8$Bonitur_Lt == "Tag 65"] <- "2014-04-18"
Daten_K8$Datum[Daten_K8$Bonitur_Lt == "Tag 69"] <- "2014-04-22"
Daten_K8$Datum[Daten_K8$Bonitur_Lt == "Tag 72"] <- "2014-04-25"

# aber keine Klimadaten zu K8 vorhanden


# K9
Daten_K9$Datum <- NA

# keine Klimadaten zu K9 und auch keine Info über Zeitraum im Endberichten


# K10
Daten_K10$Datum <- NA

# keine Klimadaten zu K10 und auch keine Info über Zeitraum im Endberichten


# K11 
# Daten in K11 (März-Juni 2015) stimmen nicht mit Versuchszeitraum (Juli-Aug 2015) überein
Daten_K11$Datum <- NA


# K12
# Datenfehler


# K13
Daten_K13$Datum <- NA
Daten_K13$Datum[Daten_K13$Bonitur_Lt == "33"] <- "2015-10-06"
Daten_K13$Datum[Daten_K13$Bonitur_Lt == "36"] <- "2015-10-09"
Daten_K13$Datum[Daten_K13$Bonitur_Lt == "40"] <- "2015-10-13"
Daten_K13$Datum[Daten_K13$Bonitur_Lt == "43"] <- "2015-10-16"
Daten_K13$Datum[Daten_K13$Bonitur_Lt == "48"] <- "2015-10-21"
Daten_K13$Datum[Daten_K13$Bonitur_Lt == "50"] <- "2015-10-23"
Daten_K13$Datum[Daten_K13$Bonitur_Lt == "61"] <- "2015-11-03"
Daten_K13$Datum[Daten_K13$Bonitur_Lt == "68"] <- "2015-11-10"
Daten_K13$Datum[Daten_K13$Bonitur_Lt == "75"] <- "2015-11-17"


# K14
Daten_K14$Datum <- NA
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "29"] <- "2015-11-12"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "32"] <- "2015-11-15"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "33"] <- "2015-11-16"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "34"] <- "2015-11-17"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "35"] <- "2015-11-18"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "36"] <- "2015-11-19"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "37"] <- "2015-11-20"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "38"] <- "2015-11-21"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "39"] <- "2015-11-22"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "40"] <- "2015-11-23"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "41"] <- "2015-11-24"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "42"] <- "2015-11-25"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "43"] <- "2015-11-26"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "44"] <- "2015-11-27"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "45"] <- "2015-11-28"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "46"] <- "2015-11-29"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "47"] <- "2015-11-30"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "48"] <- "2015-12-01"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "49"] <- "2015-12-02"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "50"] <- "2015-12-03"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "51"] <- "2015-12-04"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "52"] <- "2015-12-05"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "53"] <- "2015-12-06"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "54"] <- "2015-12-07"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "55"] <- "2015-12-08"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "56"] <- "2015-12-09"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "57"] <- "2015-12-10"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "58"] <- "2015-12-11"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "59"] <- "2015-12-12"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "60"] <- "2015-12-13"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "61"] <- "2015-12-14"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "62"] <- "2015-12-15"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "63"] <- "2015-12-16"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "64"] <- "2015-12-17"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "65"] <- "2015-12-18"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "66"] <- "2015-12-19"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "67"] <- "2015-12-20"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "68"] <- "2015-12-21"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "69"] <- "2015-12-22"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "70"] <- "2015-12-23"
Daten_K14$Datum[Daten_K14$Bonitur_Lt == "71"] <- "2015-12-24"


# K15
# keine Klimadaten zu K15
Daten_K15$Datum <- NA

# K16
# keine Klimadaten zu K16
Daten_K16$Datum <- NA


# K17
Daten_K17$Datum <- NA
Daten_K17$Datum[Daten_K17$`Bonitur Lt` == "33"] <- "2016-09-27"
Daten_K17$Datum[Daten_K17$`Bonitur Lt` == "36"] <- "2016-09-30"
Daten_K17$Datum[Daten_K17$`Bonitur Lt` == "40"] <- "2016-10-04"
Daten_K17$Datum[Daten_K17$`Bonitur Lt` == "42"] <- "2016-10-06"
Daten_K17$Datum[Daten_K17$`Bonitur Lt` == "47"] <- "2016-10-11"
Daten_K17$Datum[Daten_K17$`Bonitur Lt` == "54"] <- "2016-10-18"
Daten_K17$Datum[Daten_K17$`Bonitur Lt` == "56"] <- "2016-10-20"
Daten_K17$Datum[Daten_K17$`Bonitur Lt` == "60"] <- "2016-10-24"
Daten_K17$Datum[Daten_K17$`Bonitur Lt` == "69"] <- "2016-11-02"
Daten_K17$Datum[Daten_K17$`Bonitur Lt` == "74"] <- "2016-11-07"


# K18
Daten_K18$Datum <- NA
Daten_K18$Datum[Daten_K18$Bonitur_Lt == "30"] <- "2017-04-28"
Daten_K18$Datum[Daten_K18$Bonitur_Lt == "34"] <- "2017-05-02"
Daten_K18$Datum[Daten_K18$Bonitur_Lt == "37"] <- "2017-05-05"
Daten_K18$Datum[Daten_K18$Bonitur_Lt == "41"] <- "2017-05-09"
Daten_K18$Datum[Daten_K18$Bonitur_Lt == "44"] <- "2017-05-12"
Daten_K18$Datum[Daten_K18$Bonitur_Lt == "48"] <- "2017-05-16"
Daten_K18$Datum[Daten_K18$Bonitur_Lt == "51"] <- "2017-05-19"
Daten_K18$Datum[Daten_K18$Bonitur_Lt == "55"] <- "2017-05-23"
Daten_K18$Datum[Daten_K18$Bonitur_Lt == "58"] <- "2017-05-26"
Daten_K18$Datum[Daten_K18$Bonitur_Lt == "62"] <- "2017-05-30"
Daten_K18$Datum[Daten_K18$Bonitur_Lt == "65"] <- "2017-06-02"
Daten_K18$Datum[Daten_K18$Bonitur_Lt == "69"] <- "2017-06-06"
Daten_K18$Datum[Daten_K18$Bonitur_Lt == "72"] <- "2017-06-09"
Daten_K18$Datum[Daten_K18$Bonitur_Lt == "75"] <- "2017-06-12"


# K19
Daten_K19$Datum <- NA
Daten_K19$Datum[Daten_K19$Bonitur_Lt == "29"] <- "2018-05-04"
Daten_K19$Datum[Daten_K19$Bonitur_Lt == "33"] <- "2018-05-08"
Daten_K19$Datum[Daten_K19$Bonitur_Lt == "36"] <- "2018-05-11"
Daten_K19$Datum[Daten_K19$Bonitur_Lt == "40"] <- "2018-05-15"
Daten_K19$Datum[Daten_K19$Bonitur_Lt == "43"] <- "2018-05-18"
Daten_K19$Datum[Daten_K19$Bonitur_Lt == "47"] <- "2018-05-22"
Daten_K19$Datum[Daten_K19$Bonitur_Lt == "50"] <- "2018-05-25"
Daten_K19$Datum[Daten_K19$Bonitur_Lt == "54"] <- "2018-05-29"
Daten_K19$Datum[Daten_K19$Bonitur_Lt == "57"] <- "2018-06-01"
Daten_K19$Datum[Daten_K19$Bonitur_Lt == "61"] <- "2018-06-05"
Daten_K19$Datum[Daten_K19$Bonitur_Lt == "64"] <- "2018-06-08"
Daten_K19$Datum[Daten_K19$Bonitur_Lt == "68"] <- "2018-06-12"
Daten_K19$Datum[Daten_K19$Bonitur_Lt == "71"] <- "2018-06-15"
Daten_K19$Datum[Daten_K19$Bonitur_Lt == "75"] <- "2018-06-19"




# Gewicht Geschlecht
# Jetzt wird der Datensatz mit den Infos über die Tiere eingelesen.
# Wir verwenden den einheitlichen Datensatz, der uns im Rahmen des 
# Erstgesprächs übergeben wurde. 
# Fehlende Werte z.B. in manchen Durchgängen beim Geschlecht wurden mithilfe
# des nachgereichten Datensatzes hinzugefügt, den wir
# Gewicht_K1_K19_fehlGew genannt haben.

Gewicht_K1_K19 <- read_excel_allsheets("Gewicht_Geschlecht_K1-K19.xlsx")

Gewicht_K1_K19_fehlGew <- read_excel_allsheets("Gewicht_Geschlecht_K1-K19_mit_K19.xlsx")


# Auch hier werden die Variablentypen vereinheitlicht, sodass die Variable
# Tier_Nummer immer numerisch ist, sonst funktioniert das Zusammenführen
# mit dem anderen Datensatz nicht.

for (i in 1:18) {
  Gewicht_K1_K19[[i]]$Tier_Nr <- as.double(Gewicht_K1_K19[[i]]$Tier_Nr)
}

# K8 wurde extra nachgereicht und wird erst hier eingelesen.

Gewicht_K8_einlesen <- read_excel_allsheets("DG8_Geschlecht_Mutter.xlsx")
Gewicht_K8_einlesen_join <- Gewicht_K8_einlesen$DG_8 %>%
  select(-c("Behandlung", "DG"))


# Auch für die Gewichtdaten wird der gesamte Datensatz auf die einzelnen 
# Durchgänge aufgeteilt.
# Außerdem werden hier gleich die fehlenden Werte, wie z.B. Zunahmen in K3
# oder Gewicht in K13-K17 bearbeitet.

Gewicht_K1 <- Gewicht_K1_K19$K1
Gewicht_K2 <- Gewicht_K1_K19$K2
Gewicht_K3 <- Gewicht_K1_K19$K3
Gewicht_K3$Zunahmen <- (Gewicht_K3$Gewicht_Ausst - Gewicht_K3$Gewicht_Einst)/47
Gewicht_K4 <- Gewicht_K1_K19$K4
Gewicht_K5 <- Gewicht_K1_K19$K5
Gewicht_K6 <- Gewicht_K1_K19$K6
Gewicht_K7 <- Gewicht_K1_K19$K7
Gewicht_K8 <- Gewicht_K1_K19$K8
Gewicht_K8 <- Gewicht_K8 %>% select(-"Mutter")
Gewicht_K8 <- full_join(Gewicht_K8, Gewicht_K8_einlesen_join, by = "Tier_Nr")
Gewicht_K8 <- Gewicht_K8[, c(1, 2, 3, 4, 8, 9, 5, 6, 7)]

Gewicht_K9 <- Gewicht_K1_K19$K9
Gewicht_K10 <- Gewicht_K1_K19$K10
Gewicht_K11 <- Gewicht_K1_K19$K11
Gewicht_K12 <- Gewicht_K1_K19$K12

Gewicht_K13 <- Gewicht_K1_K19$K13
Gewicht_K13 <- Gewicht_K13[, c(1:4, 7:9)]

Gewicht_K13_Gew <- Gewicht_K1_K19_fehlGew$K13
Gewicht_K13_Gew <- Gewicht_K13_Gew[, c(3, 5, 6)]
Gewicht_K13_Gew$Tier_Nr <- as.double(Gewicht_K13_Gew$Tier_Nr)

Gewicht_K13 <- inner_join(Gewicht_K13, Gewicht_K13_Gew, by = c("Tier_Nr"))
Gewicht_K13 <- Gewicht_K13[, c(1, 2, 3, 4, 8, 9, 5, 6, 7)]

Gewicht_K14 <- Gewicht_K1_K19$K14
Gewicht_K14 <- Gewicht_K14[, c(1:4, 7:9)]
Gewicht_K14_Gew <- Gewicht_K1_K19_fehlGew$K14
Gewicht_K14_Gew <- Gewicht_K14_Gew[, c(3, 5, 6)]

Gewicht_K14 <- inner_join(Gewicht_K14, Gewicht_K14_Gew, by = c("Tier_Nr"))
Gewicht_K14 <- Gewicht_K14[, c(1, 2, 3, 4, 8, 9, 5, 6, 7)]


Gewicht_K15 <- Gewicht_K1_K19$K15
Gewicht_K15$DG <- 15
Gewicht_K15 <- Gewicht_K15[, c(1:4, 7:9)]

Gewicht_K15_Gew <- Gewicht_K1_K19_fehlGew$K15
Gewicht_K15_Gew <- Gewicht_K15_Gew[, c(3, 5, 6)]
Gewicht_K15_Gew$Tier_Nr <- as.double(Gewicht_K15_Gew$Tier_Nr)

Gewicht_K15 <- inner_join(Gewicht_K15, Gewicht_K15_Gew, by = c("Tier_Nr"))
Gewicht_K15 <- Gewicht_K15[, c(1, 2, 3, 4, 8,  9, 5, 6, 7)]

Gewicht_K16 <- Gewicht_K1_K19$K16
Gewicht_K16 <- Gewicht_K16[, c(1:4, 7:9)]

Gewicht_K16_Gew <- Gewicht_K1_K19_fehlGew$K16
Gewicht_K16_Gew <- Gewicht_K16_Gew[, c(3, 5, 6)]
Gewicht_K16_Gew$Tier_Nr <- as.double(Gewicht_K16_Gew$Tier_Nr)

Gewicht_K16 <- inner_join(Gewicht_K16, Gewicht_K16_Gew, by = c("Tier_Nr"))
Gewicht_K16 <- Gewicht_K16[, c(1, 2, 3, 4, 8,  9, 5, 6, 7)]

Gewicht_K17 <- Gewicht_K1_K19$K17
Gewicht_K17 <- Gewicht_K17[, c(1:4, 7:9)]

Gewicht_K17_Gew <- Gewicht_K1_K19_fehlGew$K17
Gewicht_K17_Gew <- Gewicht_K17_Gew[, c(3, 5, 6)]
Gewicht_K17_Gew$Tier_Nr <- as.double(Gewicht_K17_Gew$Tier_Nr)

Gewicht_K17 <- inner_join(Gewicht_K17, Gewicht_K17_Gew, by = c("Tier_Nr"))
Gewicht_K17 <- Gewicht_K17[, c(1, 2, 3, 4, 8, 9, 5, 6, 7)]

Gewicht_K18 <- Gewicht_K1_K19$K18

# Daten zu K19 in extra Datei nachgereicht
Gewicht_K19_Gew <- Gewicht_K1_K19_fehlGew$K19
Gewicht_K19_Gew <- Gewicht_K19_Gew[, c(3, 5, 6)]

Gewicht_K19 <- read_excel_allsheets("Gewichtsabruf_K19.xls")
Gewicht_K19 <- Gewicht_K19$K19_Gewichtsabruf
Gewicht_K19 <- mutate(Gewicht_K19, "Zunahmen" = (Gewicht_Ausst - Gewicht_Einst.)/47)
Gewicht_K19$Tier_Nr <- as.double(Gewicht_K19$Tier_Nr)

Gewicht_K19 <- inner_join(Gewicht_K19, Gewicht_K19_Gew, by = c("Tier_Nr"))
Gewicht_K19 <- Gewicht_K19[, c(1, 5, 6, 2, 3, 4)]



# Im Folgenden werden die Klimadaten eingelesen.
# Klimadaten
Klima_K1_K19 <- read_excel_allsheets("Klimadaten.xlsx")

# Da in R das Datum ein spezielles Format hat, werden wir es vorerst
# als Charakter-Variable betrachten.

for (i in 1:19) {
  Klima_K1_K19[[i]]$Datum <- as.character(Klima_K1_K19[[i]]$Datum )
}


# Auch hier wird der Klimadatensatz in einen Datensatz für jeden 
# Durchgang aufgeteilt.

Klima_K1 <- Klima_K1_K19$K1
Klima_K2 <- Klima_K1_K19$K2
Klima_K3 <- Klima_K1_K19$K3
Klima_K4 <- Klima_K1_K19$K4
Klima_K5 <- Klima_K1_K19$K5
Klima_K6 <- Klima_K1_K19$K6
Klima_K7 <- Klima_K1_K19$K7
Klima_K8 <- Klima_K1_K19$K8
Klima_K9 <- Klima_K1_K19$K9
Klima_K10 <- Klima_K1_K19$K10
Klima_K11 <- Klima_K1_K19$K11
Klima_K12 <- Klima_K1_K19$K12
Klima_K13 <- Klima_K1_K19$K13
Klima_K14 <- Klima_K1_K19$K14
Klima_K15 <- Klima_K1_K19$K15
Klima_K16 <- Klima_K1_K19$K16
Klima_K17 <- Klima_K1_K19$K17
Klima_K18 <- Klima_K1_K19$K18
Klima_K19 <- Klima_K1_K19$K19


# Der mit Rauten auskommentierte Code in den folgenden zeilen war nur der 
# erste Ansatz die Klimadaten aufzubereiten, die endgültige Lösung folgt
# gleich danach in den darauffolgenden Zeilen.

# Klimadaten aufbereiten
# Klima_K1 <- Klima_K1 %>%
#  group_by(Datum) %>%
#  summarise(mean_rel_Luftf_F5 = mean(`Relative Luftfeuchtigkeit F5`),
#            mean_rel_Luftf_F6 = mean(`Relative Luftfeuchtigkeit F6`),
#            mean_temp_F5 = mean(`Temperatur F5`),
#            mean_temp_F6 = mean(`Temperatur F6`),
#            min_rel_Luftf_F5 = min(`Relative Luftfeuchtigkeit F5`),
#            min_rel_Luftf_F6 = min(`Relative Luftfeuchtigkeit F6`),
#            min_temp_F5 = min(`Temperatur F5`),
#            min_temp_F6 = min(`Temperatur F6`),
#            max_rel_Luftf_F5 = max(`Relative Luftfeuchtigkeit F5`),
#            max_rel_Luftf_F6 = max(`Relative Luftfeuchtigkeit F6`),
#            max_temp_F5 = max(`Temperatur F5`),
#            max_temp_F6 = max(`Temperatur F6`),
#            var_rel_Luftf_F5 = var(`Relative Luftfeuchtigkeit F5`),
#            var_rel_Luftf_F6 = var(`Relative Luftfeuchtigkeit F6`),
#            var_temp_F5 = var(`Temperatur F5`),
#            var_temp_F6 = var(`Temperatur F6`))



# Im Folgenden die Aufbereitung der Klimadaten, dass wir für jeden Tag
# in jedem Abteil Werte für das Klima haben.
# Die aufbereiteten Klimadaten sind ersichtlich durch die Endung "_neu"

Klima_K1_K19[[11]]$'Relative Luftfeuchtigkeit F5' <- as.numeric(Klima_K1_K19[[11]]$'Relative Luftfeuchtigkeit F5')
Klima_K1_K19[[17]]$'Relative Luftfeuchtigkeit F3' <- as.numeric(Klima_K1_K19[[17]]$'Relative Luftfeuchtigkeit F3')
Klima_K1_K19[[18]]$'Relative Luftfeuchtigkeit F5' <- as.numeric(Klima_K1_K19[[18]]$'Relative Luftfeuchtigkeit F5')
Klima_K1_K19[[18]]$'Relative Luftfeuchtigkeit F6' <- as.numeric(Klima_K1_K19[[18]]$'Relative Luftfeuchtigkeit F6')
Klima_K1_K19[[18]]$'Temperatur F5' <- as.numeric(Klima_K1_K19[[18]]$'Temperatur F5')
Klima_K1_K19[[17]]$'Temperatur F3' <- Klima_K1_K19[[17]]$'Tempertur F3'

Klima_K1_K19_F5 <- list()
Klima_K1_K19_F6 <- list()
Klima_K1_K19_neu <- list()

length(Klima_K1_K19_neu) <- length(Klima_K1_K19)

names(Klima_K1_K19_neu) <- paste("K", 1:19, sep="")

for (i in c(1:7, 11, 13, 18:19)) {
  Klima_K1_K19_F5[[i]] <-  Klima_K1_K19[[i]] %>%
    group_by(Datum) %>%
    summarise(mean_rel_Luftf = mean(`Relative Luftfeuchtigkeit F5`),
              mean_temp = mean(`Temperatur F5`),
              min_rel_Luftf = min(`Relative Luftfeuchtigkeit F5`),
              min_temp = min(`Temperatur F5`),
              max_rel_Luftf = max(`Relative Luftfeuchtigkeit F5`),
              max_temp = max(`Temperatur F5`),
              var_rel_Luftf = var(`Relative Luftfeuchtigkeit F5`),
              var_temp = var(`Temperatur F5`)) %>%
    mutate(Abteil = "F5")
  
  Klima_K1_K19_F6[[i]] <- Klima_K1_K19[[i]] %>%
    group_by(Datum) %>%
    summarise(mean_rel_Luftf = mean(`Relative Luftfeuchtigkeit F6`),
              mean_temp = mean(`Temperatur F6`),
              min_rel_Luftf = min(`Relative Luftfeuchtigkeit F6`),
              min_temp = min(`Temperatur F6`),
              max_rel_Luftf = max(`Relative Luftfeuchtigkeit F6`),
              max_temp = max(`Temperatur F6`),
              var_rel_Luftf = var(`Relative Luftfeuchtigkeit F6`),
              var_temp = var(`Temperatur F6`)) %>%
    mutate(Abteil = "F6") 
  
  Klima_K1_K19_neu[[i]] <- full_join(Klima_K1_K19_F5[[i]], Klima_K1_K19_F6[[i]]) %>%
    select(Datum, Abteil, mean_rel_Luftf, mean_temp, min_rel_Luftf, min_temp, 
           max_rel_Luftf, max_temp, var_rel_Luftf, var_temp) 
  
  Klima_K1_K19_neu[[i]] <- Klima_K1_K19_neu[[i]][order(Klima_K1_K19_neu[[i]]$Datum),]
}


for (i in c(12,14,17)) {
  Klima_K1_K19_neu[[i]] <-  Klima_K1_K19[[i]] %>%
    group_by(Datum) %>%
    summarise(mean_rel_Luftf = mean(`Relative Luftfeuchtigkeit F3`),
              mean_temp = mean(`Temperatur F3`),
              min_rel_Luftf = min(`Relative Luftfeuchtigkeit F3`),
              min_temp = min(`Temperatur F3`),
              max_rel_Luftf = max(`Relative Luftfeuchtigkeit F3`),
              max_temp = max(`Temperatur F3`),
              var_rel_Luftf = var(`Relative Luftfeuchtigkeit F3`),
              var_temp = var(`Temperatur F3`)) %>%
    mutate(Abteil = "F3") %>%
    select(Datum, Abteil, mean_rel_Luftf, mean_temp, min_rel_Luftf, min_temp, max_rel_Luftf, max_temp,
           var_rel_Luftf, var_temp) 
  
  #Klima_K1_K19_neu[[i]] <- Klima_K1_K19_neu[[i]][order(Klima_K1_K19_neu[[i]]$Datum),]
}

for (i in c(8:10, 15, 16)) {
  Klima_K1_K19_neu[[i]]$Datum = NA
  Klima_K1_K19_neu[[i]]$Datum = as.character(Klima_K1_K19_neu[[i]]$Datum)
  Klima_K1_K19_neu[[i]]$Abteil = NA
  Klima_K1_K19_neu[[i]]$Abteil = as.character(Klima_K1_K19_neu[[i]]$Abteil)
  Klima_K1_K19_neu[[i]]$mean_rel_Luftf = NA
  Klima_K1_K19_neu[[i]]$mean_temp = NA
  Klima_K1_K19_neu[[i]]$min_rel_Luftf = NA
  Klima_K1_K19_neu[[i]]$min_temp = NA
  Klima_K1_K19_neu[[i]]$max_rel_Luftf = NA
  Klima_K1_K19_neu[[i]]$max_temp = NA
  Klima_K1_K19_neu[[i]]$var_rel_Luftf = NA
  Klima_K1_K19_neu[[i]]$var_temp = NA
}


for (i in c(12,14,17)) {
  Klima_K1_K19_neu[[i]] <-  Klima_K1_K19[[i]] %>%
    group_by(Datum) %>%
    summarise(mean_rel_Luftf = mean(`Relative Luftfeuchtigkeit F3`),
              mean_temp = mean(`Temperatur F3`),
              min_rel_Luftf = min(`Relative Luftfeuchtigkeit F3`),
              min_temp = min(`Temperatur F3`),
              max_rel_Luftf = max(`Relative Luftfeuchtigkeit F3`),
              max_temp = max(`Temperatur F3`),
              var_rel_Luftf = var(`Relative Luftfeuchtigkeit F3`),
              var_temp = var(`Temperatur F3`)) %>%
    mutate(Abteil = "F3") %>%
    select(Datum, Abteil, mean_rel_Luftf, mean_temp, min_rel_Luftf, min_temp, max_rel_Luftf, max_temp,
           var_rel_Luftf, var_temp) 
  
  #Klima_K1_K19_neu[[i]] <- Klima_K1_K19_neu[[i]][order(Klima_K1_K19_neu[[i]]$Datum),]
}

for (i in c(8:10, 15, 16)) {
  Klima_K1_K19_neu[[i]]$Datum = NA
  Klima_K1_K19_neu[[i]]$Datum = as.character(Klima_K1_K19_neu[[i]]$Datum)
  Klima_K1_K19_neu[[i]]$Abteil = NA
  Klima_K1_K19_neu[[i]]$Abteil = as.character(Klima_K1_K19_neu[[i]]$Abteil)
  Klima_K1_K19_neu[[i]]$mean_rel_Luftf = NA
  Klima_K1_K19_neu[[i]]$mean_temp = NA
  Klima_K1_K19_neu[[i]]$min_rel_Luftf = NA
  Klima_K1_K19_neu[[i]]$min_temp = NA
  Klima_K1_K19_neu[[i]]$max_rel_Luftf = NA
  Klima_K1_K19_neu[[i]]$max_temp = NA
  Klima_K1_K19_neu[[i]]$var_rel_Luftf = NA
  Klima_K1_K19_neu[[i]]$var_temp = NA
}


# Jetzt soll auch mit den aufbereiteten Daten ein Datensatz für jeden Durchgang
# entstehen.
# Klima_K1_K19_neu

Klima_K1_neu <- Klima_K1_K19_neu$K1
Klima_K2_neu <- Klima_K1_K19_neu$K2
Klima_K3_neu <- Klima_K1_K19_neu$K3
Klima_K4_neu <- Klima_K1_K19_neu$K4
Klima_K5_neu <- Klima_K1_K19_neu$K5
Klima_K6_neu <- Klima_K1_K19_neu$K6
Klima_K7_neu <- Klima_K1_K19_neu$K7
Klima_K8_neu <- Klima_K1_K19_neu$K8
Klima_K9_neu <- Klima_K1_K19_neu$K9
Klima_K10_neu <- Klima_K1_K19_neu$K10
Klima_K11_neu <- Klima_K1_K19_neu$K11
Klima_K12_neu <- Klima_K1_K19_neu$K12
Klima_K13_neu <- Klima_K1_K19_neu$K13
Klima_K14_neu <- Klima_K1_K19_neu$K14
Klima_K15_neu <- Klima_K1_K19_neu$K15
Klima_K16_neu <- Klima_K1_K19_neu$K16
Klima_K17_neu <- Klima_K1_K19_neu$K17
Klima_K18_neu <- Klima_K1_K19_neu$K18
Klima_K19_neu <- Klima_K1_K19_neu$K19

# Zum Zusammenführen mit den anderen Datensätzen müssen auch die Durchgänge 
# ohne Klimadaten als Data-Frame existieren.

Klima_K8_neu <- as.data.frame(Klima_K8_neu)
Klima_K9_neu <- as.data.frame(Klima_K9_neu)
Klima_K10_neu <- as.data.frame(Klima_K10_neu)
Klima_K15_neu <- as.data.frame(Klima_K15_neu)
Klima_K16_neu <- as.data.frame(Klima_K16_neu)


# Als erstes werden die Datensätze mit den Bonituren (Daten_K1 - Daten_K19)
# mit den Gewichtsdaten (Gewicht_K1 - Gewicht_K19) zusammengeführt.
# Hierfür werden die Variablen "DG", "Behandlung" und "Bucht" verwendet,
# die in beiden Datensätzen existieren.
# Der neue Datensatz heißt data_K1 - data_K19 für die 19 Versuchsdurchgänge.

# Datensätze Daten_K* und Gewicht_K* zusammenführen
Gew_K1 <- Gewicht_K1 %>%
  select(-"DG", -"Behandlung", -"Bucht")
data_K1 <- inner_join(Daten_K1, Gew_K1, by = "Tier_Nr")

Gew_K2 <- Gewicht_K2 %>%
  select(-"DG", -"Behandlung", -"Bucht")
data_K2 <- inner_join(Daten_K2, Gew_K2, by = "Tier_Nr")

Gew_K3 <- Gewicht_K3 %>%
  select(-"Durchgang", -"Behandlung", -"Bucht") 
data_K3 <- inner_join(Daten_K3, Gew_K3, by = "Tier_Nr")

Gew_K4 <- Gewicht_K4 %>%
  select(-"DG", -"Behandlung", -"Bucht")
data_K4 <- inner_join(Daten_K4, Gew_K4, by = "Tier_Nr")

Gew_K5 <- Gewicht_K5 %>%
  select(-"DG", -"Behandlung", -"Bucht")
data_K5 <- inner_join(Daten_K5, Gew_K5, by = "Tier_Nr")

Gew_K6 <- Gewicht_K6 %>%
  select(-"DG", -"Behandlung", -"Bucht")
data_K6 <- inner_join(Daten_K6, Gew_K6, by = "Tier_Nr")

Gew_K7 <- Gewicht_K7 %>%
  select(-"DG", -"Behandlung", -"Bucht")
data_K7 <- inner_join(Daten_K7, Gew_K7, by = "Tier_Nr")

Gew_K8 <- Gewicht_K8 %>%
  select(-"DG", -"Behandlung", -"Bucht")
data_K8 <- inner_join(Daten_K8, Gew_K8, by = "Tier_Nr")

Gew_K9 <- Gewicht_K9 %>%
  select(-"DG", -"Behandlung", -"Bucht")
data_K9 <- inner_join(Daten_K9, Gew_K9, by = "Tier_Nr")

Gew_K10 <- Gewicht_K10 %>%
  select(-"DG", -"Behandlung", -"Bucht")
data_K10 <- inner_join(Daten_K10, Gew_K10, by = "Tier_Nr")

Gew_K11 <- Gewicht_K11 %>%
  select(-"DG", -"Behandlung", -"Bucht")
data_K11 <- inner_join(Daten_K11, Gew_K11, by = "Tier_Nr")

Gew_K13 <- Gewicht_K13 %>%
  select(-"DG", -"Behandlung", -"Bucht")
data_K13 <- inner_join(Daten_K13, Gew_K13, by = "Tier_Nr")

Gew_K14 <- Gewicht_K14 %>%
  select(-"DG", -"Behandlung", -"Bucht")
data_K14 <- inner_join(Daten_K14, Gew_K14, by = "Tier_Nr")

Gew_K15 <- Gewicht_K15 %>%
  select(-"DG", -"Behandlung", -"Bucht")
data_K15 <- inner_join(Daten_K15, Gew_K15, by = "Tier_Nr")

Gew_K16 <- Gewicht_K16 %>%
  select(-"DG", -"Behandlung", -"Bucht")
data_K16 <- inner_join(Daten_K16, Gew_K16, by = "Tier_Nr")

Gew_K17 <- Gewicht_K17 %>%
  select(-"DG", -"Behandlung", -"Bucht")
data_K17 <- inner_join(Daten_K17, Gew_K17, by = "Tier_Nr")

Gew_K18 <- Gewicht_K18 %>%
  select(-"DG", -"Behandlung", -"Bucht")
data_K18 <- inner_join(Daten_K18, Gew_K18, by = "Tier_Nr")

Gew_K19 <- Gewicht_K19 
data_K19 <- inner_join(Daten_K19, Gew_K19, by = "Tier_Nr") 


# Damit die 19 einzelnen neuen Daten wieder in einen Datensatz, der alle
# 19 Durchgänge enthält, zusammengeführt werden können, wird hier die Bennenung
# wieder überarbeitet, damit Unterschiede, wie Gewicht_Ausst oder Gew._Ausst
# keinen Einfluss nehmen

# Datensätze zusammenführen mit rbind()

names(data_K5) <- names(data_K1)

names(data_K16) <- names(data_K1)

# K17 Ventil statt Bucht: Für rbind wird Ventil in Bucht umbenannt
names(data_K17) <- names(data_K1)


names(data_K19) <- names(data_K1)


# Der neue Datensatz heißt jetzt ferkel.
# Er enthält die Boniturdaten und Infos zu den Tieren für alle Durchgänge.
ferkel <- rbind(data_K1, data_K2, data_K3, data_K4, data_K5, data_K6, data_K7, data_K8, data_K9, data_K10, data_K11, data_K13, data_K14, data_K15, data_K16, data_K17, data_K18, data_K19)


# Hier werden die binären 0/1-codierten Variablen für die 
# Regressionsanalyse erstellt.

# zuerst Unterteilung in keine Verletzung und Verletzung
ferkel$Sverletzjn[ferkel$Sverletz %in% c(1, 2, 3)] <- 0
ferkel$Sverletzjn[ferkel$Sverletz == 0] <- 1

# frisches Blut ja/nein
ferkel$Blutjn[ferkel$fr.Blut == 1] <- 0
ferkel$Blutjn[ferkel$fr.Blut == 0] <- 1

# Schwellung ja/nein
ferkel$Schwellungjn[ferkel$Schw %in% c(1, 2, 3, 4)] <- 0
ferkel$Schwellungjn[ferkel$Schw == 0] <- 1

# Teilverlust ja/nein (nur zur Vollständigkeit, wird nicht verwendet)
ferkel$Steilvjn[ferkel$Steilv %in% c(0.5, 1, 2, 3)] <- 0
ferkel$Steilvjn[ferkel$Steilv == 0] <- 1

# Für die ersten Analysen, bei der die Regressionsmodelle nach Durchgang 
# gefiltert wurden, wurde der ferkel-Datensatz in jeden Durchgang aufgeteilt.
# Außerdem nötig, um ferkel-Daten mit Klimadaten zusammenzuführen.

# Datensatz für jeden Durchgang filtern
for (i in numvec_12) {
  dataname <- paste("ferkel_DG", i, sep = "")
  data_DG <- ferkel %>%
    filter(DG == i)
  assign(dataname, data_DG)
}


# Für jeden Durchgang wird der ferkel-Datensatz (enthält Bonituren und Tierinfos)
# mit den aufbereiteten Klimadaten zusammengeführt,
# mitilfe der Variablen Datum und Abteil, die in beiden Datensätzen 
# enthalten sind.

klimasau_K1 <- full_join(ferkel_DG1, Klima_K1_neu, by = c("Datum", "Abteil"))
klimasau_K2 <- full_join(ferkel_DG2, Klima_K2_neu, by = c("Datum", "Abteil"))
klimasau_K3 <- full_join(ferkel_DG3, Klima_K3_neu, by = c("Datum", "Abteil"))
klimasau_K4 <- full_join(ferkel_DG4, Klima_K4_neu, by = c("Datum", "Abteil"))
klimasau_K5 <- full_join(ferkel_DG5, Klima_K5_neu, by = c("Datum", "Abteil"))
klimasau_K6 <- full_join(ferkel_DG6, Klima_K6_neu, by = c("Datum", "Abteil"))
klimasau_K7 <- full_join(ferkel_DG7, Klima_K7_neu, by = c("Datum", "Abteil"))
klimasau_K8 <- full_join(ferkel_DG8, Klima_K8_neu, by = c("Datum", "Abteil"))
klimasau_K9 <- full_join(ferkel_DG9, Klima_K9_neu, by = c("Datum", "Abteil"))
klimasau_K10 <- full_join(ferkel_DG10, Klima_K10_neu, by = c("Datum", "Abteil"))
klimasau_K11 <- full_join(ferkel_DG11, Klima_K11_neu, by = c("Datum", "Abteil"))
klimasau_K13 <- full_join(ferkel_DG13, Klima_K13_neu, by = c("Datum", "Abteil"))
klimasau_K14 <- full_join(ferkel_DG14, Klima_K14_neu, by = c("Datum", "Abteil"))
klimasau_K15 <- full_join(ferkel_DG15, Klima_K15_neu, by = c("Datum", "Abteil"))
klimasau_K16 <- full_join(ferkel_DG16, Klima_K16_neu, by = c("Datum", "Abteil"))
klimasau_K17 <- full_join(ferkel_DG17, Klima_K17_neu, by = c("Datum", "Abteil"))
klimasau_K18 <- full_join(ferkel_DG18, Klima_K18_neu, by = c("Datum", "Abteil"))
klimasau_K19 <- full_join(ferkel_DG19, Klima_K19_neu, by = c("Datum", "Abteil"))

# Unter anderem für das endgültige Modell wurde aus den 19 einzelnen Datensätzen,
# die Klima, Bonituren und Tierinfos enthalten, ein Datensatz mit
# allen Durchgängen erstellt, der alle Informationen enthält, die wir haben.
# Dieser Datensatz heißt klimasau.

klimasau <- rbind(klimasau_K1, klimasau_K2, klimasau_K3, klimasau_K4, klimasau_K5, klimasau_K6,
                  klimasau_K7, klimasau_K8, klimasau_K9, klimasau_K10, klimasau_K11, klimasau_K13,
                  klimasau_K14, klimasau_K15, klimasau_K16, klimasau_K17, klimasau_K18, klimasau_K19)





####################################################################################################################
######################## Deskriptive Analysen ######################################################################
####################################################################################################################



######################################### VISUALISIERUNGEN 1 ###########################################

library(ggplot2)
library(grDevices)
color_plot <- c("#fcbba1", "#fb6a4a", "#cb181d", "#67000d")

### 1.Verletzungen -----------------------------------------------------------------------------------

# Wie häufig tritt jeder Verletzungsgrad auf?
Anzahl_Sverletz <- list()
length(Anzahl_Sverletz) <- length(Daten_K1_K19)
# names(Anzahl_Sverletz) <- paste("Versuch K", 1:length(Daten_K1_K19), sep = "")
for (i in numvec_12)
{
  Anzahl_Sverletz[[i]] <- Daten_K1_K19[[i]] %>% select("Sverletz") %>% table() 
}
Anzahl_Sverletz[[19]] <- Anzahl_Sverletz[[19]][10:13]
Anzahl_Sverletz



# extrahiere aus der Liste der Häufigkeitstabellen für jeden Versuchsgrad deren Auftrittshäufigkeit in den Versuchen K1-K19
VGrad_0 <- vector()
VGrad_1 <- vector()
VGrad_2 <- vector()
VGrad_3 <- vector()
length(VGrad_0) <- length(Anzahl_Sverletz)
length(VGrad_1) <- length(Anzahl_Sverletz)
length(VGrad_2) <- length(Anzahl_Sverletz)
length(VGrad_3) <- length(Anzahl_Sverletz)
for (i in numvec_12)
{
  VGrad_0[i] <- Anzahl_Sverletz[[i]][1]
  VGrad_1[i] <- Anzahl_Sverletz[[i]][2]
  VGrad_2[i] <- Anzahl_Sverletz[[i]][3]
  VGrad_3[i] <- Anzahl_Sverletz[[i]][4]
}
VGrad_0
VGrad_1
VGrad_2
VGrad_3
Versuch <- 1:19

gesamt <- vector()
length(gesamt) <- length(Anzahl_Sverletz)
for (i in 1:length(Anzahl_Sverletz))
{
  gesamt[i] <- sum(VGrad_0[i], VGrad_1[i], VGrad_2[i], VGrad_3[i])
}
gesamt


# Datensatz zu den Häufigkeiten der versch. Verletzungsgrade in jedem Versuch (in short und long format)
Anzahl_Sverletz_df <- data.frame(Versuch, VGrad_0, VGrad_1, VGrad_2, VGrad_3, gesamt)
Anzahl_Sverletz_df_long <- Anzahl_Sverletz_df %>% gather("VGrad_0", "VGrad_1", "VGrad_2", "VGrad_3", key = "VGrad", value = "Hfgk")



# Balkendiagramm 
barplot_Sverletz <- ggplot(Anzahl_Sverletz_df_long, aes(x = Versuch, y = (Hfgk/gesamt), fill = VGrad)) +
  geom_bar(stat = "identity", color = "black") +
  ylab("relative Häufigkeit") +
  ggtitle("Verteilung des Verletzungsgrads") + 
  theme(plot.title = element_text(size = 20, face = "bold")) +
  theme(axis.title.x = element_text(size=14),
        axis.title.y = element_text(size=14))  +
  scale_fill_manual(values = color_plot, name = "Boniturnote", labels = c(0,1,2,3))
barplot_Sverletz



### 2.frisches Blut ----------------------------------------------------------------------------------

# Wie häufig tritt frisches Blut auf?
Anzahl_frBlut <- list()
length(Anzahl_frBlut) <- length(Daten_K1_K19)
# names(Anzahl_frBlut) <- paste("Versuch K", 1:length(Daten_K1_K19), sep = "")
for (i in c(1:11,13:18))
{
  Anzahl_frBlut[[i]] <- Daten_K1_K19[[i]] %>% select("fr.Blut") %>% table() 
}
Anzahl_frBlut[[19]] <- Daten_K1_K19[[19]] %>% select("fr. Blut") %>% table() 
Anzahl_frBlut[[11]] <- Anzahl_frBlut[[11]][1:2]
Anzahl_frBlut[[17]] <- Anzahl_frBlut[[17]][c(1,3)]
Anzahl_frBlut


# extrahiere aus der Liste der Häufigkeitstabellen die Auftrittshäufigkeit von frischem Blutin den Versuchen K1-K19
frBlut_0 <- vector()
frBlut_1 <- vector()
length(frBlut_0) <- length(Anzahl_frBlut)
length(frBlut_1) <- length(Anzahl_frBlut)
for (i in numvec_12)
{
  frBlut_0[i] <- Anzahl_frBlut[[i]][1]
  frBlut_1[i] <- Anzahl_frBlut[[i]][2]
}
frBlut_0
frBlut_1
Versuch <- 1:19

gesamt <- vector()
length(gesamt) <- length(Anzahl_frBlut)
for (i in 1:length(Anzahl_frBlut))
{
  gesamt[i] <- sum(frBlut_0[i], frBlut_1[i])
}
gesamt

# Datensatz zu den Häufigkeiten der versch. Verletzungsgrade in jedem Versuch (in short und long format)
Anzahl_frBlut_df <- data.frame(Versuch, frBlut_0, frBlut_1, gesamt)
Anzahl_frBlut_df_long <- Anzahl_frBlut_df %>% gather("frBlut_0", "frBlut_1", key = "frBlut", value = "Hfgk")


# Balkendiagramm 
barplot_frBlut <- ggplot(Anzahl_frBlut_df_long, aes(x = Versuch, y = (Hfgk/gesamt), fill = frBlut)) +
  geom_bar(stat = "identity", color = "black")  +
  ylab("relative Häufigkeit") +
  ggtitle("Verteilung von frisches Blut") + 
  theme(plot.title = element_text(size = 20, face = "bold")) +
  theme(axis.title.x = element_text(size=14),
        axis.title.y = element_text(size=14))   +
  scale_fill_manual(values = color_plot[c(1,4)], name = "frisches Blut", labels = c("nein", "ja"))
barplot_frBlut

### 3.Schwellung -----------------------------------------------------------------------

# Wie häufig tritt Schwellung auf?
Anzahl_Schw <- list()
length(Anzahl_Schw) <- length(Daten_K1_K19)
# names(Anzahl_frBlut) <- paste("Versuch K", 1:length(Daten_K1_K19), sep = "")
for (i in numvec_12)
{
  Anzahl_Schw[[i]] <- Daten_K1_K19[[i]] %>% select("Schw") %>% table() 
}
Anzahl_Schw[[6]] <- Anzahl_Schw[[6]][1:2]
Anzahl_Schw[[11]] <- Anzahl_Schw[[11]][1:2]
Anzahl_Schw[[14]][2] <- 0
names(Anzahl_Schw[[14]][2]) <- "1"
Anzahl_Schw


# extrahiere aus der Liste der Häufigkeitstabellen die Auftrittshäufigkeit von Schwellung in den Versuchen K1-K19
Schw_0 <- vector()
Schw_1 <- vector()
length(Schw_0) <- length(Anzahl_Schw)
length(Schw_1) <- length(Anzahl_Schw)
for (i in numvec_12)
{
  Schw_0[i] <- Anzahl_Schw[[i]][1]
  Schw_1[i] <- Anzahl_Schw[[i]][2]
}
Schw_0
Schw_1
Versuch <- 1:19

gesamt <- vector()
length(gesamt) <- length(Anzahl_Schw)
for (i in 1:length(Anzahl_Schw))
{
  gesamt[i] <- sum(Schw_0[i], Schw_1[i])
}
gesamt

# Datensatz zu den Häufigkeiten Schwellung (ja/nein) in jedem Versuch (in short und long format)
Anzahl_Schw_df <- data.frame(Versuch, Schw_0, Schw_1, gesamt)
Anzahl_Schw_df[14,3] <- 0
Anzahl_Schw_df[14,4] <- sum(Anzahl_Schw_df[14,2], Anzahl_Schw_df[14,3])
Anzahl_Schw_df_long <- Anzahl_Schw_df %>% gather("Schw_0", "Schw_1", key = "Schw", value = "Hfgk")



# Balkendiagramm
barplot_Schw <- ggplot(Anzahl_Schw_df_long, aes(x = Versuch, y = (Hfgk/gesamt), fill = Schw)) +
  geom_bar(stat = "identity", color = "black") +
  ylab("relative Häufigkeit") +
  ggtitle("Verteilung von Schwellung") + 
  theme(plot.title = element_text(size = 20, face = "bold")) +
  theme(axis.title.x = element_text(size=14),
        axis.title.y = element_text(size=14)) +
  scale_fill_manual(name = "Schwellung", labels = c("nein", "ja"), values = color_plot[c(1,4)])

barplot_Schw


### 4.Teilverlust -----------------------------------------------------------------------

# Wie häufig treten die verschiedenen Stufen des Teilverlusts auf?
Anzahl_Steilv <- list()
length(Anzahl_Steilv) <- length(Daten_K1_K19)
# names(Anzahl_Sverletz) <- paste("Versuch K", 1:length(Daten_K1_K19), sep = "")
for (i in numvec_12)
{
  Anzahl_Steilv[[i]] <- Daten_K1_K19[[i]] %>% select("Steilv") %>% table() 
}
Anzahl_Steilv



# extrahiere aus der Liste der Häufigkeitstabellen für jede Stufe des Teilverlust deren Auftrittshäufigkeit in den Versuchen K1-K19
TVerl_0 <- vector()
TVerl_0.5 <- vector()
TVerl_1 <- vector()
TVerl_2 <- vector()
TVerl_3 <- vector()
length(TVerl_0) <- length(Anzahl_Steilv)
length(TVerl_0.5) <- length(Anzahl_Steilv)
length(TVerl_1) <- length(Anzahl_Steilv)
length(TVerl_2) <- length(Anzahl_Steilv)
length(TVerl_3) <- length(Anzahl_Steilv)

for (i in numvec_12)
{
  TVerl_0[i] <- Anzahl_Steilv[[i]][1]
}
TVerl_0

for (i in c(1:11, 13:17))
{
  TVerl_0.5[i] <- 0
}
for (i in 18:19)
{
  TVerl_0.5[i] <- Anzahl_Steilv[[i]][2]
}
TVerl_0.5

for (i in c(1:11, 13, 15:17))
{
  TVerl_1[i] <- Anzahl_Steilv[[i]][2]     
}
for (i in 18:19)
{
  TVerl_1[i] <- Anzahl_Steilv[[i]][3] 
}
TVerl_1[14] <- 0
TVerl_1

for (i in c(1:11, 13:17))
{
  TVerl_2[i] <- 0
}
for (i in 18:19)
{
  TVerl_2[i] <- Anzahl_Steilv[[i]][4]
}
TVerl_2

for (i in c(1:11, 13:18))
{
  TVerl_3[i] <- 0
}
TVerl_3[19] <- Anzahl_Steilv[[19]][5]
TVerl_3

Versuch <- 1:19

gesamt <- vector()
length(gesamt) <- length(Anzahl_Steilv)
for (i in 1:length(Anzahl_Steilv))
{
  gesamt[i] <- sum(TVerl_0[i], TVerl_0.5[i], TVerl_1[i], TVerl_2[i], TVerl_3[i])
}
gesamt


# Datensatz zu den Häufigkeiten der versch. Stufen des Teilverlust in jedem Versuch (in short und long format)
Anzahl_Steilv_df <- data.frame(Versuch, TVerl_0, TVerl_0.5, TVerl_1, TVerl_2, TVerl_3, gesamt)
Anzahl_Steilv_df_long <- Anzahl_Steilv_df %>% gather("TVerl_0", "TVerl_0.5", "TVerl_1", "TVerl_2", "TVerl_3", key = "TVerl", value = "Hfgk")



# Balkendiagramm (alles in einem Frame; Nachteil: Unübersichtlichkeit)
barplot_Steilv <- ggplot(Anzahl_Steilv_df_long, aes(x = Versuch, y = (Hfgk/gesamt)*100, fill = TVerl)) +
  geom_bar(stat = "identity") +
  ylab("prozentualer Anteil") +
  ggtitle("Verteilung von Teilverlust") + 
  theme(plot.title = element_text(size = 20, face = "bold")) +
  theme(axis.title.x = element_text(size=14),
        axis.title.y = element_text(size=14)) +
  scale_fill_manual(name = "Boniturnote", labels = c(0,0.5,1,2,3), values = c(color_plot, "black"))
barplot_Steilv





############################################# VISUALISIERUNGEN 2 #####################################


# Datensatz Gewicht-Geschlecht einlesen .............................................................
Gewicht_K1_K18 <- read_excel_allsheets("Gewicht_Geschlecht_K1-K19.xlsx")
# Daten zu K19 in extra Datei nachgereicht
Gewicht_K19 <- readxl::read_xls("Gewichtsabruf_K19.xls")

Gewicht_K1_K19 <- list()
length(Gewicht_K1_K19) <- 19
Gewicht_K1_K19[1:18] <- Gewicht_K1_K18[1:18]
Gewicht_K1_K19[[19]] <- as.data.frame(Gewicht_K19)


# "Daten_K1_K19" und "Gewicht_K1_K19" zusammenführen ................................................

# Problem: Variable "Tier_Nr" ist in "Daten_K1_K19" ein numeric-Vektor, aber in "Gewicht_K1_K19" ein character-Vektor 
# Lösung: Variable "Tier_Nr" soll in beiden Datensätzen als numeric-Vektor auftreten
for (i in c(1:11, 13:19))
{
  Daten_K1_K19[[i]]$Tier_Nr <- as.numeric(Daten_K1_K19[[i]]$Tier_Nr)
  Gewicht_K1_K19[[i]]$Tier_Nr <- as.numeric(Gewicht_K1_K19[[i]]$Tier_Nr)
}


# Problem: in Datensatz Gewicht_K1_K19$K3 Variablename "Durchgang" statt "DG" wie in den restliche Datensätzen
# Lösung: "Durchgang" -> "DG"
names(Gewicht_K1_K19[[3]])[1]  <- "DG"


# entferne die Variablen "DG", "Behandlung", "Bucht"
for (i in c(1:11, 13:18))
{
  
  Gewicht_K1_K19[[i]] <- Gewicht_K1_K19[[i]] %>% select(-"DG", -"Behandlung", -"Bucht")             # alternativ: Gewicht_K1_K19[[i]][,-c("DG", "Behandlung", "Bucht")]  
}


# Zusammenführen der beiden Datensätze
Daten_Gewicht_K1_K19 <- list()
length(Daten_Gewicht_K1_K19) <- 19
for (i in c(1:11, 13:19))
{
  Daten_Gewicht_K1_K19[[i]] <- full_join(Daten_K1_K19[[i]], Gewicht_K1_K19[[i]], by = "Tier_Nr")
}
Daten_Gewicht_K1_K19

# Visualisierung: Behandlung vs. Sverletz/ fr.Blut/ Schw/ Steilv ......................................
library(ggplot2)
library(gridExtra)

# einheitliche Variablennamen wählen
names(Daten_Gewicht_K1_K19[[19]])[8] <- "fr.Blut"

# wie häufig tritt jede Ausprägung von den Zielvariable "Schwanzverletzung", "frisches Blut", "Schwellung" und "Teilverlust" auf?
df_Sverletz <- Daten_Gewicht_K1_K19[[1]] %>% select("Behandlung", "Sverletz") %>% group_by(Behandlung, Sverletz) %>% count(Sverletz) %>% drop_na() 
df_Sverletz  <-  df_Sverletz %>% mutate(rel.Hfgk = round(n/sum(df_Sverletz$n), digits=3)) %>% mutate(Anteil_Sverletz = rel.Hfgk*100) %>% select(Behandlung, Sverletz, Anteil_Sverletz)
df_Sverletz

df_frBlut <- Daten_Gewicht_K1_K19[[1]] %>% select("Behandlung", "fr.Blut") %>% group_by(Behandlung, fr.Blut) %>% count(fr.Blut) %>% drop_na()
df_frBlut <- df_frBlut %>% mutate(rel.Hfgk = round(n/sum(df_frBlut$n), digits=3)) %>% mutate(Anteil_frBlut = rel.Hfgk*100) %>% select(Behandlung, fr.Blut, Anteil_frBlut)
df_frBlut

df_Schw <- Daten_Gewicht_K1_K19[[1]] %>% select("Behandlung", "Schw") %>% group_by(Behandlung, Schw) %>% count(Schw) %>% drop_na()
df_Schw <- df_Schw %>% mutate(rel.Hfgk = round(n/sum(df_Schw$n), digits=3)) %>% mutate(Anteil_Schw = rel.Hfgk*100) %>% select(Behandlung, Schw, Anteil_Schw)
df_Schw

df_Steilv <- Daten_Gewicht_K1_K19[[1]] %>% select("Behandlung", "Steilv") %>% group_by(Behandlung, Steilv) %>% count(Steilv) %>% drop_na() 
df_Steilv <- df_Steilv %>% mutate(rel.Hfgk = round(n/sum(df_Steilv$n), digits=3)) %>% mutate(Anteil_Steilv = rel.Hfgk*100) %>% select(Behandlung, Steilv, Anteil_Steilv)
df_Steilv


# Plots zu der Verteilung jeder Zielvariablen in Abhängigkeit von der Behandlung
# 1.Verletzungsgrad --------------------------------------------------------------------------------------

for (i in c(1:11, 13:19))
{
  Daten_Gewicht_K1_K19[[i]]$Sverletz <- as.character(Daten_Gewicht_K1_K19[[i]]$Sverletz)
}

library(grDevices)
color_plot <- c("#fcbba1", "#fb6a4a", "#cb181d", "#67000d")

plot_Beh_Sverletz_K1 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[1]]), aes(x=Behandlung, fill=Sverletz)) +
  geom_bar(position="fill", color = "black") +
  ggtitle("ZV: Schwanzverletzung") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5)) +
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent)  +
  scale_fill_manual(values = color_plot)

plot_Beh_Sverletz_K2 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[2]]), aes(x=Behandlung, fill=Sverletz)) +
  geom_bar(position="fill", color = "black") +
  ggtitle("ZV: Schwanzverletzung") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5)) +
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot)
plot_Beh_Sverletz_K3 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[3]]), aes(x=Behandlung, fill=Sverletz)) +
  geom_bar(position="fill", color = "black") +
  ggtitle("ZV: Schwanzverletzung") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot)
plot_Beh_Sverletz_K4 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[4]]), aes(x=Behandlung, fill=Sverletz)) +
  geom_bar(position="fill", color = "black") +
  ggtitle("ZV: Schwanzverletzung") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot)
plot_Beh_Sverletz_K5 <- ggplot(Daten_Gewicht_K1_K19[[5]], aes(x=Behandlung, fill=Sverletz)) +
  geom_bar(position="fill", color = "black") +
  ggtitle("ZV: Schwanzverletzung") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot)
plot_Beh_Sverletz_K6 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[6]]), aes(x=Behandlung, fill=Sverletz)) +
  geom_bar(position="fill", color = "black") +
  ggtitle("ZV: Schwanzverletzung") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot)
plot_Beh_Sverletz_K7 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[7]]), aes(x=Behandlung, fill=Sverletz)) +
  geom_bar(position="fill", color = "black") +
  ggtitle("ZV: Schwanzverletzung") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))  
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot)
plot_Beh_Sverletz_K8 <- ggplot(Daten_Gewicht_K1_K19[[8]], aes(x=Behandlung, fill=Sverletz)) +
  geom_bar(position="fill", color = "black") +
  ggtitle("ZV: Schwanzverletzung") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot)
plot_Beh_Sverletz_K9 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[9]]), aes(x=Behandlung, fill=Sverletz)) +
  geom_bar(position="fill", color = "black") +
  ggtitle("ZV: Schwanzverletzung") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot)
plot_Beh_Sverletz_K10 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[10]]), aes(x=Behandlung, fill=Sverletz)) +
  geom_bar(position="fill", color = "black") +
  ggtitle("ZV: Schwanzverletzung") +
  ##geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5)) +
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("Standard28", "Standard21", "Tierwohl27", "Tierwohl20"))  +
  scale_y_continuous(labels = scales::percent)  +
  scale_fill_manual(values = color_plot)
plot_Beh_Sverletz_K11 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[11]]), aes(x=Behandlung, fill=Sverletz)) +
  geom_bar(position="fill", color = "black") +
  ggtitle("ZV: Schwanzverletzung") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot)
plot_Beh_Sverletz_K13 <- ggplot(Daten_Gewicht_K1_K19[[13]], aes(x=Behandlung, fill=Sverletz)) +
  geom_bar(position="fill", color = "black") +
  ggtitle("ZV: Schwanzverletzung") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot)
plot_Beh_Sverletz_K14 <- ggplot(Daten_Gewicht_K1_K19[[14]], aes(x=Behandlung, fill=Sverletz)) +
  geom_bar(position="fill", color = "black") +
  ggtitle("ZV: Schwanzverletzung") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot)
plot_Beh_Sverletz_K15 <- ggplot(Daten_Gewicht_K1_K19[[15]], aes(x=Behandlung, fill=Sverletz)) +
  geom_bar(position="fill", color = "black") +
  ggtitle("ZV: Schwanzverletzung") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot)
plot_Beh_Sverletz_K16 <- ggplot(Daten_Gewicht_K1_K19[[16]], aes(x=Behandlung, fill=Sverletz)) +
  geom_bar(position="fill", color = "black") +
  ggtitle("ZV: Schwanzverletzung") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot)
plot_Beh_Sverletz_K17 <- ggplot(Daten_Gewicht_K1_K19[[17]], aes(x=Behandlung, fill=Sverletz)) +
  geom_bar(position="fill", color = "black") +
  ggtitle("ZV: Schwanzverletzung") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot)
plot_Beh_Sverletz_K18 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[18]]), aes(x=Behandlung, fill=Sverletz)) +
  geom_bar(position="fill", color = "black") +
  ggtitle("ZV: Schwanzverletzung") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot)
plot_Beh_Sverletz_K19 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[19]]), aes(x=Behandlung, fill=Sverletz)) +
  geom_bar(position="fill", color = "black") +
  ggtitle("ZV: Schwanzverletzung") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot)



# 2.frisches Blut -----------------------------------------------------------------------------------------

for (i in c(1:11, 13:19))
{
  Daten_Gewicht_K1_K19[[i]]$fr.Blut <- as.character(Daten_Gewicht_K1_K19[[i]]$fr.Blut)
}

plot_Beh_frBlut_K1 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[1]]), aes(x=Behandlung, fill=fr.Blut)) +
  geom_bar(position="fill", color = "black") +
  ggtitle("ZV: frisches Blut") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent)  +
  scale_fill_manual(values = color_plot[c(1,4)])
plot_Beh_frBlut_K2 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[2]]), aes(x=Behandlung, fill=fr.Blut)) +
  geom_bar(position="fill", color = "black") +
  ggtitle("ZV: frisches Blut") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent)  +
  scale_fill_manual(values = color_plot[c(1,4)])
plot_Beh_frBlut_K3 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[3]]), aes(x=Behandlung, fill=fr.Blut)) +
  geom_bar(position="fill", color = "black") +
  ggtitle("ZV: frisches Blut") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  scale_y_continuous(labels = scales::percent)  +
  scale_fill_manual(values = color_plot[c(1,4)])
plot_Beh_frBlut_K4 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[4]]), aes(x=Behandlung, fill=fr.Blut)) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: frisches Blut") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  scale_y_continuous(labels = scales::percent)  +
  scale_fill_manual(values = color_plot[c(1,4)])
plot_Beh_frBlut_K5 <- ggplot(Daten_Gewicht_K1_K19[[5]], aes(x=Behandlung, fill=fr.Blut)) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: frisches Blut") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  scale_y_continuous(labels = scales::percent)  +
  scale_fill_manual(values = color_plot[c(1,4)])
plot_Beh_frBlut_K6 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[6]]), aes(x=Behandlung, fill=fr.Blut)) +
  geom_bar(position="fill", color = "black") +
  ggtitle("ZV: frisches Blut") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  scale_y_continuous(labels = scales::percent)  +
  scale_fill_manual(values = color_plot[c(1,4)])
plot_Beh_frBlut_K7 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[7]]), aes(x=Behandlung, fill=fr.Blut)) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: frisches Blut") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  scale_y_continuous(labels = scales::percent)  +
  scale_fill_manual(values = color_plot[c(1,4)])
plot_Beh_frBlut_K8 <- ggplot(Daten_Gewicht_K1_K19[[8]], aes(x=Behandlung, fill=fr.Blut)) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: frisches Blut") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  scale_y_continuous(labels = scales::percent)  +
  scale_fill_manual(values = color_plot[c(1,4)])
plot_Beh_frBlut_K9 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[9]]), aes(x=Behandlung, fill=fr.Blut)) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: frisches Blut") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  scale_y_continuous(labels = scales::percent)  +
  scale_fill_manual(values = color_plot[c(1,4)]) 
plot_Beh_frBlut_K10 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[10]]), aes(x=Behandlung, fill=fr.Blut)) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: frisches Blut") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  scale_y_continuous(labels = scales::percent)  +
  scale_fill_manual(values = color_plot[c(1,4)])
plot_Beh_frBlut_K11 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[11]]), aes(x=Behandlung, fill=fr.Blut)) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: frisches Blut") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  scale_y_continuous(labels = scales::percent)  +
  scale_fill_manual(values = c(color_plot[c(1,4)], "black"))
plot_Beh_frBlut_K13 <- ggplot(Daten_Gewicht_K1_K19[[13]], aes(x=Behandlung, fill=fr.Blut)) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: frisches Blut") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  scale_y_continuous(labels = scales::percent)  +
  scale_fill_manual(values = color_plot[c(1,4)])
plot_Beh_frBlut_K14 <- ggplot(Daten_Gewicht_K1_K19[[14]], aes(x=Behandlung, fill=fr.Blut)) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: frisches Blut") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  scale_y_continuous(labels = scales::percent)  +
  scale_fill_manual(values = color_plot[c(1,4)])
plot_Beh_frBlut_K15 <- ggplot(Daten_Gewicht_K1_K19[[15]], aes(x=Behandlung, fill=fr.Blut)) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: frisches Blut") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  scale_y_continuous(labels = scales::percent)  +
  scale_fill_manual(values = color_plot[c(1,4)])
plot_Beh_frBlut_K16 <- ggplot(Daten_Gewicht_K1_K19[[16]], aes(x=Behandlung, fill=fr.Blut)) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: frisches Blut") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  scale_y_continuous(labels = scales::percent)  +
  scale_fill_manual(values = color_plot[c(1,4)])
plot_Beh_frBlut_K17 <- ggplot(Daten_Gewicht_K1_K19[[17]], aes(x=Behandlung, fill=fr.Blut)) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: frisches Blut") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  scale_y_continuous(labels = scales::percent)  +
  scale_fill_manual(values = c(color_plot[c(1,4)], "black"))
plot_Beh_frBlut_K18 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[18]]), aes(x=Behandlung, fill=fr.Blut)) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: frisches Blut") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  scale_y_continuous(labels = scales::percent)  +
  scale_fill_manual(values = color_plot[c(1,4)])
plot_Beh_frBlut_K19 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[19]]), aes(x=Behandlung, fill=fr.Blut)) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: frisches Blut") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  scale_y_continuous(labels = scales::percent)  +
  scale_fill_manual(values = color_plot[c(1,4)])




# 3.Schwellung -------------------------------------------------------------------------------------------

for (i in c(1:11, 13:19))
{
  Daten_Gewicht_K1_K19[[i]]$Schw <- as.character(Daten_Gewicht_K1_K19[[i]]$Schw)
}

plot_Beh_Schw_K1 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[1]]), aes(x=Behandlung, fill=Schw)) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: Schwellung") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot[c(1,4)])
plot_Beh_Schw_K2 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[2]]), aes(x=Behandlung, fill=Schw)) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: Schwellung") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot[c(1,4)])
plot_Beh_Schw_K3 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[3]]), aes(x=Behandlung, fill=Schw)) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: Schwellung") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot[c(1,4)])
plot_Beh_Schw_K4 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[4]]), aes(x=Behandlung, fill=Schw)) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: Schwellung") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot[c(1,4)])
plot_Beh_Schw_K5 <- ggplot(Daten_Gewicht_K1_K19[[5]], aes(x=Behandlung, fill=Schw)) +
  geom_bar(position="fill", color = "black") +
  ggtitle("ZV: Schwellung") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot[c(1,4)])
plot_Beh_Schw_K6 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[6]]), aes(x=Behandlung, fill=Schw)) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: Schwellung") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = c(color_plot[c(1,4)], "black"))
plot_Beh_Schw_K7 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[7]]), aes(x=Behandlung, fill=Schw)) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: Schwellung") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot[c(1,4)])
plot_Beh_Schw_K8 <- ggplot(Daten_Gewicht_K1_K19[[8]], aes(x=Behandlung, fill=Schw)) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: Schwellung") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot[c(1,4)])
plot_Beh_Schw_K9 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[9]]), aes(x=Behandlung, fill=Schw)) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: Schwellung") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot[c(1,4)])
plot_Beh_Schw_K10 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[10]]), aes(x=Behandlung, fill=Schw)) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: Schwellung") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot[c(1,4)])
plot_Beh_Schw_K11 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[11]]), aes(x=Behandlung, fill=Schw)) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: Schwellung") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = c(color_plot[c(1,4)], "black"))
plot_Beh_Schw_K13 <- ggplot(Daten_Gewicht_K1_K19[[13]], aes(x=Behandlung, fill=Schw)) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: Schwellung") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot[c(1,4)])
plot_Beh_Schw_K14 <- ggplot(Daten_Gewicht_K1_K19[[14]], aes(x=Behandlung, fill=Schw)) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: Schwellung") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot[c(1,4)])
plot_Beh_Schw_K15 <- ggplot(Daten_Gewicht_K1_K19[[15]], aes(x=Behandlung, fill=Schw)) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: Schwellung") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot[c(1,4)])
plot_Beh_Schw_K16 <- ggplot(Daten_Gewicht_K1_K19[[16]], aes(x=Behandlung, fill=Schw)) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: Schwellung") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot[c(1,4)])
plot_Beh_Schw_K17 <- ggplot(Daten_Gewicht_K1_K19[[17]], aes(x=Behandlung, fill=Schw)) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: Schwellung") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot[c(1,4)])
plot_Beh_Schw_K18 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[18]]), aes(x=Behandlung, fill=Schw)) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("K18") +
  ggtitle("ZV: Schwellung") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot[c(1,4)])
plot_Beh_Schw_K19 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[19]]), aes(x=Behandlung, fill=Schw)) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: Schwellung") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot[c(1,4)])





# 4.Teilverlust ---------------------------------------------------------------------------------------

for (i in c(1:11, 13:19))
{
  Daten_Gewicht_K1_K19[[i]]$Steilv <- as.character(Daten_Gewicht_K1_K19[[i]]$Steilv)
}

plot_Beh_Steilv_K1 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[1]]), aes(x=Behandlung, fill=factor(Steilv))) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: Teilverlust") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot)
plot_Beh_Steilv_K2 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[2]]), aes(x=Behandlung, fill=factor(Steilv))) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: Teilverlust") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot)
plot_Beh_Steilv_K3 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[3]]), aes(x=Behandlung, fill=factor(Steilv))) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: Teilverlust") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot)
plot_Beh_Steilv_K4 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[4]]), aes(x=Behandlung, fill=factor(Steilv))) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: Teilverlust") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot)
plot_Beh_Steilv_K5 <- ggplot(Daten_Gewicht_K1_K19[[5]], aes(x=Behandlung, fill=factor(Steilv))) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: Teilverlust") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot)
plot_Beh_Steilv_K6 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[6]]), aes(x=Behandlung, fill=factor(Steilv))) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: Teilverlust") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot)
plot_Beh_Steilv_K7 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[7]]), aes(x=Behandlung, fill=factor(Steilv))) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: Teilverlust") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot)
plot_Beh_Steilv_K8 <- ggplot(Daten_Gewicht_K1_K19[[8]], aes(x=Behandlung, fill=factor(Steilv))) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: Teilverlust") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot)
plot_Beh_Steilv_K9 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[9]]), aes(x=Behandlung, fill=factor(Steilv))) +
  geom_bar(position="fill", color = "black")   +
  ggtitle("ZV: Teilverlust") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot)
plot_Beh_Steilv_K10 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[10]]), aes(x=Behandlung, fill=factor(Steilv))) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: Teilverlust") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot)
plot_Beh_Steilv_K11 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[11]]), aes(x=Behandlung, fill=factor(Steilv))) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: Teilverlust") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot)
plot_Beh_Steilv_K13 <- ggplot(Daten_Gewicht_K1_K19[[13]], aes(x=Behandlung, fill=factor(Steilv))) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: Teilverlust") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot)
plot_Beh_Steilv_K14 <- ggplot(Daten_Gewicht_K1_K19[[14]], aes(x=Behandlung, fill=factor(Steilv))) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: Teilverlust") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot)
plot_Beh_Steilv_K15 <- ggplot(Daten_Gewicht_K1_K19[[15]], aes(x=Behandlung, fill=factor(Steilv))) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: Teilverlust") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot)
plot_Beh_Steilv_K16 <- ggplot(Daten_Gewicht_K1_K19[[16]], aes(x=Behandlung, fill=factor(Steilv))) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: Teilverlust") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot)
plot_Beh_Steilv_K17 <- ggplot(Daten_Gewicht_K1_K19[[17]], aes(x=Behandlung, fill=factor(Steilv))) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: Teilverlust") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot)
plot_Beh_Steilv_K18 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[18]]), aes(x=Behandlung, fill=factor(Steilv))) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: Teilverlust") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot)
plot_Beh_Steilv_K19 <- ggplot(drop_na(Daten_Gewicht_K1_K19[[19]]), aes(x=Behandlung, fill=factor(Steilv))) +
  geom_bar(position="fill", color = "black")  +
  ggtitle("ZV: Teilverlust") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5))
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  #scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = c(color_plot, "black"))




#---------------------------------------------------------------------------------------------------
# plots aus der Endpräsentation

ggplot(drop_na(Daten_Gewicht_K1_K19[[1]]), aes(x=Behandlung, fill=Sverletz)) +
  geom_bar(position="fill", color = "black") +
  ggtitle("Verteilung Von Schwanzverletzung \n in Abhängigkeit von der Behandlung in K1") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5)) +
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent)  +
  scale_fill_manual(values = color_plot)

ggplot(drop_na(Daten_Gewicht_K1_K19[[2]]), aes(x=Behandlung, fill=Sverletz)) +
  geom_bar(position="fill", color = "black") +
  ggtitle("Verteilung Von Schwanzverletzung \n in Abhängigkeit von der Behandlung in K2") +
  #geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5)) +
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  scale_x_discrete(limits=c("unkupiert", "kupiert")) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_plot)

ggplot(drop_na(Daten_Gewicht_K1_K19[[10]]), aes(x=Behandlung, fill=Sverletz)) +
  geom_bar(position="fill", color = "black") +
  ggtitle("Verteilung Von Schwanzverletzung \n in Abhängigkeit von der Behandlung in K10") +
  ##geom_text(aes(label=scales::percent(..count../sum(..count..))),
  #          stat='count',position=position_fill(vjust=0.5)) +
  ylab("Anteil") +
  labs(fill="Boniturnote") +
  scale_x_discrete(limits=c("Standard28", "Standard21", "Tierwohl27", "Tierwohl20"))  +
  scale_y_continuous(labels = scales::percent)  +
  scale_fill_manual(values = color_plot)





# erstellte plots je nach Versuchseinheit ausgeben

grid.arrange(
  plot_Beh_Sverletz_K1, plot_Beh_frBlut_K1, plot_Beh_Schw_K1, plot_Beh_Steilv_K1, 
  nrow = 2,
  top = "Verteilung der Zielvariablen in Abhängigkeit von der Behandlung in K1")
grid.arrange(
  plot_Beh_Sverletz_K2, plot_Beh_frBlut_K2, plot_Beh_Schw_K2, plot_Beh_Steilv_K2, 
  nrow = 2,
  top = "Verteilung der Zielvariablen in Abhängigkeit von der Behandlung in K2")
grid.arrange(
  plot_Beh_Sverletz_K3, plot_Beh_frBlut_K3, plot_Beh_Schw_K3, plot_Beh_Steilv_K3, 
  nrow = 2,
  top = "Verteilung der Zielvariablen in Abhängigkeit von der Behandlung in K3")
grid.arrange(
  plot_Beh_Sverletz_K4, plot_Beh_frBlut_K4, plot_Beh_Schw_K4, plot_Beh_Steilv_K4, 
  nrow = 2,
  top = "Verteilung der Zielvariablen in Abhängigkeit von der Behandlung in K4")
grid.arrange(
  plot_Beh_Sverletz_K5, plot_Beh_frBlut_K5, plot_Beh_Schw_K5, plot_Beh_Steilv_K5, 
  nrow = 2,
  top = "Verteilung der Zielvariablen in Abhängigkeit von der Behandlung in K5")
grid.arrange(
  plot_Beh_Sverletz_K6, plot_Beh_frBlut_K6, plot_Beh_Schw_K6, plot_Beh_Steilv_K6, 
  nrow = 2,
  top = "Verteilung der Zielvariablen in Abhängigkeit von der Behandlung in K6")
grid.arrange(
  plot_Beh_Sverletz_K7, plot_Beh_frBlut_K7, plot_Beh_Schw_K7, plot_Beh_Steilv_K7, 
  nrow = 2,
  top = "Verteilung der Zielvariablen in Abhängigkeit von der Behandlung in K7")
grid.arrange(
  plot_Beh_Sverletz_K8, plot_Beh_frBlut_K8, plot_Beh_Schw_K8, plot_Beh_Steilv_K8, 
  nrow = 2,
  top = "Verteilung der Zielvariablen in Abhängigkeit von der Behandlung in K8")
grid.arrange(
  plot_Beh_Sverletz_K9, plot_Beh_frBlut_K9, plot_Beh_Schw_K9, plot_Beh_Steilv_K9, 
  nrow = 2,
  top = "Verteilung der Zielvariablen in Abhängigkeit von der Behandlung in K9")
grid.arrange(
  plot_Beh_Sverletz_K10, plot_Beh_frBlut_K10, plot_Beh_Schw_K10, plot_Beh_Steilv_K10, 
  nrow = 2,
  top = "Verteilung der Zielvariablen in Abhängigkeit von der Behandlung in K10")
grid.arrange(
  plot_Beh_Sverletz_K11, plot_Beh_frBlut_K11, plot_Beh_Schw_K11, plot_Beh_Steilv_K11, 
  nrow = 2,
  top = "Verteilung der Zielvariablen in Abhängigkeit von der Behandlung in K11")
grid.arrange(
  plot_Beh_Sverletz_K13, plot_Beh_frBlut_K13, plot_Beh_Schw_K13, plot_Beh_Steilv_K13, 
  nrow = 2,
  top = "Verteilung der Zielvariablen in Abhängigkeit von der Behandlung in K13")
grid.arrange(
  plot_Beh_Sverletz_K14, plot_Beh_frBlut_K14, plot_Beh_Schw_K14, plot_Beh_Steilv_K14, 
  nrow = 2,
  top = "Verteilung der Zielvariablen in Abhängigkeit von der Behandlung in K14")
grid.arrange(
  plot_Beh_Sverletz_K15, plot_Beh_frBlut_K15, plot_Beh_Schw_K15, plot_Beh_Steilv_K15, 
  nrow = 2,
  top = "Verteilung der Zielvariablen in Abhängigkeit von der Behandlung in K15")
grid.arrange(
  plot_Beh_Sverletz_K16, plot_Beh_frBlut_K16, plot_Beh_Schw_K16, plot_Beh_Steilv_K16, 
  nrow = 2,
  top = "Verteilung der Zielvariablen in Abhängigkeit von der Behandlung in K16")
grid.arrange(
  plot_Beh_Sverletz_K17, plot_Beh_frBlut_K17, plot_Beh_Schw_K17, plot_Beh_Steilv_K17, 
  nrow = 2,
  top = "Verteilung der Zielvariablen in Abhängigkeit von der Behandlung in K17")
grid.arrange(
  plot_Beh_Sverletz_K18, plot_Beh_frBlut_K18, plot_Beh_Schw_K18, plot_Beh_Steilv_K18, 
  nrow = 2,
  top = "Verteilung der Zielvariablen in Abhängigkeit von der Behandlung in K18")
grid.arrange(
  plot_Beh_Sverletz_K19, plot_Beh_frBlut_K19, plot_Beh_Schw_K19, plot_Beh_Steilv_K19, 
  nrow = 2,
  top = "Verteilung der Zielvariablen in Abhängigkeit von der Behandlung in K19")


###################################### Kreuztabellen #################################################

# Kreuztabelle mit absoluten und relativen Häufigkeiten und Anteil

# 1. Verletzungsgrad -------------------------------------------------------------------------------

kreuztabelle_Sverletz <- list()
length(kreuztabelle_Sverletz) <- length(Daten_Gewicht_K1_K19)
names(kreuztabelle_Sverletz) <- paste("K", 1:19, sep="")
for (i in c(1:11, 13:18))
{
  kreuztabelle_Sverletz_list <- list()
  length(kreuztabelle_Sverletz_list) <- 3
  names(kreuztabelle_Sverletz_list) <- c( "absolute Häufigkeiten", "relative Häufigkeiten", "Anteil")
  kreuztabelle_Sverletz_list[[1]] <- table(Daten_Gewicht_K1_K19[[i]]$Behandlung, Daten_Gewicht_K1_K19[[i]]$Sverletz) %>% addmargins()
  kreuztabelle_Sverletz_list[[2]] <- round(table(Daten_Gewicht_K1_K19[[i]]$Behandlung, Daten_Gewicht_K1_K19[[i]]$Sverletz) %>% prop.table() %>% addmargins(), digits=3) 
  kreuztabelle_Sverletz_list[[3]] <- round(table(Daten_Gewicht_K1_K19[[i]]$Behandlung, Daten_Gewicht_K1_K19[[i]]$Sverletz) %>% prop.table() %>% addmargins()*100 , digits=1)
  
  kreuztabelle_Sverletz[[i]] <- kreuztabelle_Sverletz_list
}
kreuztabelle_Sverletz



# 2. frisches Blut ----------------------------------------------------------------------------------

kreuztabelle_frBlut <- list()
length(kreuztabelle_frBlut) <- length(Daten_Gewicht_K1_K19)
names(kreuztabelle_frBlut) <- paste("K", 1:19, sep="")
for (i in c(1:11, 13:19))
{
  kreuztabelle_frBlut_list <- list()
  length(kreuztabelle_frBlut_list) <- 3
  names(kreuztabelle_frBlut_list) <- c( "absolute Häufigkeiten", "relative Häufigkeiten", "Anteil")
  kreuztabelle_frBlut_list[[1]] <- table(Daten_Gewicht_K1_K19[[i]]$Behandlung, Daten_Gewicht_K1_K19[[i]]$fr.Blut) %>% addmargins()
  kreuztabelle_frBlut_list[[2]] <- round(table(Daten_Gewicht_K1_K19[[i]]$Behandlung, Daten_Gewicht_K1_K19[[i]]$fr.Blut) %>% prop.table() %>% addmargins(), digits=3) 
  kreuztabelle_frBlut_list[[3]] <- round(table(Daten_Gewicht_K1_K19[[i]]$Behandlung, Daten_Gewicht_K1_K19[[i]]$fr.Blut) %>% prop.table() %>% addmargins()*100 , digits=1)
  
  kreuztabelle_frBlut[[i]] <- kreuztabelle_frBlut_list
}
kreuztabelle_frBlut



# 3. Schwellung ------------------------------------------------------------------------------------
kreuztabelle_Schw <- list()
length(kreuztabelle_Schw) <- length(Daten_Gewicht_K1_K19)
names(kreuztabelle_Schw) <- paste("K", 1:19, sep="")
for (i in c(1:11, 13:19))
{
  kreuztabelle_Schw_list <- list()
  length(kreuztabelle_Schw_list) <- 3
  names(kreuztabelle_Schw_list) <- c( "absolute Häufigkeiten", "relative Häufigkeiten", "Anteil")
  kreuztabelle_Schw_list[[1]] <- table(Daten_Gewicht_K1_K19[[i]]$Behandlung, Daten_Gewicht_K1_K19[[i]]$Schw) %>% addmargins()
  kreuztabelle_Schw_list[[2]] <- round(table(Daten_Gewicht_K1_K19[[i]]$Behandlung, Daten_Gewicht_K1_K19[[i]]$Schw) %>% prop.table() %>% addmargins(), digits=3) 
  kreuztabelle_Schw_list[[3]] <- round(table(Daten_Gewicht_K1_K19[[i]]$Behandlung, Daten_Gewicht_K1_K19[[i]]$Schw) %>% prop.table() %>% addmargins()*100 , digits=1)
  
  kreuztabelle_Schw[[i]] <- kreuztabelle_Schw_list
}
kreuztabelle_Schw



# 4.Teilverletzung ---------------------------------------------------------------------------------
kreuztabelle_Steilv <- list()
length(kreuztabelle_Steilv) <- length(Daten_Gewicht_K1_K19)
names(kreuztabelle_Steilv) <- paste("K", 1:19, sep="")
for (i in c(1:11, 13:19))
{
  kreuztabelle_Steilv_list <- list()
  length(kreuztabelle_Steilv_list) <- 3
  names(kreuztabelle_Steilv_list) <- c( "absolute Häufigkeiten", "relative Häufigkeiten", "Anteil")
  kreuztabelle_Steilv_list[[1]] <- table(Daten_Gewicht_K1_K19[[i]]$Behandlung, Daten_Gewicht_K1_K19[[i]]$Steilv) %>% addmargins()
  kreuztabelle_Steilv_list[[2]] <- round(table(Daten_Gewicht_K1_K19[[i]]$Behandlung, Daten_Gewicht_K1_K19[[i]]$Steilv) %>% prop.table() %>% addmargins(), digits=3) 
  kreuztabelle_Steilv_list[[3]] <- round(table(Daten_Gewicht_K1_K19[[i]]$Behandlung, Daten_Gewicht_K1_K19[[i]]$Steilv) %>% prop.table() %>% addmargins()*100 , digits=1)
  
  kreuztabelle_Steilv[[i]] <- kreuztabelle_Steilv_list
}
kreuztabelle_Steilv





#############################################################################################
############## Zeitreihenanalyse ############################################################
#############################################################################################

library(ggplot2)
library(grDevices)

# einheitlichen Variablennamen "Bonitur_Lt" verwenden (statt "Bonitur Lt"wie in K16+K17)
for (i in 16:17)
{
  names(Daten_K1_K19[[i]])[5] <- "Bonitur_Lt"
}

# benötigte Daten für die Zeitreihenanalyse in einen neuen Datensatz speichern
df_zeitreihe1 <- list()
length(df_zeitreihe1) <- length(Daten_K1_K19)
df_zeitreihe2 <- list()
length(df_zeitreihe2) <- length(Daten_K1_K19)
df_zeitreihe <- list()
length(df_zeitreihe) <- length(Daten_K1_K19)
names(df_zeitreihe) <- paste("K", 1:19, sep="")
for (i in c(1:11,13:19))
{
  Daten_K1_K19[[i]]$Sverletz <- as.numeric(Daten_K1_K19[[i]]$Sverletz)
  df_zeitreihe1[[i]] <- Daten_K1_K19[[i]] %>% 
    group_by(Bonitur_Lt, Sverletz) %>% 
    summarise(anzahl = n()) %>% group_by(Bonitur_Lt) %>% 
    mutate(anzahl_insg = sum(anzahl)) %>% 
    filter(!is.na(Sverletz)) %>% 
    mutate(anzahl_rel = anzahl/anzahl_insg) 
  df_zeitreihe2[[i]] <- data.frame("Bonitur_Lt" = rep(unique(Daten_K1_K19[[i]]$Bonitur_Lt), each=4), 
                                   "Sverletz" = rep(0:3, times=length(unique(Daten_K1_K19[[i]]$Bonitur_Lt))))
  df_zeitreihe[[i]] <- full_join(df_zeitreihe1[[i]] %>% select(Bonitur_Lt, Sverletz, anzahl_rel), df_zeitreihe2[[i]])
  df_zeitreihe[[i]]$anzahl_rel[is.na(df_zeitreihe[[i]]$anzahl_rel)] <- 0               
  
  df_zeitreihe[[i]] <- df_zeitreihe[[i]][order(df_zeitreihe[[i]]$Bonitur_Lt),]
}
df_zeitreihe


# gestapelte kerndichteschätzer
color_plot <- c("#fcbba1", "#fb6a4a", "#cb181d", "#67000d")

for (i in c(1:11, 13:19))
{
  x11()
  plot_zeitrAnal <- ggplot(df_zeitreihe[[i]], aes(x=factor(Bonitur_Lt), y=anzahl_rel, fill=factor(Sverletz), group=factor(Sverletz))) + 
    geom_area(position="stack") +
    ggtitle(paste("Verteilung von Schwanzverletzung \n im Laufe der Zeit in K", i, sep="")) + 
    theme(plot.title = element_text(size = 20, face = "bold")) +
    xlab("Bonitur Lebenstag") +
    ylab("relative Häufigkeit") +
    labs(color = "Boniturnote") +
    scale_fill_manual(name = "Boniturnote", labels = c(0,1,2,3), values = color_plot) 
  print(plot_zeitrAnal)
}


#.....................................................................................................

############################## zeitreihenanalyse für alle Durchgänge zsm ##########################

library(ggplot2)
library(grDevices)

# einheitlichen Variablennamen "Bonitur_Lt" verwenden (statt "Bonitur Lt"wie in K16+K17)
for (i in 16:17)
{
  names(Daten_K1_K19[[i]])[5] <- "Bonitur_Lt"
}

# benötigte Daten für die Zeitreihenanalyse in einen neuen Datensatz speichern
for (i in 13:19)
{
  for (j in 1:length(Daten_K1_K19[[i]]$Bonitur_Lt))
  {
    Daten_K1_K19[[i]]$Bonitur_Lt <- as.character(Daten_K1_K19[[i]]$Bonitur_Lt)
    Daten_K1_K19[[i]]$Bonitur_Lt[j] <- paste("Tag", Daten_K1_K19[[i]]$Bonitur_Lt[j], sep=" ")
  }
}

Daten_K1_K19_gesamt <- rbind(Daten_K1_K19$K1[,c("Bonitur_Lt", "Sverletz")], Daten_K1_K19$K2[,c("Bonitur_Lt", "Sverletz")], Daten_K1_K19$K3[,c("Bonitur_Lt", "Sverletz")], Daten_K1_K19$K4[,c("Bonitur_Lt", "Sverletz")], Daten_K1_K19$K5[,c("Bonitur_Lt", "Sverletz")], Daten_K1_K19$K6[,c("Bonitur_Lt", "Sverletz")],
                             Daten_K1_K19$K7[,c("Bonitur_Lt", "Sverletz")], Daten_K1_K19$K8[,c("Bonitur_Lt", "Sverletz")], Daten_K1_K19$K9[,c("Bonitur_Lt", "Sverletz")], Daten_K1_K19$K10[,c("Bonitur_Lt", "Sverletz")], Daten_K1_K19$K11[,c("Bonitur_Lt", "Sverletz")], Daten_K1_K19$K13[,c("Bonitur_Lt", "Sverletz")],
                             Daten_K1_K19$K14[,c("Bonitur_Lt", "Sverletz")], Daten_K1_K19$K15[,c("Bonitur_Lt", "Sverletz")], Daten_K1_K19$K16[,c("Bonitur_Lt", "Sverletz")], Daten_K1_K19$K17[,c("Bonitur_Lt", "Sverletz")], Daten_K1_K19$K18[,c("Bonitur_Lt", "Sverletz")], Daten_K1_K19$K19[,c("Bonitur_Lt", "Sverletz")])

Daten_K1_K19_gesamt$Sverletz <- as.numeric(Daten_K1_K19_gesamt$Sverletz)
df_zeitreihe1 <- Daten_K1_K19_gesamt %>% 
  group_by(Bonitur_Lt, Sverletz) %>% 
  summarise(anzahl = n()) %>% group_by(Bonitur_Lt) %>% 
  mutate(anzahl_insg = sum(anzahl)) %>% 
  filter(!is.na(Sverletz)) %>% 
  mutate(anzahl_rel = anzahl/anzahl_insg) 
df_zeitreihe2 <- data.frame("Bonitur_Lt" = rep(unique(Daten_K1_K19_gesamt$Bonitur_Lt), each=4), 
                            "Sverletz" = rep(0:3, times=length(unique(Daten_K1_K19_gesamt$Bonitur_Lt))))
df_zeitreihe <- full_join(df_zeitreihe1 %>% select(Bonitur_Lt, Sverletz, anzahl_rel), df_zeitreihe2)
df_zeitreihe$anzahl_rel[is.na(df_zeitreihe$anzahl_rel)] <- 0               

df_zeitreihe <- df_zeitreihe[order(df_zeitreihe$Bonitur_Lt),]

df_zeitreihe





# gestapelte kerndichteschätzer
color_plot <- c("#fcbba1", "#fb6a4a", "#cb181d", "#67000d")

x11()
plot_zeitrAnal_gesamt <- ggplot(df_zeitreihe, aes(x=factor(Bonitur_Lt), y=anzahl_rel, fill=factor(Sverletz), group=factor(Sverletz))) + 
  geom_area(position="stack") +
  ggtitle("Verteilung von Schwanzverletzung im Laufe der Zeit") + 
  theme(plot.title = element_text(size = 20, face = "bold")) +
  xlab("Bonitur Lebenstag") +
  ylab("relative Häufigkeit") +
  labs(color = "Boniturnote") +
  scale_fill_manual(name = "Boniturnote", labels = c(0,1,2,3), values = color_plot) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
plot_zeitrAnal_gesamt






##########################################################################################################
##### Regressionsanalysen ################################################################################
##########################################################################################################

######################### weitere plots für die regression #######################################

library(ggplot2)
library(grDevices)
color_plot <- c("#fcbba1", "#fb6a4a", "#cb181d", "#67000d")

### fr.Blut - Sverletz - Balkendiagramm
ferkel_plot1 <- ferkel %>% 
  select(Sverletz, fr.Blut) %>% 
  group_by(Sverletz, fr.Blut) %>% 
  summarise(anzahl_abs = n()) %>% 
  filter(fr.Blut %in% c(0, 1)) %>%
  filter(!is.na(Sverletz)) 

anzahl_insg <- sum(ferkel_plot1[,3])

x11()
barplot_frBlut_Sverletz <- ferkel_plot1 %>% 
  mutate(anzahl_insg) %>%
  mutate(anzahl_rel = anzahl_abs/anzahl_insg) %>% 
  ggplot(aes(x=factor(Sverletz), y=anzahl_rel, fill=factor(fr.Blut))) +
  geom_bar(stat="identity", position = "fill") +
  xlab("Schwanzverletzung") +
  ylab("relative Häufigkeit") +
  ggtitle("Verteilung von frisches Blut in \n Abhängigkeit von der Schwanzverletzung") + 
  theme(plot.title = element_text(size = 20, face = "bold")) +
  theme(axis.title.x = element_text(size=14),
        axis.title.y = element_text(size=14))  +
  scale_fill_manual(values = color_plot[c(1,4)], 
                    name = "Boniturnote", labels = c(0,1,2,3))
barplot_frBlut_Sverletz

### Schw - Sverletz - Balkendiagramm
ferkel_plot2 <- ferkel %>% 
  select(Sverletz, Schw) %>% 
  group_by(Sverletz, Schw) %>% 
  summarise(anzahl_abs = n()) %>% 
  filter(Schw %in% c(0, 1)) %>%
  filter(!is.na(Sverletz)) 

anzahl_insg <- sum(ferkel_plot2[,3])

x11()
barplot_Schw_Sverletz <- ferkel_plot2 %>% 
  mutate(anzahl_insg) %>%
  mutate(anzahl_rel = anzahl_abs/anzahl_insg) %>% 
  ggplot(aes(x=factor(Sverletz), y=anzahl_rel, fill=factor(Schw))) +
  geom_bar(stat="identity", position = "fill") +
  xlab("Schwanzverletzung") +
  ylab("relative Häufigkeit") +
  ggtitle("Verteilung von Schwellung in \n Abhängigkeit von der Schwanzverletzung") + 
  theme(plot.title = element_text(size = 20, face = "bold")) +
  theme(axis.title.x = element_text(size=14),
        axis.title.y = element_text(size=14))  +
  scale_fill_manual(values = color_plot[c(1,4)], 
                    name = "Boniturnote", labels = c(0,1,2,3))
barplot_Schw_Sverletz








################################################################################
##### Erste Modelle ############################################################
################################################################################

# Anfangs nur die Modelle, die wir in der Zwischenpräsentation verwendet haben,
# um einen ersten Überblick zu bekommen.
# Hier wird noch für jeden Durchgang ein eigenes Modell geschätzt und 
# es wird als Einflussgröße hauptsächlich die Behandlung betrachtet.
# Außerdem wird hier nur ein logistisches Modell verwendet und noch keine 
# zufälligen Effekte betrachtet.
# Es werden auch für jeden Durchgang Koeffizientenplots zur Visualisierung 
# erstellt. Um diese anzuschauen, einfach den Namen des Plots vor dem jeweiligen
# Pfeil markieren und ausführen.
# Die endgültigen Modelle folgen im Abschnitt "Regressionsmodell für alle
# Durchgänge", der deutlich gekennzeichnet ist.

# Betrachtung der Schwanzverletzungen


# K1
ferkel_DG1$Behandlung <- relevel(as.factor(ferkel_DG1$Behandlung), ref = "unkupiert")

reg_sverletzjn_dg1 <- glm(Sverletzjn ~ Behandlung, family = binomial(link = 'logit'), data = ferkel_DG1)
coef(reg_sverletzjn_dg1)
exp(coef(reg_sverletzjn_dg1))


# K2
ferkel_DG2$Behandlung <- relevel(as.factor(ferkel_DG2$Behandlung), ref = "unkupiert")

reg_sverletzjn_dg2 <- glm(Sverletzjn ~ Behandlung, family = binomial(link = 'logit'), data = ferkel_DG2)
coef(reg_sverletzjn_dg2)
exp(coef(reg_sverletzjn_dg2))


# K3
ferkel_DG3$Behandlung <- relevel(as.factor(ferkel_DG3$Behandlung), ref = "Standard")

reg_sverletzjn_dg3 <- glm(Sverletzjn ~ Behandlung, family = binomial(link = 'logit'), data = ferkel_DG3)
coef(reg_sverletzjn_dg3)
exp(coef(reg_sverletzjn_dg3))


# K4
ferkel_DG4$Behandlung <- relevel(as.factor(ferkel_DG4$Behandlung), ref = "Standard")

reg_sverletzjn_dg4 <- glm(Sverletzjn ~ Behandlung, family = binomial(link = 'logit'), data = ferkel_DG4)
coef(reg_sverletzjn_dg4)
exp(coef(reg_sverletzjn_dg4))


# K5
reg_sverletzjn_dg5 <- glm(Sverletzjn ~ Behandlung, family = binomial(link = 'logit'), data = ferkel_DG5)
coef(reg_sverletzjn_dg5)
exp(coef(reg_sverletzjn_dg5))

# K6
reg_sverletzjn_dg6 <- glm(Sverletzjn ~ Behandlung, family = binomial(link = 'logit'), data = ferkel_DG6)
coef(reg_sverletzjn_dg6)
exp(coef(reg_sverletzjn_dg6))


# K7 
ferkel_DG7$Behandlung <- relevel(as.factor(ferkel_DG7$Behandlung), ref = "Heu")

reg_sverletzjn_dg7 <- glm(Sverletzjn ~ Behandlung, family = binomial(link = 'logit'), data = ferkel_DG7)
coef(reg_sverletzjn_dg7)
exp(coef(reg_sverletzjn_dg7))


# K8
ferkel_DG8$Behandlung <- relevel(as.factor(ferkel_DG8$Behandlung), ref = "unkupiert")

reg_sverletzjn_dg8 <- glm(Sverletzjn ~ Behandlung, family = binomial(link = 'logit'), data = ferkel_DG8)
coef(reg_sverletzjn_dg8)
exp(coef(reg_sverletzjn_dg8))


# K9
reg_sverletzjn_dg9 <- glm(Sverletzjn ~ Behandlung, family = binomial(link = 'logit'), data = ferkel_DG9)
coef(reg_sverletzjn_dg9)
exp(coef(reg_sverletzjn_dg9))


# K10
ferkel_DG10$Behandlung <- relevel(as.factor(ferkel_DG10$Behandlung), ref = "Standard28")

reg_sverletzjn_dg10 <- glm(Sverletzjn ~ Behandlung, family = binomial(link = 'logit'), data = ferkel_DG10)
coef(reg_sverletzjn_dg10)
exp(coef(reg_sverletzjn_dg10))


# K11
ferkel_DG11$Behandlung <- relevel(as.factor(ferkel_DG11$Behandlung), ref = "Standard 28")

reg_sverletzjn_dg11 <- glm(Sverletzjn ~ Behandlung, family = binomial(link = 'logit'), data = ferkel_DG11)
coef(reg_sverletzjn_dg11)
exp(coef(reg_sverletzjn_dg11))


# K13
ferkel_DG13$Behandlung <- relevel(as.factor(ferkel_DG13$Behandlung), ref = "lang")

reg_sverletzjn_dg13 <- glm(Sverletzjn ~ Behandlung, family = binomial(link = 'logit'), data = ferkel_DG13)
coef(reg_sverletzjn_dg13)
exp(coef(reg_sverletzjn_dg13))


# K14
ferkel_DG14$Behandlung <- relevel(as.factor(ferkel_DG14$Behandlung), ref = "TW 20")

reg_sverletzjn_dg14 <- glm(Sverletzjn ~ Behandlung, family = binomial(link = 'logit'), data = ferkel_DG14)
coef(reg_sverletzjn_dg14)
exp(coef(reg_sverletzjn_dg14))


# K15
ferkel_DG15$Behandlung <- relevel(as.factor(ferkel_DG15$Behandlung), ref = "Fix")

reg_sverletzjn_dg15 <- glm(Sverletzjn ~ Behandlung, family = binomial(link = 'logit'), data = ferkel_DG15)
coef(reg_sverletzjn_dg15)
exp(coef(reg_sverletzjn_dg15))


# K16
ferkel_DG16$Behandlung <- relevel(as.factor(ferkel_DG16$Behandlung), ref = "Heu")


reg_sverletzjn_dg16 <- glm(Sverletzjn ~ Behandlung, family = binomial(link = 'logit'), data = ferkel_DG16)
coef(reg_sverletzjn_dg16)
exp(coef(reg_sverletzjn_dg16))


# K17
ferkel_DG17$Behandlung <- relevel(as.factor(ferkel_DG17$Behandlung), ref = "Fix")

reg_sverletzjn_dg17 <- glm(Sverletzjn ~ Behandlung, family = binomial(link = 'logit'), data = ferkel_DG17)
coef(reg_sverletzjn_dg17)
exp(coef(reg_sverletzjn_dg17))


# K18
ferkel_DG18$Behandlung <- relevel(as.factor(ferkel_DG18$Behandlung), ref = "Trocken")

reg_sverletzjn_dg18 <- glm(Sverletzjn ~ Behandlung, family = binomial(link = 'logit'), data = ferkel_DG18)
coef(reg_sverletzjn_dg18)
exp(coef(reg_sverletzjn_dg18))


# K19
ferkel_DG19$Behandlung <- relevel(as.factor(ferkel_DG19$Behandlung), ref = "Fixierung")

reg_sverletzjn_dg19 <- glm(Sverletzjn ~ Behandlung, family = binomial(link = 'logit'), data = ferkel_DG19)
coef(reg_sverletzjn_dg19)
exp(coef(reg_sverletzjn_dg19))


# Plot der Koeffizienten (unter anderem zusammengefasst nach Behandlung)
library(jtools)

#  Durchgänge mit Behandlung der Kupierlänge: K1, K2, K8, K13
plot_coefs(reg_sverletzjn_dg1, reg_sverletzjn_dg2, reg_sverletzjn_dg8, reg_sverletzjn_dg13, exp = TRUE)
plot_coefs(reg_sverletzjn_dg1, reg_sverletzjn_dg2, exp = TRUE, model.names = c("K1", "K2"), legend.title = "Durchgang", point.shape = FALSE, xlab = "exp(Behandlung)")


# Standard und Tierwohl
plot_coefs(reg_sverletzjn_dg3, reg_sverletzjn_dg4, exp = TRUE, model.names = c("K3", "K4"), legend.title = "Durchgang", point.shape = FALSE, xlab = "exp(Behandlung)")
plot_coefs(reg_sverletzjn_dg5, reg_sverletzjn_dg6, exp = TRUE, model.names = c("K5", "K6"), legend.title = "Durchgang", point.shape = FALSE, xlab = "exp(Behandlung)")

# Fixierung und Bewegung
plot_coefs(reg_sverletzjn_dg15, reg_sverletzjn_dg17, reg_sverletzjn_dg19, exp = TRUE, model.names = c("K15", "K17", "K19"), legend.title = "Durchgang", point.shape = FALSE, xlab = "exp(Behandlung)")

# Heu/Grascobs und Trockenfutter/Brei
plot_coefs(reg_sverletzjn_dg16, reg_sverletzjn_dg18, exp = TRUE, model.names = c("K16", "K18"), legend.title = "Durchgang", point.shape = FALSE, xlab = "exp(Behandlung)")

# Heu TWI TWII Maissilage
plot_coefs(reg_sverletzjn_dg7, exp = TRUE, model.names = c("K7"), legend.title = "Durchgang", point.shape = FALSE, xlab = "exp(Behandlung)")

# Vaterrasse
plot_coefs(reg_sverletzjn_dg9, exp = TRUE, model.names = c("K9"), legend.title = "Durchgang", point.shape = FALSE, xlab = "exp(Behandlung)")

# Standard21/28, TW20/27
plot_coefs(reg_sverletzjn_dg10, reg_sverletzjn_dg11, exp = TRUE, model.names = c("K10", "K11"), legend.title = "Durchgang", point.shape = FALSE, xlab = "exp(Behandlung)")


# Einbezug anderer Variablen in K2
reg_sverletzjn_dg2_erweitert <- glm(Sverletzjn ~ Behandlung + Geschlecht + Zunahmen, family = binomial(link = 'logit'), data = ferkel_DG2)
coef(reg_sverletzjn_dg2_erweitert)
exp(coef(reg_sverletzjn_dg2_erweitert)) 

effektplot_reg_sverletzjn_dg2_erweitert <- plot(allEffects(reg_sverletzjn_dg2_erweitert), ylab = "Schwanzverletzung j/n")


###############################################################################
### Regressionsmodell für alle Durchgänge #####################################
###############################################################################

# Aufbereitung der Daten:
# Hier wird für die Regressionsanalyse ein Datensatz erstellt, der nur noch die 
# Variablen beinhaltet, die in das Modell miteinfließen, damit fehlende Werte
# bei anderen Variablen keinen Einfluss nehmen.


# Datensatz klimasau_reg ohne Klimadaten
klimasau_reg <- klimasau %>%
  select(DG, Tier_Nr, Sverletzjn, Blutjn, Schwellungjn, Steilvjn, Behandlung, Geschlecht, Zunahmen, Fensterbucht) %>%
  na.omit()
klimasau_reg$Behandlung <- factor(klimasau_reg$Behandlung, levels = c("Standard", "unkupiert", "zweidrittel", "kupiert",
                                                                      "Standard 21", "Tierwohl 27", "Tierwohl 20",
                                                                      "Tierwohl 20 F3", "Tierwohl 20+ F3", 
                                                                      "Tierwohl I", "Tierwohl II", "Maissilage", "Heu",
                                                                      "Grascobs", "Brei", "Trocken", "Du", "Pi",
                                                                      "Fixierung", "Bewegung"))


# Datensatz klimasau_reg_Klima mit Klimadaten
klimasau_reg_Klima <- klimasau %>%
  select(DG, Tier_Nr, Sverletzjn, Blutjn, Schwellungjn, Steilvjn, Behandlung, Geschlecht, Zunahmen, Fensterbucht, mean_temp, mean_rel_Luftf) %>%
  na.omit()
klimasau_reg_Klima$Behandlung <- factor(klimasau_reg_Klima$Behandlung, levels = c("Standard", "unkupiert", "zweidrittel", "kupiert",
                                                                                  "Standard 21", "Tierwohl 27", "Tierwohl 20",
                                                                                  "Tierwohl 20 F3", "Tierwohl 20+ F3", 
                                                                                  "Tierwohl I", "Tierwohl II", "Maissilage", "Heu",
                                                                                  "Grascobs", "Brei", "Trocken", "Du", "Pi",
                                                                                  "Fixierung", "Bewegung"))


# Modelle für Sverletzjn (was wirkt sich positv aus, dass keine Verletzungen auftreten?)

# Modelle ohne Klimaeffekt
#  Es wurde zuerst immer ein logit-Modell geschätzt und dann ein 
# gemischtes Logit-Modell mit zufälligen Effekten, die an der Endung
# mixed_modell ersichtlich sind (gilt auch für die Plots)

library(jtools)

reg_sverletzjn_K1_K19 <- glm(Sverletzjn ~ Behandlung + Geschlecht + Zunahmen + Fensterbucht, data = klimasau_reg, family = binomial(link = 'logit'))

reg_sverletzjn_K1_K19_mixed_modell <- glmer(Sverletzjn ~ Behandlung + Geschlecht + Zunahmen + Fensterbucht + (1|Tier_Nr) + (1|DG), data = klimasau_reg, family = binomial(link = 'logit'))


# Modellerweiterung: Aufnahme Klimaeffekt

reg_sverletzjn_K1_K19_Klima <- glm(Sverletzjn ~ Behandlung + Geschlecht + Zunahmen + Fensterbucht + mean_temp + mean_rel_Luftf, data = klimasau_reg_Klima, family = binomial(link = 'logit'))

reg_sverletzjn_K1_K19_Klima_mixed_modell <- glmer(Sverletzjn ~ Behandlung + Geschlecht + Zunahmen + Fensterbucht + mean_temp + mean_rel_Luftf + (1|Tier_Nr) + (1|DG), data = klimasau_reg_Klima, family = binomial(link = 'logit'))


# Signifikanzanalyse des Modells der Schwanzverletzung

#Modell ohne Klimaeffekten
anova_mixed_model_Sverletzjn <- Anova(reg_sverletzjn_K1_K19_mixed_modell)

#Modell mit Klimaeffekten
anova_mixed_model_Sverletzjn_Klima <- Anova(reg_sverletzjn_K1_K19_Klima_mixed_modell)

# Plots der Modelle

# ohne Klima
coefplot_reg_severletzjn_K1_K19 <- plot_coefs(reg_sverletzjn_K1_K19, exp = TRUE, omit.coefs = "(Intercept)")

coefplot_reg_sverletzjn_K1_K19_mixed_modell <- plot_coefs(reg_sverletzjn_K1_K19_mixed_modell, exp = TRUE, omit.coefs = "(Intercept)", colors = "#de2d26") +
  labs(title = "Koeffizientenplot Modell ohne Klimaeffekte", x = "exp(geschätzte Koeffizienten)")

# mit Klima
coefplot_reg_severletzjn_K1_K19_Klima <- plot_coefs(reg_sverletzjn_K1_K19_Klima, exp = TRUE, omit.coefs = "(Intercept)")

coefplot_reg_severletzjn_K1_K19_Klima_mixed_modell <- plot_coefs(reg_sverletzjn_K1_K19_Klima_mixed_modell, exp = TRUE, omit.coefs = "(Intercept)", colors = "#c994c7")+
  labs(title = "Koeffizientenplot Modell mit Klimaeffekten", x = "exp(geschätzte Koeffizienten)")
coefplot_reg_severletzjn_K1_K19_Klima_mixed_modell_nur_Klima <- plot_coefs(reg_sverletzjn_K1_K19_Klima_mixed_modell, exp = TRUE, coefs = c("Mittlere Temperatur" = "mean_temp", "Mittlere relative Luftfeuchtigkeit" = "mean_rel_Luftf"), colors = "#c994c7",
                                                                           groups = list("Temperatur (Wertebereich [23,30; 30,31])" = c("Mittlere Temperatur"), "Luftfeuchtigkeit (Wertebereich [6,21; 71,35])" = c("Mittlere relative Luftfeuchtigkeit"))) +
  labs(title = "Klimakoeffizienten im Klimamodell", x = "exp(geschätzte Koeffizienten)")


coefplot_reg_sverletzjn_K1_K19_mixed_modell_klimavergleich <- plot_coefs(reg_sverletzjn_K1_K19_mixed_modell, reg_sverletzjn_K1_K19_Klima_mixed_modell, exp = TRUE, omit.coefs = "(Intercept)",
                                                                         point.shape = FALSE, colors = c("#de2d26", "#c994c7"), legend.title = "Modell", model.names = c("ohne Klimaeffekt", "mit Klimaeffekt")) +
  labs(title = "Vergleich der Modelle ohne und mit Klimaeffekt", x = "geschätzte Koeffizienten") +
  coord_cartesian(xlim = c(0,50))


# Modelle für frisches Blut als abhängige Variable

# Modelle ohne Klimaeffekt

reg_blutjn_K1_K19 <- glm(Blutjn ~ Behandlung + Geschlecht + Zunahmen + Fensterbucht, data = klimasau_reg, family = binomial(link = 'logit'))

reg_blutjn_K1_K19_mixed_modell <- glmer(Blutjn ~ Behandlung + Geschlecht + Zunahmen + Fensterbucht + (1|Tier_Nr) + (1|DG), data = klimasau_reg, family = binomial(link = 'logit'))


# Modellerweiterung: Aufnahme Klimaeffekt

reg_blutjn_K1_K19_Klima <- glm(Blutjn ~ Behandlung + Geschlecht + Zunahmen + Fensterbucht + mean_temp + mean_rel_Luftf, data = klimasau_reg_Klima, family = binomial(link = 'logit'))

reg_blutjn_K1_K19_Klima_mixed_modell <- glmer(Sverletzjn ~ Behandlung + Geschlecht + Zunahmen + Fensterbucht + mean_temp + mean_rel_Luftf + (1|Tier_Nr) + (1|DG), data = klimasau_reg_Klima, family = binomial(link = 'logit'))


# Plots der Modelle für frisches Blut

# ohne Klima
coefplot_reg_blutjn_K1_K19 <- plot_coefs(reg_blutjn_K1_K19, exp = TRUE, omit.coefs = "(Intercept)")

coefplot_reg_blutjn_K1_K19_mixed_modell <- plot_coefs(reg_blutjn_K1_K19_mixed_modell, exp = TRUE, omit.coefs = "(Intercept)", colors = "#de2d26") 

# mit Klima
coefplot_reg_blutjn_K1_K19_Klima <- plot_coefs(reg_blutjn_K1_K19_Klima, exp = TRUE, omit.coefs = "(Intercept)")

coefplot_reg_blutjn_K1_K19_Klima_mixed_modell <- plot_coefs(reg_blutjn_K1_K19_Klima_mixed_modell, exp = TRUE, omit.coefs = "(Intercept)")



# Modelle für Auftreten von Schwellungen

# Modelle ohne Klimaeffekt

reg_schwellungjn_K1_K19 <- glm(Schwellungjn ~ Behandlung + Geschlecht + Zunahmen + Fensterbucht, data = klimasau_reg, family = binomial(link = 'logit'))

reg_schwellungjn_K1_K19_mixed_modell <- glmer(Schwellungjn ~ Behandlung + Geschlecht + Zunahmen + Fensterbucht + (1|Tier_Nr) + (1|DG), data = klimasau_reg, family = binomial(link = 'logit'))


# Modellerweiterung: Aufnahme Klimaeffekt

reg_schwellungjn_K1_K19_Klima <- glm(Schwellungjn ~ Behandlung + Geschlecht + Zunahmen + Fensterbucht + mean_temp + mean_rel_Luftf, data = klimasau_reg_Klima, family = binomial(link = 'logit'))

reg_schwellungjn_K1_K19_Klima_mixed_modell <- glmer(Schwellungjn ~ Behandlung + Geschlecht + Zunahmen + Fensterbucht + mean_temp + mean_rel_Luftf + (1|Tier_Nr) + (1|DG), data = klimasau_reg_Klima, family = binomial(link = 'logit'))


# Plots der Modelle

# ohne Klima
coefplot_reg_schwellungjn_K1_K19 <- plot_coefs(reg_schwellungjn_K1_K19, exp = TRUE, omit.coefs = "(Intercept)")

coefplot_reg_schwellungjn_K1_K19_mixed_modell <- plot_coefs(reg_schwellungjn_K1_K19_mixed_modell, exp = TRUE, omit.coefs = "(Intercept)")


# mit Klima
coefplot_reg_schwellungjn_K1_K19_Klima <- plot_coefs(reg_schwellungjn_K1_K19_Klima, exp = TRUE, omit.coefs = "(Intercept)")

coefplot_reg_schwellungjn_K1_K19_Klima_mixed_modell <- plot_coefs(reg_schwellungjn_K1_K19_Klima_mixed_modell, exp = TRUE, omit.coefs = "(Intercept)")




#############################################################################################
################## Vorbereitung der Endpräsentation #########################################
############################################################################################


# Im Folgenden noch alle weiteren Plots, die bisher so noch nicht
# existieren, aber in der Endpräsentation gezeigt werden.

# Vergleich abhängige Variablen: Sverletzjn und Blutjn

coefplot_reg_sverletzjn_blutjn_mixed_modell <- plot_coefs(reg_sverletzjn_K1_K19_mixed_modell, reg_blutjn_K1_K19_mixed_modell, exp = TRUE, point.shape = FALSE,  omit.coefs = c("(Intercept)", "BehandlungTierwohl 20+ F3"), colors = c("#de2d26", "#9ecae1"), legend.title = "Abhängige Variable", model.names = c("Schwanzverletzung", "Frisches Blut")) +
  labs(title = "Vergleich von Schwanzverletzung und frisches Blut als abhängige Variable", x = "exp(geschätzte Koeffizienten)")


# Modell ohne Klimaeffekte: Behandlung - Schwanzlänge
coefplot_reg_severletzjn_K1_K19_mixed_modell_Behadlung_schwanzlänge <- plot_coefs(reg_sverletzjn_K1_K19_mixed_modell, exp = TRUE, coefs = c("unkupiert" = "Behandlungunkupiert", "zweidrittel" = "Behandlungzweidrittel", "kupiert" = "Behandlungkupiert"), colors = "#de2d26",
                                                                                  groups = list("Schwanzlänge - Referenz: Standard 28" = c("unkupiert", "zweidrittel", "kupiert"))) +
  labs(title = "Einfluss der Schwanzlänge auf das Verhindern von Verletzungen", x = "exp(geschätzte Koeffizienten)")

# Modell ohne Klimaeffekte: Behandlung - Bucht

coefplot_reg_severletzjn_K1_K19_mixed_modell_Behadlung_bucht <- plot_coefs(reg_sverletzjn_K1_K19_mixed_modell, exp = TRUE, coefs = c("Standard 21" = "BehandlungStandard 21", "Tierwohl 27" = "BehandlungTierwohl 27", "Tierwohl 20" = "BehandlungTierwohl 20", "Tierwohl 20 F3" = "BehandlungTierwohl 20 F3",
                                                                                                                                     "Tierwohl 20+ F3" = "BehandlungTierwohl 20+ F3", "Fixierung" = "BehandlungFixierung", "Bewegung" = "BehandlungBewegung"), colors = "#de2d26",
                                                                           groups = list("1) F5/F6 (Referenz: Standard 28)" = c("Standard 21", "Tierwohl 27", "Tierwohl 20"), "2) F3 (Referenz: Standard 28)" = c("Tierwohl 20 F3", "Tierwohl 20+ F3"), "3) Abferkelstall (Referenz: Standard 28)" = c("Fixierung", "Bewegung"))) +
  labs(title = "Einfluss der verschiedenen Buchten auf das Verhindern von Verletzungen", x = "exp(geschätzte Koeffizienten)")

# Modell ohne Klimaeffekte: Behandlung - Strategien

coefplot_reg_severletzjn_K1_K19_mixed_modell_Behadlung_strategien <- plot_coefs(reg_sverletzjn_K1_K19_mixed_modell, exp = TRUE, coefs = c("Luzerne ad lib." = "BehandlungTierwohl I", "Zusätzl. Beschäftigung" = "BehandlungTierwohl II", "Maissilage" = "BehandlungMaissilage", "Heu" = "BehandlungHeu", "Grascobs" = "BehandlungGrascobs",
                                                                                                                                          "Brei" = "BehandlungBrei", "Trocken" = "BehandlungTrocken", "Duroc" = "BehandlungDu", "Pietrain" = "BehandlungPi"), colors = "#de2d26",
                                                                                groups = list("1) Futter (Referenz: Standard 28)" = c("Luzerne ad lib.", "Zusätzl. Beschäftigung", "Maissilage", "Heu", "Grascobs", "Brei", "Trocken"), "2) Vaterrasse (Referenz: Standard 28)" = c("Duroc", "Pietrain"))) +
  labs(title = "Einfluss weiterer Behandlungsstrategien auf das Verhindern von Verletzungen", x = "exp(geschätzte Koeffizienten)")


# Modell ohne Klimaeffekte: Restliche Behandlung
coefplot_reg_sverletzjn_mixed_modell_restliche_koeffizienten <- plot_coefs(reg_sverletzjn_K1_K19_mixed_modell, exp = TRUE, coefs = c("Geschlecht weiblich" = "Geschlechtw", "Zunahmen" = "Zunahmen", "Fensterbucht ja" = "Fensterbuchtja"), colors = "#de2d26",
                                                                           groups = list("Geschlecht (Referenz: männlich)" = c("Geschlecht weiblich"), "Fensterbucht (Referenz: nein)" = c("Fensterbucht ja"), "Zunahmen (Wertebereich [-0,4; 0,85])" = c("Zunahmen"))) +
  labs(title = "Einfluss der restlichen Variablen auf das Verhindern von Verletzungen", x = "exp(geschätzte Koeffizienten)") 



#################################################################################################
############## Analysen für den Endbericht ######################################################
#################################################################################################

# Beispiele zur Methodikerklärung
# einfaches lineares Regressionsmodell
# Zunahmen in Abhängigkeit der Temperatur

linear_mod_temp <- lm(Zunahmen ~ mean_temp, data = klimasau_reg_Klima)

# multiples lineares Regressionsmodell
# Zunahmen in Abhängikeit von Temperatur und Luftfeuchtigkeit
linear_mod_temp_lftg <- lm(Zunahmen ~ mean_temp + mean_rel_Luftf, data = klimasau_reg_Klima)

# Negativbeispiel Schwanzverletzung lineares Modell in Abhängigkeit der Temperatur 
linear_mod_temp_Sverletz <- lm(Sverletzjn ~ mean_temp, data = klimasau_reg_Klima)

# Logistisches Modell
# Schwanzverletzung in Abhängigkeit einer metrischen (Temperatur) und einer 
# kategorialen (Behandlung) Variable
logit_mod_klima_behand <- glm(Sverletzjn ~ mean_temp + Behandlung, data = klimasau_reg_Klima)

# Gemischtes lineares Modell
# Zunahmen in Abhängigkeit von der Temperatur mit zufälligen Effekten für jedes Ferkel
mixed_linear_mod_temp <- glmer(Zunahmen ~ mean_temp + (1|Tier_Nr), data = klimasau_reg_Klima)
