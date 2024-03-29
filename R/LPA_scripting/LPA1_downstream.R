# 
# spelunking.R -- tbh, just cleaning up really messy spreadsheets and trying
# to get some clean summary statistics for paper revisions.
#
# Ben Decato
#

rm(list=ls())

library(tidyverse)
library(readxl)
library(broom)

setwd("~/Desktop/LPA Revisions/")

# Set up my ggplot theme for use with all visualizations
myTheme <- theme_bw() +
  theme(text = element_text(size=16), axis.text = element_text(size = 14),
        axis.text.x = element_text(angle = 45, hjust = 1),
        strip.background = element_blank(),
        strip.placement = "outside")

yi <- "IM136-003 Pivot table for all biomarkers for publication.xlsx"
clinical <- yi %>% 
  excel_sheets() %>% 
  set_names() %>% 
  map(read_excel, path = yi)
biomarkers <- clinical$`biomarker data`
patientKey <- clinical$`Subject ID`

newPC6 <- "ProC-6 file for Ben.xlsx"
pc6 <- newPC6 %>% 
  excel_sheets() %>% 
  set_names() %>% 
  map(read_excel, path = newPC6)
pc6 <- pc6$`copy Sheet1 (2) sort 5 +PC3`
pc6 <- pc6 %>% 
  select(`Subject Code`, Timepoint, Measurement = `ng/ml...4`) %>%
  mutate(Timepoint = case_when(Timepoint == "D28 pre-dose" ~ "Week 4",
                               Timepoint == "Sparse D1 pre-dose" ~ "Baseline",
                               Timepoint == "Intensive D1 pre-dose" ~ "Baseline",
                               Timepoint == "W26 pre-dose" ~ "Week 26")) %>%
  mutate(Biomarker = "PRO-C6 ng/mL")

biomarkers_smaller <- biomarkers %>%
  left_join(patientKey) %>%
  select(SUBJID, SEX, RACE, TRTP, `Subject Code`,
         starts_with("C1M"), starts_with("C3A"), starts_with("C3M"),
         starts_with("C4M2"), starts_with("C6M"), starts_with("P4NP"),
         starts_with("PRO-C3"), starts_with("VICM")) %>%
  gather( `C1M ng/mL.DAY -1 Value`:`VICM ng/mL.WEEK 26 Value`, 
          key = "Biomarker", value = "Measurement") %>%
  separate(Biomarker, into = c("Biomarker", "Timepoint"), sep = "\\.") %>%
  mutate(Timepoint = case_when(Timepoint == "DAY 28 Value" ~ "Week 4",
                               Timepoint == "DAY -1 Value" ~ "Baseline",
                               Timepoint == "WEEK 26 Value" ~ "Week 26"))

demographics <- biomarkers_smaller %>% 
  select(SUBJID, SEX, RACE, TRTP, `Subject Code`) %>% 
  unique()

pc6 <- left_join(pc6, demographics)

biomarkers_long <- rbind(biomarkers_smaller, pc6)

rm(yi, newPC6, pc6, patientKey, clinical, biomarkers_smaller, biomarkers)

biomarkers_long$Measurement <- as.double(biomarkers_long$Measurement)

baseline <- biomarkers_long %>% 
  filter(Timepoint == "Baseline") %>% 
  select(SUBJID, Biomarker, Baseline = Measurement)

## KW test for baseline differences
kwTest <- baseline %>%
  left_join(demographics) %>%
  group_by(Biomarker) %>%
  do(tidy(kruskal.test(x = .$Baseline, g = .$TRTP)))
##

biomarkers_long <- biomarkers_long %>% left_join(baseline) %>%
  na.omit() %>%
  mutate(`CFB (ng/mL)` = Measurement - Baseline)

summary <- biomarkers_long %>% 
  group_by(Biomarker, Timepoint, TRTP) %>%
  summarize(mean = mean(Measurement), se = sd(Measurement)/sqrt(n()), 
            median = median(Measurement), sd = sd(Measurement)) #%>%
  #spread(Timepoint, median) %>%
  #select(Treatment = TRTP, Biomarker, Baseline, `Week 4`, `Week 26`)

summaryCFB <- biomarkers_long %>%
  filter(Timepoint == "Week 26") %>%
  group_by(Biomarker, TRTP) %>%
  summarize(meanCFB = mean(`CFB (ng/mL)`), seCFB = sd(`CFB (ng/mL)`)/sqrt(n()))

pdf("meanCFB_week26.pdf",width=16, height=8)
ggplot(summaryCFB, aes(x=TRTP, y=meanCFB)) + 
  geom_point() + 
  geom_errorbar(aes(ymin=meanCFB-seCFB,ymax=meanCFB+seCFB), width = 0.2, position = position_dodge(0.9)) + 
  facet_wrap(~Biomarker, ncol=9, scales = "free") + 
  ylab("Week 26 mean CFB +/- SEM") + 
  myTheme
dev.off()

write.table(summary, file = "eTable1-extension.txt", append = F, quote = F, 
            sep = "\t", row.names = F)
write.table(summaryCFB, file = "CFB_interpretation.txt", append = F, quote = F, 
            sep = "\t", row.names = F)

corBaselineCFB <- biomarkers_long %>% 
  filter(Timepoint != "Baseline")
ggplot(corBaselineCFB, aes(x=Baseline, y = `CFB (ng/mL)`, color = TRTP)) + 
  geom_point() + 
  facet_wrap(~Biomarker, ncol = 5, scales = "free") + 
  myTheme

