# ---- GROUP 9 - BUSINFO 703 (Q2-2025) ----
# PROJECT: New Zealand’s Vulnerable International Trade:
#          Mapping Trade Potential for a More Resilient Supply Chain

# ---- Group Members ----
# 1.Fitrianur Meilin Y (fyus697)
# 2.Haoyu Wang (hwan663)
# 3.Jiayu Wen (jwen381)
# 4.Thi Nga Doan (tdoa917)


# ---- 1.Introduction ----

## Applying unsupervised machine learning,to understand the New Zealand trade pattern
## based on trade volume, import share, and GDP per capital.

# ---- 2. Loading packages ----

# Install and load GGally (for advanced pairwise plots and diagnostics)
if (!require("GGally")) install.packages("GGally")
library(GGally)

# Install and load tidyverse (includes dplyr, ggplot2, readr, etc. for data manipulation and visualization)
if (!require("tidyverse")) install.packages("tidyverse")
library(tidyverse)

# Install and load corrplot (for visualizing correlation matrices)
if (!require("corrplot")) install.packages("corrplot")
library(corrplot) 

# Install and load ggplot2 (for custom visualizations — included in tidyverse, but loaded separately here for safety)
if (!require("ggplot2")) install.packages("ggplot2")
library(ggplot2)

# Install and load cluster (for clustering algorithms like k-means, PAM, silhouette analysis)
if (!require("cluster")) install.packages("cluster")
library(cluster)

# Install and load gridExtra (for arranging multiple ggplot2 plots in a grid)
if (!require("gridExtra")) install.packages("gridExtra")
library(gridExtra)

# Install and load e1071 (for additional ML functions — includes skewness, SVM, etc.)
if (!require("e1071")) install.packages("e1071")
library(e1071)

# ---- 3. Load the dataset ----

# Load the dataset exported from Power BI (named 'tradedata_export_from_BI.csv')
trade_data <- read.csv("tradedata_export_from_BI.csv")

# View the first few rows to inspect the data
head(trade_data)

# View current column names
names(trade_data)

# Rename columns for clarity and consistency
names(trade_data) <- c(
  "Country_Code",                  # ISO country code
  "Country_Year",                  # Combined country-year identifier
  "Country",                       # Country name
  "Year",                          # Year of the record
  "Distance_To_NZ",                # Distance from partner country to NZ
  "Partner_Export_Value",          # Export value from partner country
  "Political_Stability",           # Political stability score or indicator
  "GDP_Per_Capital",               # GDP per capita 
  "Import_Share_Percentage_To_NZ"  # Percentage share of NZ imports from the partner
)

# Confirm column names after renaming
names(trade_data)

# Selected relevent variables for clustering and analysis
selected_vars <- trade_data[, c(
  "Partner_Export_Value",
  "GDP_Per_Capital",
  "Import_Share_Percentage_To_NZ")]

# ---- 4. Data Exploration & Skewness ----

# Explore variable relationships using pairwise plots
ggpairs(selected_vars, aes(alpha = 0.5))

# Calculate skewness for selected variables
skew_results <- sapply(selected_vars, skewness, na.rm = TRUE)
print(round(skew_results, 3))

# ---- 5. Log Transformation & Yearly Subsets ----

# Apply log transformation to skewed variables (+1 to avoid log(0))
trade_data$Log_Import_Share_Percentage_To_NZ <- log(trade_data$Import_Share_Percentage_To_NZ + 1)
trade_data$Log_Partner_Export_Value <- log(trade_data$Partner_Export_Value + 1)
trade_data$Log_GDP_Per_Capital <- log(trade_data$GDP_Per_Capital + 1)

# Create yearly subsets
trade_data23 <- trade_data |> filter(Year == 2023) |> as.data.frame()
trade_data22 <- trade_data |> filter(Year == 2022) |> as.data.frame()
trade_data21 <- trade_data |> filter(Year == 2021) |> as.data.frame()
trade_data20 <- trade_data |> filter(Year == 2020) |> as.data.frame()
trade_data19 <- trade_data |> filter(Year == 2019) |> as.data.frame()

# Select relevant numeric variables for clustering
vars_to_select <- c("Log_Partner_Export_Value", "Log_GDP_Per_Capital", "Log_Import_Share_Percentage_To_NZ")

df_trade23 <- trade_data23[, vars_to_select]
df_trade22 <- trade_data22[, vars_to_select]
df_trade21 <- trade_data21[, vars_to_select]
df_trade20 <- trade_data20[, vars_to_select]
df_trade19 <- trade_data19[, vars_to_select]

# ---- 6. Standardize the Data ----

# Standardize the variables using z-score normalization
df_trade23_std <- as.data.frame(scale(df_trade23))
df_trade22_std <- as.data.frame(scale(df_trade22))
df_trade21_std <- as.data.frame(scale(df_trade21))
df_trade20_std <- as.data.frame(scale(df_trade20))
df_trade19_std <- as.data.frame(scale(df_trade19))

# ---- 7. Apply PCA and Clustering on Data (Year 2023) ----

# ---- 7.1 PCA Analysis ----

# Check for missing or infinite values
colSums(is.na(df_trade23))
colSums(!is.finite(as.matrix(df_trade23)))

# Perform PCA on standardized 2023 data
pca23 <- prcomp(df_trade23, center = TRUE, scale. = TRUE)

# Visualize variance explained by each principal component
explained_variance <- summary(pca23)$importance[2,]
barplot(explained_variance, main = "Variance Explained by Each PC")

# Summarize PCA result
summary(pca23)

# Extract the first 3 principal components
df_trade_pc_3 <- data.frame(pca23$x[, 1:3])
head(df_trade_pc_3)

# Add contextual info: Country names and clusters (if available)
df_trade_pc_3$Country <- trade_data23$Country

# Plot PC1 vs PC2, colored by PC3
ggplot(df_trade_pc_3, aes(x = PC1, y = PC2, color = PC3)) +
  geom_point(size = 3, alpha = 0.8) +
  scale_color_gradient(low = "blue", high = "red") +
  labs(
    title = "PCA Scatter Plot: PC1 vs PC2 (PC3 Encoded by Color)",
    x = "Principal Component 1",
    y = "Principal Component 2",
    color = "PC3 Value"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    axis.title = element_text(face = "bold")
  )

# Examine variable contributions to PCs (PCA loadings)
pca23$rotation

# Confirm PC computation manually for one row
df_trade23_std[1, ]
df_trade_pc_3[1, ]
rowSums(pca23$rotation[, 1] * df_trade23_std[1, ])  # PC1
rowSums(pca23$rotation[, 2] * df_trade23_std[1, ])  # PC2
rowSums(pca23$rotation[, 3] * df_trade23_std[1, ])  # PC3

# Correlation matrices for interpretation
print(round(cor(df_trade23), 3))         # Raw data
print(round(cor(df_trade23_std), 3))     # Standardized
print(round(cor(data.frame(pca23$x)), 3))  # PCA-transformed

# Basic biplot for PCA
biplot(pca23)

# ---- 7.2 Hierarchical Clustering on 3D PCA Space ----

# STEP 1: Prepare PCA data for clustering using PC1–PC3
df_hc_data <- df_trade_pc_3[, c("PC1", "PC2", "PC3")]
rownames(df_hc_data) <- df_trade_pc_3$Country  # Use country names as row labels

# STEP 2: Compute Euclidean distance matrix in 3D space
dist_matrix <- dist(df_hc_data, method = "euclidean")

# STEP 3: Perform hierarchical clustering using Ward’s method
hc_result <- hclust(dist_matrix, method = "ward.D2")

# STEP 4: Plot the dendrogram
plot(
  hc_result,
  labels = df_trade_pc_3$Country,
  cex = 0.5, hang = -1,
  main = "Hierarchical Clustering Dendrogram",
  xlab = "", sub = ""
)

# STEP 5: Cut dendrogram to form k clusters
df_trade_pc_3$HC_Cluster <- cutree(hc_result, k = 3)

# STEP 6: Visualize PCA result with hierarchical clusters in 2D
ggplot(df_trade_pc_3, aes(x = PC1, y = PC2, color = factor(HC_Cluster))) +
  geom_point(size = 3, alpha = 0.8) +
  labs(
    title = "PCA: Hierarchical Clustering Result (k = 3)",
    x = "PC1", y = "PC2",
    color = "HC Cluster"
  ) +
  theme_minimal()

# STEP 7:  3D visualization of clusters using PC1–PC3
library(plotly)

plot_ly(
  data = df_trade_pc_3,
  x = ~PC1, y = ~PC2, z = ~PC3,
  type = 'scatter3d',
  mode = 'markers',
  color = ~factor(HC_Cluster),
  colors = "Set1",
  text = ~Country,
  marker = list(size = 5, opacity = 0.8)
) %>%
  layout(
    title = list(text = "3D PCA Scatter Plot of Trade Clusters"),
    scene = list(
      xaxis = list(title = list(text = "PC1")),
      yaxis = list(title = list(text = "PC2")),
      zaxis = list(title = list(text = "PC3"))
    )
  )
# ---- 8. K-Means Clustering and Anomaly Detection year 2023 ----

# ---- 8.1 K-Mean 2023 ----

### Identify the best k number for cluster
fits <- list()
wcss_scores23 <- numeric()
silhouette_scores23 <- numeric()

# Loop through different values of k
set.seed(999)
for (k in 2:7) {
  # Train the model for current value of k
  model23 <- kmeans(df_trade23_std, centers = k)
  fits[[k]] <- model23 
  # Calculate WCSS
  wcss_scores23[k] <- model23$tot.withinss
  # Calculate silhouette score
  sil23 <- silhouette(model23$cluster, dist(df_trade23_std))
  silhouette_scores23[k] <- mean(sil23[, 3])
}

# Print the scores
cat("WCSS Scores:", wcss_scores23, '\n')
cat("Silhouette Scores:", silhouette_scores23, '\n')

# Plot the scores
scores_df23 <- data.frame(k = 2:7,
                          wcss23 = wcss_scores23[2:7],
                          sil23 = silhouette_scores23[2:7])
wcss_plot23 <- ggplot(scores_df23, aes(x = k, y = wcss23)) +
  geom_line() +
  geom_point() +
  labs(title = "2023 WCSS Scores for Different Values of k",
       x = "Number of Clusters (k)",
       y = "WCSS Score") +
  ylim(0, max(scores_df23$wcss23) * 1.1)
sil_plot23 <- ggplot(scores_df23, aes(x = k, y = sil23)) +
  geom_line() +
  geom_point() +
  labs(title = "2023 Silhouette Scores for Different Values of k",
       x = "Number of Clusters (k)",
       y = "Average Silhouette Score") +
  ylim(0, max(scores_df23$sil23) * 1.1)
grid.arrange(wcss_plot23, sil_plot23, ncol = 2)

## Clustering with the best k
set.seed(999)

kmeans_result23 <- kmeans(df_trade23_std, centers = 3) 
print(kmeans_result23)

## Silhoutte score from the best k
silhouette_scores23 <- silhouette(kmeans_result23$cluster, dist(df_trade23_std))
avg_silhouette_score23 <- mean(silhouette_scores23[, 3])
## Print the average silhouette score
print(avg_silhouette_score23)

## Add the cluster result to the table
trade_data23$Cluster <- factor(kmeans_result23$cluster)
head(trade_data23)

# ---- 8.2 Anomaly Detection 2023 ----
set.seed(999)
kmeans_result23 <- kmeans(df_trade23_std, centers = 3)

# Step 1: Store cluster in the standardized data frame
df_trade23_std$cluster <- factor(kmeans_result23$cluster)

# Step 2: Compute distances to centroids
euclidean_distance <- function(a, b) sqrt(sum((a - b)^2))

# Add distance column
df_trade23_std$DistanceToCentroid <- NA

centroids <- kmeans_result23$centers

for (i in 1:nrow(df_trade23_std)) {
  cluster_id <- kmeans_result23$cluster[i]
  point <- as.numeric(df_trade23_std[i, 1:ncol(centroids)])  # Only original vars
  centroid <- centroids[cluster_id, ]
  df_trade23_std$DistanceToCentroid[i] <- euclidean_distance(point, centroid)
}

# Step 3: Mean distance per cluster
cluster_means <- tapply(df_trade23_std$DistanceToCentroid, df_trade23_std$cluster, mean)

# Step 4: Flag anomalies (distance > 3× cluster mean)
df_trade23_std$Anomaly <- mapply(function(dist, cluster) {
  dist > 3 * cluster_means[as.character(cluster)]
}, df_trade23_std$DistanceToCentroid, df_trade23_std$cluster)

# Step 5: View anomalies
anomalies <- df_trade23_std[df_trade23_std$Anomaly == TRUE, ]
print(anomalies)

## Put the anomalies result to the table
trade_data23$Anomaly<-df_trade23_std$Anomaly

# As the cluster results seem similar in 2 clustering method. We choose to use
# K-mean as the final to apply for all the year

# ---- 9. K-Means Clustering and Anomaly Detection year 2022 ----

# ---- 9.1 K-Mean 2022 ----
### Identify the best k number for cluster
fits <- list()
wcss_scores22 <- numeric()
silhouette_scores22 <- numeric()

# Loop through different values of k
set.seed(999)
for (k in 2:7) {
  # Train the model for current value of k
  model22 <- kmeans(df_trade22_std, centers = k)
  fits[[k]] <- model22 # Append the model to fits
  # Calculate WCSS
  wcss_scores22[k] <- model22$tot.withinss
  # Calculate silhouette score
  sil22 <- silhouette(model22$cluster, dist(df_trade22_std))
  silhouette_scores22[k] <- mean(sil22[, 3])
}

# Print the scores
cat("WCSS Scores:", wcss_scores22, '\n')
cat("Silhouette Scores:", silhouette_scores22, '\n')

# Plot the scores
scores_df22 <- data.frame(k = 2:7,
                          wcss22 = wcss_scores22[2:7],
                          sil22 = silhouette_scores22[2:7])
wcss_plot22 <- ggplot(scores_df22, aes(x = k, y = wcss22)) +
  geom_line() +
  geom_point() +
  labs(title = "2022 WCSS Scores for Different Values of k",
       x = "Number of Clusters (k)",
       y = "WCSS Score") +
  ylim(0, max(scores_df22$wcss22) * 1.1)
sil_plot22 <- ggplot(scores_df22, aes(x = k, y = sil22)) +
  geom_line() +
  geom_point() +
  labs(title = "2022 Silhouette Scores for Different Values of k",
       x = "Number of Clusters (k)",
       y = "Average Silhouette Score") +
  ylim(0, max(scores_df22$sil22) * 1.1)
grid.arrange(wcss_plot22, sil_plot22, ncol = 2)

## Clustering with the best k
set.seed(999)

kmeans_result22 <- kmeans(df_trade22_std, centers = 4) 
print(kmeans_result22)

## Silhoutte score from the best k
silhouette_scores22 <- silhouette(kmeans_result22$cluster, dist(df_trade22_std))
avg_silhouette_score22 <- mean(silhouette_scores22[, 3])
## Print the average silhouette score
print(avg_silhouette_score22)

## Add the cluster result to the table
trade_data22$Cluster <- factor(kmeans_result22$cluster)
head(trade_data22)

# ---- 9.2 Anomaly Detection ----
set.seed(999)
kmeans_result22 <- kmeans(df_trade22_std, centers = 4)

# Step 1: Store cluster in the standardized data frame
df_trade22_std$cluster <- factor(kmeans_result22$cluster)

# Step 2: Compute distances to centroids
euclidean_distance <- function(a, b) sqrt(sum((a - b)^2))

# Add distance column
df_trade22_std$DistanceToCentroid <- NA

centroids <- kmeans_result22$centers

for (i in 1:nrow(df_trade22_std)) {
  cluster_id <- kmeans_result22$cluster[i]
  point <- as.numeric(df_trade22_std[i, 1:ncol(centroids)])  # Only original vars
  centroid <- centroids[cluster_id, ]
  df_trade22_std$DistanceToCentroid[i] <- euclidean_distance(point, centroid)
}

# Step 3: Mean distance per cluster
cluster_means <- tapply(df_trade22_std$DistanceToCentroid, df_trade22_std$cluster, mean)

# Step 4: Flag anomalies (distance > 3× cluster mean)
df_trade22_std$Anomaly <- mapply(function(dist, cluster) {
  dist > 3 * cluster_means[as.character(cluster)]
}, df_trade22_std$DistanceToCentroid, df_trade22_std$cluster)

# Step 5: View anomalies
anomalies <- df_trade22_std[df_trade22_std$Anomaly == TRUE, ]
print(anomalies)

## Put the anomalies result to the table
trade_data22$Anomaly<-df_trade22_std$Anomaly

# ---- 10. K-Means Clustering and Anomaly Detection year 2021 ----

# ---- 10.1 K-Mean 2021 ----
### Identify the best k number for cluster 
fits <- list()
wcss_scores21 <- numeric()
silhouette_scores21 <- numeric()

# Loop through different values of k
set.seed(999)
for (k in 2:7) {
  # Train the model for current value of k
  model21 <- kmeans(df_trade21_std, centers = k)
  fits[[k]] <- model21 # Append the model to fits
  # Calculate WCSS
  wcss_scores21[k] <- model21$tot.withinss
  # Calculate silhouette score
  sil21 <- silhouette(model21$cluster, dist(df_trade21_std))
  silhouette_scores21[k] <- mean(sil21[, 3])
}

# Print the scores
cat("WCSS Scores:", wcss_scores21, '\n')
cat("Silhouette Scores:", silhouette_scores21, '\n')

# Plot the scores
scores_df21 <- data.frame(k = 2:7,
                          wcss21 = wcss_scores21[2:7],
                          sil21 = silhouette_scores21[2:7])
wcss_plot21 <- ggplot(scores_df21, aes(x = k, y = wcss21)) +
  geom_line() +
  geom_point() +
  labs(title = "2021 WCSS Scores for Different Values of k",
       x = "Number of Clusters (k)",
       y = "WCSS Score") +
  ylim(0, max(scores_df21$wcss21) * 1.1)
sil_plot21 <- ggplot(scores_df21, aes(x = k, y = sil21)) +
  geom_line() +
  geom_point() +
  labs(title = "2021 Silhouette Scores for Different Values of k",
       x = "Number of Clusters (k)",
       y = "Average Silhouette Score") +
  ylim(0, max(scores_df21$sil21) * 1.1)
grid.arrange(wcss_plot21, sil_plot21, ncol = 2)

## Clustering with the best k
set.seed(999)

kmeans_result21 <- kmeans(df_trade21_std, centers = 4) 
print(kmeans_result21)

## Silhoutte score from the best k
silhouette_scores21 <- silhouette(kmeans_result21$cluster, dist(df_trade21_std))
avg_silhouette_score21 <- mean(silhouette_scores21[, 3])
## Print the average silhouette score
print(avg_silhouette_score21)

## Add the cluster result to the table
trade_data21$Cluster <- factor(kmeans_result21$cluster)
head(trade_data21)

# ---- 10.2 Anomaly Detection ----
set.seed(999)
kmeans_result21 <- kmeans(df_trade21_std, centers = 4)

# Step 1: Store cluster in the standardized data frame
df_trade21_std$cluster <- factor(kmeans_result21$cluster)

# Step 2: Compute distances to centroids
euclidean_distance <- function(a, b) sqrt(sum((a - b)^2))

# Add distance column
df_trade21_std$DistanceToCentroid <- NA

centroids <- kmeans_result21$centers

for (i in 1:nrow(df_trade21_std)) {
  cluster_id <- kmeans_result21$cluster[i]
  point <- as.numeric(df_trade21_std[i, 1:ncol(centroids)])  # Only original vars
  centroid <- centroids[cluster_id, ]
  df_trade21_std$DistanceToCentroid[i] <- euclidean_distance(point, centroid)
}

# Step 3: Mean distance per cluster
cluster_means <- tapply(df_trade21_std$DistanceToCentroid, df_trade21_std$cluster, mean)

# Step 4: Flag anomalies (distance > 3× cluster mean)
df_trade21_std$Anomaly <- mapply(function(dist, cluster) {
  dist > 3 * cluster_means[as.character(cluster)]
}, df_trade21_std$DistanceToCentroid, df_trade21_std$cluster)

# Step 5: View anomalies
anomalies <- df_trade21_std[df_trade21_std$Anomaly == TRUE, ]
print(anomalies)

## Put the anomalies result to the table
trade_data21$Anomaly<-df_trade21_std$Anomaly

# ---- 11. K-Means Clustering and Anomaly Detection Year 2020 ----

# ---- 11.1 K-Means 2020 ----
### Identify the best k number for cluster
fits <- list()
wcss_scores20 <- numeric()
silhouette_scores20 <- numeric()

# Loop through different values of k
set.seed(999)
for (k in 2:7) {
  # Train the model for current value of k
  model20 <- kmeans(df_trade20_std, centers = k)
  fits[[k]] <- model20 # Append the model to fits
  # Calculate WCSS
  wcss_scores20[k] <- model20$tot.withinss
  # Calculate silhouette score
  sil20 <- silhouette(model20$cluster, dist(df_trade20_std))
  silhouette_scores20[k] <- mean(sil20[, 3])
}

# Print the scores
cat("WCSS Scores:", wcss_scores20, '\n')
cat("Silhouette Scores:", silhouette_scores20, '\n')

# Plot the scores
scores_df20 <- data.frame(k = 2:7,
                          wcss20 = wcss_scores20[2:7],
                          sil20 = silhouette_scores20[2:7])
wcss_plot20 <- ggplot(scores_df20, aes(x = k, y = wcss20)) +
  geom_line() +
  geom_point() +
  labs(title = "2020 WCSS Scores for Different Values of k",
       x = "Number of Clusters (k)",
       y = "WCSS Score") +
  ylim(0, max(scores_df20$wcss20) * 1.1)
sil_plot20 <- ggplot(scores_df20, aes(x = k, y = sil20)) +
  geom_line() +
  geom_point() +
  labs(title = "2020 Silhouette Scores for Different Values of k",
       x = "Number of Clusters (k)",
       y = "Average Silhouette Score") +
  ylim(0, max(scores_df20$sil20) * 1.1)
grid.arrange(wcss_plot20, sil_plot20, ncol = 2)

## Clustering with the best k
set.seed(999)

kmeans_result20 <- kmeans(df_trade20_std, centers = 4) 
print(kmeans_result20)

## Silhoutte score from the best k
silhouette_scores20 <- silhouette(kmeans_result20$cluster, dist(df_trade20_std))
avg_silhouette_score20 <- mean(silhouette_scores20[, 3])
## Print the average silhouette score
print(avg_silhouette_score20)

## Add the cluster result to the table
trade_data20$Cluster <- factor(kmeans_result20$cluster)
head(trade_data20)

# ---- 11.2 Anomaly Detection 2020 ----
set.seed(999)
kmeans_result20 <- kmeans(df_trade20_std, centers = 4)

# Step 1: Store cluster in the standardized data frame
df_trade20_std$cluster <- factor(kmeans_result20$cluster)

# Step 2: Compute distances to centroids
euclidean_distance <- function(a, b) sqrt(sum((a - b)^2))

# Add distance column
df_trade20_std$DistanceToCentroid <- NA

centroids <- kmeans_result20$centers

for (i in 1:nrow(df_trade20_std)) {
  cluster_id <- kmeans_result20$cluster[i]
  point <- as.numeric(df_trade20_std[i, 1:ncol(centroids)])  # Only original vars
  centroid <- centroids[cluster_id, ]
  df_trade20_std$DistanceToCentroid[i] <- euclidean_distance(point, centroid)
}

# Step 3: Mean distance per cluster
cluster_means <- tapply(df_trade20_std$DistanceToCentroid, df_trade20_std$cluster, mean)

# Step 4: Flag anomalies (distance > 3× cluster mean)
df_trade20_std$Anomaly <- mapply(function(dist, cluster) {
  dist > 3 * cluster_means[as.character(cluster)]
}, df_trade20_std$DistanceToCentroid, df_trade20_std$cluster)

# Step 5: View anomalies
anomalies <- df_trade20_std[df_trade20_std$Anomaly == TRUE, ]
print(anomalies)

## Put the anomalies result to the table
trade_data20$Anomaly<-df_trade20_std$Anomaly



# ---- 12. K-Means Clustering and Anomaly Detection Year 2019 ----

# ---- 12.1 K-Means 2019----

# Identify the best k number for cluster
fits <- list()
wcss_scores19 <- numeric()
silhouette_scores19 <- numeric()

# Loop through different values of k
set.seed(999)
for (k in 2:7) {
  # Train the model for current value of k
  model19 <- kmeans(df_trade19_std, centers = k)
  fits[[k]] <- model19 # Append the model to fits
  # Calculate WCSS
  wcss_scores19[k] <- model19$tot.withinss
  # Calculate silhouette score
  sil19 <- silhouette(model19$cluster, dist(df_trade19_std))
  silhouette_scores19[k] <- mean(sil19[, 3])
}

# Print the scores
cat("WCSS Scores:", wcss_scores19, '\n')
cat("Silhouette Scores:", silhouette_scores19, '\n')

# Plot the scores
scores_df19 <- data.frame(k = 2:7,
                          wcss19 = wcss_scores19[2:7],
                          sil19 = silhouette_scores19[2:7])
wcss_plot19 <- ggplot(scores_df19, aes(x = k, y = wcss19)) +
  geom_line() +
  geom_point() +
  labs(title = "2019 WCSS Scores for Different Values of k",
       x = "Number of Clusters (k)",
       y = "WCSS Score") +
  ylim(0, max(scores_df19$wcss19) * 1.1)
sil_plot19 <- ggplot(scores_df19, aes(x = k, y = sil19)) +
  geom_line() +
  geom_point() +
  labs(title = "2019 Silhouette Scores for Different Values of k",
       x = "Number of Clusters (k)",
       y = "Average Silhouette Score") +
  ylim(0, max(scores_df19$sil19) * 1.1)
grid.arrange(wcss_plot19, sil_plot19, ncol = 2)

## Clustering with the best k
set.seed(999) # Set seed for reproducibility

kmeans_result19 <- kmeans(df_trade19_std, centers = 3) 
print(kmeans_result19) # View the clustering result

## Silhoutte score from the best k
silhouette_scores19 <- silhouette(kmeans_result19$cluster, dist(df_trade19_std))
avg_silhouette_score19 <- mean(silhouette_scores19[, 3])
## Print the average silhouette score
print(avg_silhouette_score19)

## Add the cluster result to the table
trade_data19$Cluster <- factor(kmeans_result19$cluster)
head(trade_data19)

# ---- 12.2 Anomaly Detection 2019 ----
set.seed(999)
kmeans_result19 <- kmeans(df_trade19_std, centers = 3)

# Step 1: Store cluster in the standardized data frame
df_trade19_std$cluster <- factor(kmeans_result19$cluster)

# Step 2: Compute distances to centroids
euclidean_distance <- function(a, b) sqrt(sum((a - b)^2))

# Add distance column
df_trade19_std$DistanceToCentroid <- NA

centroids <- kmeans_result19$centers

for (i in 1:nrow(df_trade19_std)) {
  cluster_id <- kmeans_result19$cluster[i]
  point <- as.numeric(df_trade19_std[i, 1:ncol(centroids)])  # Only original vars
  centroid <- centroids[cluster_id, ]
  df_trade19_std$DistanceToCentroid[i] <- euclidean_distance(point, centroid)
}

# Step 3: Mean distance per cluster
cluster_means <- tapply(df_trade19_std$DistanceToCentroid, df_trade19_std$cluster, mean)

# Step 4: Flag anomalies (distance > 3× cluster mean)
df_trade19_std$Anomaly <- mapply(function(dist, cluster) {
  dist > 3 * cluster_means[as.character(cluster)]
}, df_trade19_std$DistanceToCentroid, df_trade19_std$cluster)

# Step 5: View anomalies
anomalies <- df_trade19_std[df_trade19_std$Anomaly == TRUE, ]
print(anomalies)

## Put the anomalies result to the table
trade_data19$Anomaly<-df_trade19_std$Anomaly

# ---- 13. Export the cluster results to csv ----
write.csv(trade_data19, "df_data19_export.csv", row.names = FALSE)
write.csv(trade_data20, "df_data20_export.csv", row.names = FALSE)
write.csv(trade_data21, "df_data21_export.csv", row.names = FALSE)
write.csv(trade_data22, "df_data22_export.csv", row.names = FALSE)
write.csv(trade_data23, "df_data23_export.csv", row.names = FALSE)

# ---- 14. Summary Note ----
# The cluster results and anomaly flags are now included in each year's dataset.
# These outputs are exported as CSV files for further business insights.