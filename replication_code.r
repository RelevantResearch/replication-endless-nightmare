# Replication of pages 9-18 of the "Endless Nightmare" Report
# Published 2024-02-06
# Accessed at https://phr.org/our-work/resources/endless-nightmare-solitary-confinement-in-us-immigration-detention/
library(tidyverse)
library(janitor)
library(readxl)
library(stringi)
library(openxlsx)

# Read in Segregation Review Management System (SRMS) table received by researchers via FOIA request
df <- read_excel('./SRMS spreadsheet 9.1.2018 - 9.1.2023 Redacted.xlsx')

# Read in ICE data summarized from quarterly reports
ice <- read_excel('./2022_2023_ICE_quarterly_confinement_vulnerable.xlsx', sheet = 5)

## replicate table and graphics 2 and 3 from "Endless Nightmare" report

fig2 <- df |>
  filter(`Tracking Number` != "") |>#Filter out cases that have no tracking number 
  filter(!is.na(`Release Date`)) |> #Filter out cases with no release date
  mutate(`Mental Illness` = ifelse(`Mental Illness` == "Yes", #Standardize Mental Illness field
                                   "Mental Illness", `Mental Illness`))|>
  mutate(Facility = ifelse(Facility == "WEBB COUNTY DETENTION CENTER (TX)", #Standardize facility field
                           "WEBB COUNTY DETENTION CENTER (CCA) (TX)", Facility)) |>
  filter(`Detainee Request Segregation` == "Facility-Initiated")

## Add column indicating source of ICE data
ice_nums <- ice |>
  mutate(source = "ICE_public")


# add month-year
fig2 <- fig2 |>
  mutate(placement_year = year(as.Date(`Placement Date`)),
         placement_fyq = quarter(as.Date(`Placement Date`), type="year.quarter",fiscal_start = 10))

#subset of vulnerable placements. Replication here does not create separate bin column
fig2_vuln <- fig2 |>
  mutate(vulnerable = case_when(`Mental Illness` == "Mental Illness" ~ 1,
                                `Mental Illness` == "Serious Mental Illness" ~ 1,
                                `Serious Medical Illness` == "Yes" ~ 1,
                                `Serious Disability` == "Yes" ~ 1,
                                `Placement Reason` == "Protective Custody: Lesbian, Gay, Bisexual, Transgender (LGBT)" ~ 1,
                                `Placement Reason` == "Protective Custody: Victim of Sexual Assault" ~ 1,
                                `Placement Reason` == "Hunger Strike" ~ 1,
                                `Placement Reason` == "Suicide Risk Placement" ~ 1,
                                `Suicide Risk?` == "Suicide Risk"~1,
                                .default = 0)) |>
  filter(vulnerable==1)

#summarize foia dataset by quarter and filter only fy2022-fy2023q3
all_vuln_fyq <- fig2_vuln |>
  group_by(placement_fyq)|>
  summarize(Placement_FOIA = n(),
            Length_FOIA = mean(`Length of Stay`)) |>
  filter(placement_fyq >= 2022.1)|>
  mutate(placement_fyq = case_when(placement_fyq == 2022.1 ~ "2022q1", ## Change numeric to character
                                   placement_fyq == 2022.2 ~ "2022q2",
                                   placement_fyq == 2022.3 ~ "2022q3",
                                   placement_fyq == 2022.4 ~ "2022q4",
                                   placement_fyq == 2023.1 ~ "2023q1",
                                   placement_fyq == 2023.2 ~ "2023q2",
                                   placement_fyq == 2023.3 ~ "2023q3",
                                   placement_fyq == 2023.4 ~ "2023q4"),
         source = "FOIA")


#Merge FOIA and ICE-related data
combined <- all_vuln_fyq |> 
  left_join(ice_nums, by=c("placement_fyq"="PlacementQ")) |>
  filter(!is.na(Placement_ICE)) 

#Write
#write.csv(combined, "rep_fig2-3.csv", row.names = FALSE)


#####Visualization

#Convert placement number data to long format
fig2_data <- combined |>
  select(c(placement_fyq, Placement_FOIA, Placement_ICE)) |>
  pivot_longer(!placement_fyq, names_to = "Source", values_to = "Placements")

#Factor Source to bring proper order to visualization
fig2_data$Source <- factor(fig2_data$Source, levels = c("Placement_ICE", "Placement_FOIA"))

write.csv(fig2_data, "fig2_data.csv", row.names = FALSE)
#Convert length of solitary confinement data to long format
fig3_data <- combined |>
  select(c(placement_fyq, Length_FOIA, Length_ICE))|>
  pivot_longer(!placement_fyq, names_to = "Source", values_to = "Mean Length")

#Factor Source to bring proper order to visualization
fig3_data$Source <- factor(fig3_data$Source, levels = c("Length_ICE", "Length_FOIA"))

write.csv(fig3_data, "fig3_data.csv", row.names = FALSE)

#Visualize placement numbers
fig2_plot <- fig2_data |>
  ggplot(aes(x=placement_fyq, y=Placements, group = Source, color = Source))+
  geom_line() +
  labs(title = "Replication of Figure 2 in the 'Endless Nightmare' Report",
       subtitle = "Number of Solitary Confinement Placements for Immigrants with Vulnerabilities",
       x = "",
       y = "")+
  scale_color_manual(labels = c("ICE Quarterly Placements", "SRMS FOIA Placements"), 
                     values = c("red", "orange"))+
  scale_y_continuous(limits = c(100, 425))+
  theme_classic() +
  theme(legend.title= element_blank())
fig2_plot

ggsave('rep_fig2.png')

#Visualize length of confinement average
fig3_plot <- fig3_data |>
  ggplot(aes(x=placement_fyq, y=`Mean Length`, group = Source, color = Source))+
  geom_line() +
  labs(title = "Replication of Figure 3 in the 'Endless Nightmare' Report",
       subtitle = "Length of Solitary Confinement for Immigrants with Vulnerabilities",
       x = "",
       y = "Days")+
  
  scale_color_manual(labels = c("ICE Quarterly Placements", "SRMS FOIA Placements"), 
                     values = c("red", "orange"))+
  scale_y_continuous(limits = c(5, 22))+
  theme_classic()+
  theme(legend.title= element_blank())
fig3_plot

ggsave('rep_fig3.png')

# Replicating page 16-18 from "Eternal Nightmare" and graphics 4 and 6
# start over with original dataset and clean variables
df <- df |>
  filter(`Tracking Number` != "") |>#Filter out cases that have no tracking number 
  mutate(`Mental Illness` = ifelse(`Mental Illness` == "Yes", #Standardize Mental Illness field
                                   "Mental Illness", `Mental Illness`))|>
  mutate(Facility = ifelse(Facility == "WEBB COUNTY DETENTION CENTER (TX)", #Standardize facility field
                           "WEBB COUNTY DETENTION CENTER (CCA) (TX)", Facility))

#find mean/median length of stay. Pg. 14: 
# "These placements lasted 27 days on average, well in excess of the 15-day period 
# "that constitutes torture, as defined by the Special Rapporteur on Torture. 
# Indeed, with a median length of confinement of 15 days"
summarize_length <- df |>
  filter(!is.na(`Release Date`))|> #Remove any instances where there are no release dates
  summarize(count = n(),
            mean_length = mean(`Length of Stay`), #26.6 days
            median_length = median(`Length of Stay`)) #15 days

#Pg. 14.
length_90 <-df |> #Determine number of instances when a detainee had a mental illness and had a stay > 90 days
  filter(`Tracking Number` != "") |>#Filter out cases that have no tracking number 
  filter(!is.na(`Release Date`))|>
  filter(`Length of Stay` >= 90) |> #682 solitary confinement placements > 90 days
  group_by(`Mental Illness`)|>
  count() # (140 mental illness + 53 serious mental illness) / 682 = 28.3% (almost 30 percent had mental health condition)

#Pg. 14.
length_365 <-df |> #Determine number of instances when a detainee had a mental illness and had a stay > 365 days
  filter(`Tracking Number` != "") |>#Filter out cases that have no tracking number 
  filter(!is.na(`Release Date`))|>
  filter(`Length of Stay` > 365) |> #42 detainees
  group_by(`Mental Illness`)|>
  count() # (8 mental illness + 2 serious mental illness) / 42 = 23.8% (~almost 25 percent had mental health condition)

## Sort facilities by longest length of stay and average length of stay
longest_stays <- df |>
  filter(!is.na(`Release Date`))|>
  group_by(Facility, `Length of Stay`)|>
  count() |>
  arrange(desc(`Length of Stay`)) #Denver Contract - 727 days; Otay Mesa 759/567 Days, etc...

## Average Stay by Facility
average_staysxfacility <- df |>
  filter(!is.na(`Release Date`))|>
  group_by(Facility) |>
  summarise(mean_stay = mean(`Length of Stay`)) |>
  arrange(desc(mean_stay)) #Northwest ICE average length is 55 days (Tacoma); Denver-52 days.


## Year by year placements

#month-year
time <- df |>
  mutate(placement_year = year(as.Date(`Placement Date`)),
         placement_month = month(as.Date(`Placement Date`)),
         placement_fyq = quarter(as.Date(`Placement Date`), type="year.quarter",fiscal_start = 10),
         release_year = year(as.Date(`Release Date`)))

yearly <- time |>
  group_by(placement_year)|>
  count() #"As of September 2023, there were already 2,301 reported placements." 
          # projection (2301/8 months)*12 = 3452 placements
          # Peak number of placements in 2020
 
monthly <- time |>
  group_by(placement_year, placement_month)|>
  count() # Lowest number of placements in mid/late-2021

release_date <- time |>
  filter(!is.na(`Release Date`))|>
  group_by(release_year)|>
  summarise(mean_length = mean(`Length of Stay`))   # Average length above 15 days each of past five years
                                                    # Average was 23 days in 2023 as of Sept 2023

no_release_date <- time |>
  filter(is.na(`Release Date`))|>
  group_by(release_year)|>
  summarise(mean_length = mean(`Length of Stay`)) 
# For those without a release date, average length is 65 days 

## Pg. 15
###Proportion of solitary per 10k detained
det <- read_excel("2019_2023_daily_detention_confinement.xlsx", sheet = 'combined')

##Plot graphic 4
detplot <- det |>
  ggplot(aes(x=YearMonth, y=confinement_prop))+
  geom_line(color = "orange") +
  labs(title = "Replication of Figure 4 in the 'Endless Nightmare' Report",
       subtitle = "Number of Immigrants Held in Solitary Confinement out of Total Population in Detention",
       x="",
       y="")+
  scale_y_continuous(limits = c(0,200))+
  theme_classic()
detplot

ggsave("rep_fig4.png")

# Page 16

#clean variables
df <- df |>
  filter(`Tracking Number` != "") |>#Filter out cases that have no tracking number 
  mutate(`Mental Illness` = ifelse(`Mental Illness` == "Yes", #Standardize Mental Illness field
                                   "Mental Illness", `Mental Illness`))|>
  mutate(Facility = ifelse(Facility == "WEBB COUNTY DETENTION CENTER (TX)", #Standardize facility field
                           "WEBB COUNTY DETENTION CENTER (CCA) (TX)", Facility))

### Graphic 6

time <- df |>
  filter(!is.na(`Release Date`))|>
  mutate(placement_year = year(as.Date(`Placement Date`)),
         placement_fyq = quarter(as.Date(`Placement Date`), type="year.quarter",fiscal_start = 10),
         release_year = year(as.Date(`Release Date`)))

avg_length <- time |>
  group_by(release_year) |>
  summarize(mean_length = mean(`Length of Stay`)) |>
  filter(release_year >= 2019) |>
  mutate(UN_Def = 15) |>
  pivot_longer(!release_year, names_to = "Length of Stay", values_to = "Days")

#write.csv(avg_length, "fig6_data.csv", row.names = FALSE)

### Graphic 6
fig6 <- avg_length |>
  ggplot(aes(x=release_year, y=Days))+
  geom_line(aes(color = `Length of Stay`), size=2)+
  scale_color_manual(values = c("red", "purple"),
                     labels=c("Average Number of Days \n in Solitary Confinement", 
                              "UN Definition \n of Torture"))+
  labs(title = "Replication of Figure 6 in the 'Endless Nightmare'' Report",
       subtitle = "Average Number of Days in Solitary Confinement",
       x = "",
       y = "")+
  scale_y_continuous(limits = c(0, 35), breaks = seq(0,35,5))+
  theme_classic()+
  theme(legend.title = element_blank(),
        legend.spacing.y = unit(1, 'cm'))+
  guides(color = guide_legend(byrow = TRUE))
fig6  

ggsave("rep_fig6.png")

# LGBT statistic
lgbt <- df |>
  filter(`Placement Reason` == "Protective Custody: Lesbian, Gay, Bisexual, Transgender (LGBT)")


lgbt_fyq <- lgbt |>
  mutate(placement_fyq = quarter(as.Date(`Placement Date`), type="year.quarter",fiscal_start = 10))|>
  group_by(placement_fyq)|>
  count() |>
  adorn_totals(c('row')) # 62 detainees placed in confinement

summary(lgbt$`Length of Stay`) ## Protective Custody for LGBT detainees: Mean 57 days; median 34; max 286 days

##Pg 17
df <- df |>
  filter(`Tracking Number` != "") |>#Filter out cases that have no tracking number 
  mutate(`Mental Illness` = ifelse(`Mental Illness` == "Yes", #Standardize Mental Illness field
                                   "Mental Illness", `Mental Illness`))|>
  mutate(Facility = ifelse(Facility == "WEBB COUNTY DETENTION CENTER (TX)", #Standardize facility field
                           "WEBB COUNTY DETENTION CENTER (CCA) (TX)", Facility))

mental_illness <- df |>  # 8,787 records (Discrepancy. Off by one record); 2882+642/8787=40.1%
  group_by(`Mental Illness`)|> 
  filter(!is.na(`Mental Illness`))|>
  count() |>
  adorn_totals("row")
# Over 40 percent had documented mental health conditions

mental_illnes_nacount <- df |> #(5477/14264=38.4% NAs) 
  group_by(`Mental Illness`)|> 
  count() |>
  adorn_totals("row")
# "ICE reported immigrants' mental health in only 62 percent of total solitary confinement records.

mental_year <- df |>
  mutate(placement_year = year(as.Date(`Placement Date`)))|>
  group_by(`Mental Illness`, placement_year) |>
  count()

mental_19 <- df |> ## 2019 : Mental Illness = 26.6% + Serious Illness = 6.7% == 33.3% (Discrepancy. Off by 2 percentage points)
  mutate(placement_year = year(as.Date(`Placement Date`)))|> # "Jumped from 35 percent in 2019 to 56 percent in 2023"
  filter(placement_year == "2019") |>
  group_by(`Mental Illness`, placement_year) |>
  count() |>
  ungroup()|>
  filter(!is.na(`Mental Illness`))|>
  mutate(total = sum(n), 
         pct = n/total)

mental_23 <- df |> ## 2023 : Mental Illness = 41.0% + Serious Illness = 15.2% == 56.2%
  mutate(placement_year = year(as.Date(`Placement Date`)))|>
  filter(placement_year == "2023") |>
  group_by(`Mental Illness`, placement_year) |>
  count() |>
  ungroup()|>
  filter(!is.na(`Mental Illness`))|>
  mutate(total = sum(n), 
         pct = n/total)

serious_mental_19 <- df |> ## 2019 : Serious Mental Illness is 20.0% of all with mental illness
  mutate(placement_year = year(as.Date(`Placement Date`)))|>
  filter(placement_year == "2019") |>
  filter(`Mental Illness` == "Mental Illness" | `Mental Illness` == "Serious Mental Illness") |>
  group_by(`Mental Illness`, placement_year) |>
  count() |>
  ungroup()|>
  filter(!is.na(`Mental Illness`))|>
  mutate(total = sum(n), 
         pct = n/total)

serious_mental_23 <- df |> ## 2023 : Mental Illness = 27.0%
  mutate(placement_year = year(as.Date(`Placement Date`)))|>
  filter(placement_year == "2023") |>
  filter(`Mental Illness` == "Mental Illness" | `Mental Illness` == "Serious Mental Illness") |>
  group_by(`Mental Illness`, placement_year) |>
  count() |>
  ungroup()|>
  filter(!is.na(`Mental Illness`))|>
  mutate(total = sum(n), 
         pct = n/total)
# 20 percent mental illnesses in 2019, 27 percent in 2023


## Mental Illness length of stay
mental_illness_length <- df |> ## Mental Illness 23.4 days; Serious # 34.4 days
  mutate(placement_year = year(as.Date(`Placement Date`)))|>
  group_by(`Mental Illness`)|>
  summarize(mean_length = mean(`Length of Stay`))

##Facilities length of stay by mental illness
mental_illness_facility <- df |>
  filter(`Mental Illness` == "Mental Illness" | `Mental Illness` == "Serious Mental Illness") |>
  group_by(Facility)|>
  summarize(mean_length = mean(`Length of Stay`))|>
  arrange(desc(mean_length))
#Richwood, Denver, Yuba, Otay Mesa, Henderson all ranged between 3 months (90 days) - 6 months (180 days)

## Figure 7 on page 18
mental_year <- df |>
  mutate(release_year = year(as.Date(`Release Date`)))|>
  mutate(mental_ill_bin = ifelse(`Mental Illness` == "Mental Illness" | 
                                   `Mental Illness` == "Serious Mental Illness", "Mental Illness", "No Mental Illness"))|>
  group_by(mental_ill_bin, release_year) |>
  count()

fig7 <- mental_year |>
  filter(!is.na(mental_ill_bin))|>
  filter(release_year > 2018)
write.csv(fig7, "fig7_data.csv", row.names = FALSE)

fig7 <- mental_year |>
  filter(!is.na(mental_ill_bin))|>
  filter(release_year > 2018)|>
  ggplot(aes(x=release_year, y = n, fill=mental_ill_bin))+
  geom_bar(position = "fill", stat="identity")+
  scale_fill_manual(values = c("Mental Illness" = "#FB4F14", 
                               "No Mental Illness" = "#002244"))+
  scale_y_continuous(labels = scales::label_percent())+
  labs(title = "Replication of Figure 7 in the 'Endless Nightmare' Report",
       subtitle = "Percent in Solitary Confinement With Mental Illness",
       x="",
       y="Percent")+
  annotate("text", x = 2019, y = 0.85, label = "35", color = 'white',
           size = 10, parse = TRUE) +
  annotate("text", x = 2020, y = 0.85, label = "33", color = 'white',
           size = 10, parse = TRUE) +
  annotate("text", x = 2021, y = 0.85, label = "44", color = 'white',
           size = 10, parse = TRUE) +
  annotate("text", x = 2022, y = 0.85, label = "55", color = 'white',
           size = 10, parse = TRUE) +
  annotate("text", x = 2023, y = 0.85, label = "56", color = 'white',
           size = 10, parse = TRUE) +
  theme_classic() +
  theme(legend.title = element_blank())
fig7

ggsave("rep_fig7.png")

