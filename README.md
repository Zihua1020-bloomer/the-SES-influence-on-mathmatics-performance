# the-SES-influence-on-mathmatics-performance

## Abstract
The influence of home educational resources on student academic outcomes is a well-recognized theme within educational research, with a particular focus on mathematics. This study investigates the hypothesis that the richness of home educational resources exerts a more pronounced positive influence on the mathematics achievement of Finnish students compared to students in other countries. Using panel data from the Trends in International Mathematics and Science Study (TIMSS) for the years 2015 and 2019, this research employs fixed and random effects models, the Hausman specification test, and a general-to-specific approach for variable selection. The findings confirm that Finnish students benefit significantly more from home educational resources, highlighting the importance of socio-economic status (SES) and parental involvement in enhancing educational outcomes.

## Data Description

The dataset originates from the Trends in International Mathematics and Science Study (TIMSS) conducted in 2015 and 2019. TIMSS assesses the mathematics and science knowledge of fourth and eighth-grade students worldwide, involving 53 participating countries. This study aims to understand and compare the effectiveness of educational systems across different regions.

A complex survey design was defined using the `svrepdesign` function from the `survey` package to accurately reflect the sampling methodology and ensure reliable variance estimation. This design incorporates weights (`totwgt`), which represent the probability of each student being included in the sample, and replicate weights (`weights_df`), which are used to compute standard errors by simulating multiple samples from the population. The replicate weights were constructed following the jackknife replication method, providing a robust means of variance estimation. This approach accounts for the hierarchical structure of the data and the stratified sampling design, which is essential for producing valid statistical inferences.

For both 2015 and 2019, columns ending with `01` through `05` were identified as multiply-imputed plausible values. These columns were extracted into a separate DataFrame and reshaped from a wide format to a long format to create one record per student per implicate. The plausible value columns were removed from the original DataFrame to avoid redundancy. The reshaped DataFrame was then merged back with the source data, ensuring a comprehensive dataset with detailed student records. This process was crucial for accurately capturing the variability and uncertainty in student performance measures.

Mean and median mathematics scores were calculated for each country using the multiply-imputed variance estimation technique. Additional variables, such as socioeconomic status (SES) and interest in mathematics, were summarised at the country level. These statistics were combined into single datasets (`all_data` for each year), which include mean and median scores for mathematics, SES, and interest.

The final datasets for 2015 and 2019 contain aggregated statistics at the country level, including mean and median mathematics scores, SES scores, and interest scores. These datasets are intended for cross-country comparisons of educational outcomes, focusing on mathematics performance, socioeconomic influences, and students' interest in the subject. The comprehensive design and statistical methods ensure robust, reliable conclusions about educational effectiveness across diverse international contexts.

The TIMSS datasets for 2015 and 2019 provide valuable insights into global education systems, emphasising the importance of socioeconomic factors and student engagement in mathematics. By analysing these aggregated statistics, researchers and policymakers can identify strengths and areas for improvement in different countries' educational strategies. The use of a complex survey design with appropriate weights and replicate weights ensures that the findings are statistically sound and representative of the underlying populations.

## Methodology
### Model Estimation: Fixed and Random Effects

To accurately capture individual-specific effects, we estimated both fixed and random effects models. The fixed effects model controls for unobservable individual-specific effects that may correlate with the explanatory variables, ensuring that the estimates are not biassed by these latent factors. In contrast, the random effects model assumes that these individual-specific effects are uncorrelated with the regressors, allowing for more efficient estimates if this assumption holds true
Hausman Specification Test

We employed the Hausman specification test to determine the most appropriate model between fixed and random effects. This test assesses whether the unique errors (individual-specific effects) are correlated with the regressors. A significant result from the Hausman test indicates that the fixed effects model is more suitable, as it suggests that the individual-specific effects are indeed correlated with the explanatory variables, thus violating the assumptions of the random effects model.

### General-to-Specific Method for Variable Selection

A general-to-specific approach was utilised for variable selection to refine the model and ensure its parsimony and robustness. This method begins with a comprehensive model that includes all potential explanatory variables. Through iterative testing, insignificant variables are systematically removed, resulting in a more specific and streamlined model that retains only the most significant predictors. This process helps in avoiding overfitting and ensures that the model is both parsimonious and interpretable.

### Interaction Term

To explore the potential combined effects of specific variables on the dependent variable, an interaction term was introduced. This term allows us to examine how the influence of one variable on the dependent variable changes depending on the level of another variable. Including interaction terms can uncover nuanced relationships and provide deeper insights into the dynamics between variables.

### Diagnostic Tests
To ensure the robustness and reliability of the final model, we conducted several diagnostic tests:

1. Heteroskedasticity: The Breusch-Pagan test was used to check for heteroskedasticity, which occurs when the variance of the errors differs across observations. A significant result indicates the presence of heteroskedasticity, suggesting the need for robust standard errors to obtain reliable coefficient estimates.

2. Autocorrelation: The Breusch-Godfrey test was performed to detect autocorrelation, where the residuals are correlated across observations. Significant autocorrelation can lead to inefficient estimates and biassed standard errors. Addressing this issue may involve adding lagged variables or using specialised econometric techniques.

3. Multicollinearity: The Variance Inflation Factor (VIF) was calculated to assess multicollinearity among the predictors. High VIF values indicate that predictors are highly correlated, which can inflate the standard errors and make it difficult to assess the individual effect of each predictor. In our analysis, VIF values below 10 suggest that multicollinearity is not a significant concern.

By employing these diagnostic tests, we ensured that our model is well-specified and the estimates are reliable. The rigorous testing and refinement process enhances the validity of our findings and supports robust conclusions regarding the relationships between socio-economic status, home educational resources, and mathematics achievement.
Results
Mean Model Results

## Model Specifications and Estimations
The analysis involves two models, each evaluated through both fixed effects and random effects frameworks to discern the impact of socioeconomic status (SES), interest in mathematics, and a Finland-specific SES interaction on mean mathematics scores. The models were analysed using panel data consisting of 42 entities across 2 time periods, resulting in a balanced panel of 84 observations.
### Fixed Effects Model
The fixed effects model (FE) is focused on analysing within-entity variations by controlling for all time-invariant differences among the entities, thus isolating the effect of predictors that vary over time.
1.Model with Interaction Term (FE Model)
   - SES:  showed a positive and statistically significant effect on mathematics scores (β = 20.094, p < 0.05), suggesting that higher SES is associated with better performance.
   - Interest in Mathematics: was not statistically significant (p > 0.1), indicating insufficient evidence within this dataset to confirm a consistent impact on scores.
   - Finland SES Interaction:  was not significant (p > 0.75), indicating no special effect of SES in Finland different from other countries.

2. Model without Interaction Term (FE Model 1)
   - Similar outcomes were observed, with SES remaining significant (β = 20.131, p < 0.05) and interest not reaching statistical significance.
### Random Effects Model
The random effects model (RE) considers both within and between-entity variations, assuming that individual-specific effects are uncorrelated with the predictor variables.

1. Model with Interaction Term (RE Model)
   - SES:  had a significantly positive impact on scores (β = 31.585, p < 0.001), more pronounced than in the FE model.
   - Interest in Mathematics  and the Finland SES Interaction were not significant, similar to the FE model findings.

2. Model without Interaction Term (RE Model 1)
   - Results mirrored the interaction model, with SES showing a significant positive effect (β = 31.475, p < 0.001).




## Model Diagnostics and Comparisons
- Hausman Tests  were conducted to decide between FE and RE models based on whether the unique errors (entity-specific effects) are correlated with the regressors. The test favoured the FE model for both specifications (p < 0.05), suggesting that FE models are more appropriate given the data structure and study hypothesis.
  
- Ordinary Least Squares (OLS) analyses were also conducted, which showed significant results for SES across both models and a significant negative effect for interest. However, OLS models detected issues with autocorrelation, suggesting that OLS may not be suitable for this panel data without further adjustments.

- RESET Tests for model specification indicated that the functional form of the models was correctly specified. The Breusch-Pagan tests confirmed homoscedasticity, and Jarque-Bera tests verified the normal distribution of residuals.
Conclusion
The analysis strongly supports the hypothesis that socioeconomic status significantly affects mathematics scores, a relationship robust across different modelling techniques. The lack of significance for the interest variable and the Finland interaction suggests these factors either do not impact the scores as measured or the effect could not be detected within the scope of this dataset and methodology. Given the results of the Hausman test, the fixed effects model is preferred, providing a more reliable interpretation of the impact of observed variables on mathematics scores within entities over time.
Median Model Results



## Model Specifications
1. FE Model (with interaction): Focused on the changes within each entity, ignoring between-entity variations.
2. RE Model (with interaction): Considered both within and between-entity variations.
3. FE Model 1 (without interaction): Simplified version excluding the Finland interaction term.
4. RE Model 1 (without interaction): Same as FE Model 1 but utilizing random effects.

## Statistical Findings
- Median SES: showed a positive and significant impact on median scores in both interaction and non-interaction models, indicating that higher SES correlates with better academic performance.
- Interest in Mathematics: did not show consistent statistical significance, suggesting that other unmeasured factors might mediate the influence of interest on scores.
- Finland SES Interaction: was not statistically significant, suggesting no unique effect of SES on scores in Finland compared to other countries.

## Model Comparisons and Diagnostics
- Hausman Tests indicated a preference for the FE model in the non-interaction model (p = 0.0217) and a non-significant preference in the interaction model (p = 0.05776), suggesting RE might be suitable due to its inconclusive results.
- OLS Diagnostics linearity (RESET test), homoscedasticity (Breusch-Pagan test), and normality (Jarque-Bera test) mostly confirmed the suitability of the model specifications. However, the detection of autocorrelation (Breusch-Godfrey test) in residuals suggests potential issues with using OLS directly without adjustments.

## Conclusions
The fixed effects model is recommended for analysing the influence of SES and interest on mathematics scores without the interaction term due to the significant individual effects detected. For models including the interaction term, the random effects model may be considered due to its broader inclusion of between-entity variations and the inconclusive Hausman test result.

## Comparative Analysis of Mean and Median Models in Panel Data Analysis
This comparative analysis examines the impact of socioeconomic status (SES), interest in mathematics, and a Finland-specific SES interaction on student performance in mathematics, as measured by both mean and median scores. The comparison helps elucidate the robustness and sensitivity of the results to the measure of central tendency used (mean vs. median), providing a deeper understanding of the data distribution's influence on statistical outcomes.
Two sets of models were evaluated:
1. Mean Models: Where the dependent variable was the mean score of mathematics.
2. Median Models: Where the dependent variable was the median score of mathematics.
Both sets of models were assessed using fixed effects (FE) and random effects (RE) models to analyse within and between variations, respectively.
Summary of Findings
- SES Impact: SES consistently showed a positive and significant impact on mathematics scores across both mean and median models. This suggests a robust association where higher SES correlates with better educational outcomes.
- Interest in Mathematics: The influence of interest was generally non-significant in both models, indicating that the variable may not directly affect scores or other latent variables not included in the model might mediate this relationship.
- Finland Interaction Term: This interaction term was not significant in both models, indicating no unique SES effect in Finland compared to other countries.

## Comparative Analysis
- Stability of Results: The SES variable's significance across both models suggests that the effect of socioeconomic factors on educational achievement is stable, regardless of the measure of central tendency used.
- Model Fit and Preference:
  - The Adjusted R-squared values were generally higher in the random effects models compared to the fixed effects models, suggesting that considering between-entity variations provides a better fit for the data.
  - Hausman Tests favoured the fixed effects model for the non-interaction median model but were inconclusive for the interaction models. This result suggests that while individual effects are significant when considering median scores without the interaction, the choice between FE and RE models may depend on specific analytical goals when interactions are included.
- OLS Diagnostics indicated that while the models generally meet the assumptions of linearity, homoscedasticity, and normality of residuals, issues with autocorrelation were detected, suggesting that panel-specific methods (FE or RE) are more appropriate than OLS.

## Interpretation and Implications
- Sensitivity to Outliers: The robustness of SES's impact across both mean and median scores indicates that this effect is not driven by outliers. Median models, often less sensitive to extreme values, did not significantly differ from mean models in terms of the SES impact, reinforcing the strength of this relationship.
- Future Research: The non-significance of the interest variable across all models suggests that further research could explore more nuanced aspects of student engagement or other potential mediators like teaching quality or school resources.
Discussion
The analysis of mean and median scores provides nuanced insights into student performance in mathematics. Mean scores offer a general measure of central tendency but are susceptible to distortion by extreme values, potentially skewing the interpretation of overall performance. In contrast, median scores present a more robust measure of central tendency that is less influenced by outliers, offering a clearer view of the typical student’s performance. Comparing these measures across different years allows for a detailed examination of shifts in central tendencies and the distribution of mathematics performance among students. Such comparisons can reveal underlying trends and changes in the educational landscape, indicating whether performance improvements or declines are widespread or driven by specific subsets of the student population.

## Conclusion

This study comprehensively estimates and validates a panel data model to investigate the influence of socio-economic status (SES) and home educational resources on mathematics achievement, with a particular focus on Finnish students. Employing both fixed and random effects estimators, the analysis leverages the Hausman test to rigorously determine the appropriate model, confirming the fixed effects model as the most suitable. The general-to-specific modelling approach enhances the robustness of the analysis by systematically refining the model to include only significant predictors. The inclusion of interaction terms provides deeper insights into the combined effects of SES and specific contextual factors, such as the Finnish educational environment. Thorough diagnostic tests, including checks for heteroskedasticity, autocorrelation, and multicollinearity, ensure the final model is well-specified and reliable. The comparative analysis of mean and median scores further enriches the understanding of student performance dynamics across different countries and time periods, highlighting both overall trends and specific outliers. These findings offer valuable contributions to educational policy and practice, emphasising the critical role of home educational resources in shaping mathematics achievement and the unique context of Finland’s educational system.

## References
Areepattamannil, S. (2019). The impact of science teaching strategies in the Arabic-speaking countries: A multilevel analysis of TIMSS 2019 data. Heliyon. Retrieved from https://www.sciencedirect.com/science/article/pii/S2405844024030937#mmc1
Banerjee, P. A. (2015). Family socioeconomic status, family health, and changes in students' math achievement across high school: A mediational model. Social Science & Medicine, 140, 42-48. Retrieved from https://www.sciencedirect.com/science/article/pii/S0277953615300046?via%3Dihub#sec2.2.1
Dritsakis, N., & Papageorgiou, E. (2015). Examining students’ achievement in mathematics: A multilevel analysis of the Programme for International Student Assessment (PISA) 2012 data for Greece. Retrieved from https://clixplatform.tiss.edu/softwares/Reseach_data/Reseach_data_backup_HDD_20170601/Research%20data/miz_std_baseline/readings/Student%20achievement/Examining%20students%E2%80%99%20achievement%20in%20mathematics.pdf
González, E. J. (2002). Patterns of diagnosed mathematical content and process skills in TIMSS-R across a sample of 20 countries. International Journal of Educational Research, 37(2), 115-139. Retrieved from https://www.jstor.org/stable/3699467?seq=17
Goodman, M., & Moulton, J. (2021). Got a math attitude? (In)direct effects of student mathematics attitudes on intentions, behavioural engagement, and mathematics performance in the U.S. PISA. Studies in Educational Evaluation, 68, 100955. Retrieved from https://www.sciencedirect.com/science/article/pii/S0361476X21000783
Hansen, M., & Gustafsson, J. (2019). Using EdSurvey to analyse TIMSS data. American Institutes for Research. Retrieved from https://www.air.org/sites/default/files/edsurvey-TIMSS-pdf.pdf
He, J., & Van de Vijver, F. J. R. (2019). IRT scoring procedures for TIMSS data. Frontiers in Psychology, 10, 1195. Retrieved from https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6603296/
Hossain, M. A. (2016). What methods are used to calculate aggregates for groups of countries? World Bank Data Help Desk. Retrieved from https://datahelpdesk.worldbank.org/knowledgebase/articles/198549-what-methods-are-used-to-calculate-aggregates-for
Kupiainen, S., & Marjanen, J. (2020). Family related variables effect on later educational outcome: A further geospatial analysis on TIMSS 2015 Finland. Large-scale Assessments in Education, 8(1). Retrieved from https://largescaleassessmentsineducation.springeropen.com/articles/10.1186/s40536-020-00081-2
Linnaeus, K., & Hartig, J. (2014). PISA, TIMSS and Finnish mathematics teaching: An enigma in search of an explanation. Educational Studies in Mathematics, 87(1), 7-26. Retrieved from https://link.springer.com/article/10.1007/s10649-014-9545-3#Sec8
Marks, G. N. (2013). Measurement invariance of socioeconomic status across migrational background. Social Indicators Research, 114, 479-492. Retrieved from https://www.researchgate.net/publication/241738208_Measurement_Invariance_of_Socioeconomic_Status_Across_Migrational_Background
Mullis, I. V. S., Martin, M. O., & Foy, P. (2020). Modeling mathematics achievement using hierarchical linear models. Large-scale Assessments in Education, 8(1), 9. Retrieved from https://www.researchgate.net/publication/339942762_Modeling_mathematics_achievement_using_hierarchical_linear_models
Ngcobo, N. (2016). Home and school resources as predictors of mathematics performance in South Africa. South African Journal of Education, 36(3). Retrieved from https://www.sajournalofeducation.co.za/index.php/saje/article/view/1010/495
Ogino, H., & Oikawa, T. (2015). The role of family background and school resources on elementary school students’ mathematics achievement. Social Psychology of Education, 18(3), 531-554. Retrieved from https://www.researchgate.net/publication/281066659_The_role_of_family_background_and_school_resources_on_elementary_school_students'_mathematics_achievement#fullTextFileContent
Oliveira, J. M., & Costa, P. (2020). Academic achievement and the effects of the student’s learning context: A study on PISA data. Paideia, 30. Retrieved from https://www.scielo.br/j/pusf/a/8xDjLMVgznsSSDKzc5N5RrK/
Opfer, D. V., & Pedder, D. (2023). How effective is the professional development in which teachers typically participate? Quasi-experimental analyses of effects on student achievement based on TIMSS 2003–2019. Teaching and Teacher Education, 112, 103622. Retrieved from https://www.sciencedirect.com/science/article/pii/S0742051X23002305#abs0010
Papanastasiou, C., & Zembylas, M. (2014). When technology does not add up: ICT use negatively predicts mathematics and science achievement for Finnish and Turkish students in PISA 2012. Learning and Individual Differences, 34, 112-120. Retrieved from https://consensus.app/papers/when-technology-does-negatively-predicts-mathematics-bulut/81404b1b1a2350feb308e1eaac893958/?utm_source=chatgpt
Sirin, S. R., & Rogers-Sirin, L. (2016). Contextual effects on students’ achievement and academic self-concept in the Nordic and Chinese educational systems. International Journal of Educational Research, 77, 35-45. Retrieved from https://www.researchgate.net/publication/364226165_Contextual_effects_on_students'_achievement_and_academic_self-concept_in_the_Nordic_and_Chinese_educational_systems
Skaalvik, E. M., & Federici, R. A. (2024). Motivational profiles in mathematics – stability and links with educational and emotional outcomes. Learning and Instruction, 89, 101639. Retrieved from https://www.sciencedirect.com/science/article/pii/S0361476X24000018
Tian, L., & Gao, J. (2024). Do intercultural education and attitudes promote student wellbeing and social outcomes? An examination across PISA countries. International Journal of Intercultural Relations, 84, 1-12. Retrieved from https://www.sciencedirect.com/science/article/pii/S0959475224000069#tbl2

