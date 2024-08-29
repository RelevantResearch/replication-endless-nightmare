# Relevant Research's Replication Study of Harvard University's "Endless Nightmare" Report

This repository is the result of Relevant Research's replication study of ["Endless Nightmare" (Ardalan et al., 2024)](https://phr.org/our-work/resources/endless-nightmare-solitary-confinement-in-us-immigration-detention/) published by students and faculty of the Harvard Immigration and Refugee Clinical Program (HIRCP) and Harvard Law School (HLS), members of the Peeler Immigration Lab (PIL) at Harvard Medical School (HMS), and Physicians for Human Rights (PHR).

### Summary

An interdisciplinary collaboration of lawyers, physicians, and social scientists from Harvard University published the report [“‘Endless Nightmare’: Torture and Inhuman Treatment in Solitary Confinement in U.S. Immigration Detention”]("https://phr.org/our-work/resources/endless-nightmare-solitary-confinement-in-us-immigration-detention/") in February 2024. 
The report was based on data obtained through Freedom of Information Act (FOIA) requests sent to Immigration and Customs Enforcement (ICE) related to the use of solitary confinement in U.S. immigration detention.
In keeping with best practices of transparent scholarship, the authors commendably made the underlying data for their project available online through a public repository on Harvard's Dataverse platform.
To demonstrate Relevant Research's approach to data analysis, we used the publicly-available data to replicate the 'Endless Nightmare' study.
Our process and findings are outlined briefly below, while all of our R code and replicated figures are available in this repository.

### Method and Tools

This replication study is limited in scope to the first part of the report, based specifically on a reproduction of the ICE solitary confinement data obtained from the Harvard team's FOIA requests.
The researchers presented their analysis on pages one through eighteen of their report, with figures two through four and five through seven constructed from summaries of the ICE dataset.
All in-text statistics, tables, and figures have been replicated here.
This replication does not include an analysis of the in-person interviews of former detainees that make up the rest of the report. 
Relevant Research's replication study was undertaken independently from the Harvard team.

Relevant Research relied on the Harvard study’s metadata (available on Dataverse) and conducted the replication study using R, rather than Stata, the programming language used by the original researchers – yet we arrived at the same results.
The method of analysis is described in further detail in the accompanying “how-to” document that covers how a general data science workflow can be applied when working with the specific opportunities and challenges that are presented by administrative data.

The Harvard team's original repository for their report can be found [on Dataverse here](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/AT7YFA) and their final report can be found [here](phr.org/our-work/resources/endless-nightmare-solitary-confinement-in-us-immigration-detention/).

### Data 

The dataset under analysis consists of 17,000 case-by-case records of solitary confinement stays between 2018 and 2023. ICE redacted five of the 23 fields under FOIA exemptions related to personal privacy (b)(6), law enforcement (b)(7)(e), or both. After removing the approximately 3,000 cases in which the release date is not entered, the number of stays over that time period aggregates to over 14,000 stays in solitary detention.

The research team appears to have done some minimal preliminary processing of the dataset before uploading it to the Harvard Dataverse repository. This included removing the header rows used by government agencies for FOIA response tracking and modifying the date fields to the preferred YYYY-MM-DD format.

### Output

Figures 2-4 and 6-7 can be seen below. Figure 5 was a replication of an ICE graph that did not require further reproduction. Underlying datasets are linked.
For in-text citations of data, the script `replication_code.r` contains the commented code to produce each statistic and the result.

Fig. 2
<img src=https://github.com/RelevantResearch/replication-endless-nightmare/blob/main/figures/orig_fig2.png width="310"><img src=https://github.com/RelevantResearch/replication-endless-nightmare/blob/main/figures/rep_fig2.png width="300">
Data [here](https://github.com/RelevantResearch/replication-endless-nightmare/blob/main/figure_data)

Fig. 3
<img src=https://github.com/RelevantResearch/replication-endless-nightmare/blob/main/figures/orig_fig3.png width="317"><img src=https://github.com/RelevantResearch/replication-endless-nightmare/blob/main/figures/rep_fig3.png width="300">
Data [here](https://github.com/RelevantResearch/replication-endless-nightmare/blob/main/figure_data)

Fig. 4
<img src=https://github.com/RelevantResearch/replication-endless-nightmare/blob/main/figures/orig_fig4.png width="325"><img src=https://github.com/RelevantResearch/replication-endless-nightmare/blob/main/figures/rep_fig4.png width="300">
Data [here](https://github.com/RelevantResearch/replication-endless-nightmare/blob/main/figure_data)

Fig. 6
<img src=https://github.com/RelevantResearch/replication-endless-nightmare/blob/main/figures/orig_fig6.png width="326"><img src=https://github.com/RelevantResearch/replication-endless-nightmare/blob/main/figures/rep_fig6.png width="350">
Data [here](https://github.com/RelevantResearch/replication-endless-nightmare/blob/main/figure_data)

Fig. 7
<img src=https://github.com/RelevantResearch/replication-endless-nightmare/blob/main/figures/orig_fig7.png width="300"><img src=https://github.com/RelevantResearch/replication-endless-nightmare/blob/main/figures/rep_fig7.png width="306">
Data [here](https://github.com/RelevantResearch/replication-endless-nightmare/blob/main/figure_data)

### Results
The vast majority of calculations using the FOIA case-by-case records are correct. 
See the replication file `replication_code.r`.
As seen above, graphics 2, 3, 4, 6, and 7 were successfully reproduced.

This replication identified three minor discrepancies, which illustrate Relevant Research's attention to detail.
Two of the three discrepancies are differences of a single whole number.
The third discrepancy is a percentage calculation that is two percentage points off in Relevant Research's code than the researchers. 
The three minor discrepancies are explained below.

#### Page 14

- **Original Text**: "682 solitary confinement placements lasted at least 90 days, while *42* lasted over a year."
- **RR's Replication**: A total of *43* solitary confinement placements lasted over one year.

#### Page 17

- **Original Text**: "Among the *8,788* records for this period where ICE’s SRMS reported the mental health status of immigrants in solitary confinement..."
- **RR's Replication**: There were *8,787* records which met those criteria.

#### Page 17

- **Original Text**: "The percentage of immigrants with mental health conditions placed in solitary confinement jumped from *35* percent in 2019 to 56 percent in 2023."
- **RR's Replication**: The percentage of immigrants with mental illness in 2019 came to *33.3* percent.

To reiterate, none of the discrepancies found here should assume that the research team committed errors in calculation.
This replication merely points out the minimal situations in which the calculations do not seem to align between the researchers processing in Stata and our analysis in R.
If any of the discrepancies do in fact rise to the level of error, it does not impact the findings of the report.
Solitary confinement in ICE detention remains a subject deserving of further scrutiny, and we applaud the research team for their persistence in documenting abuses and making their data, methods, and findings public.

### Conclusion

Relevant Research's replication study affirms the quality of the Harvard team's methodology and findings (we note only minimal discrepancies) and we make our results evident below.
We commend the interdisciplinary team for publishing structured descriptions of work in public repositories and encourage more researchers to do the same.
For questions or inquiries about how Relevant Research can provide data discovery (including through FOIA requests), data analysis, replication studies, data visualization, and data write-up, please email us at info@relevant-research.com.
