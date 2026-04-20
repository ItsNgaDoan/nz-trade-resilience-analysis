# New Zealand’s Vulnerable International Trade  
Mapping Trade Potential for a More Resilient Supply Chain  

This is a **group project** completed as part of a *Data Visualisation course*, exploring how New Zealand’s international trade structure creates both **strengths and vulnerabilities**.

The analysis covers **5 years (2019–2023)** and **150+ global trade partners**, combining economic, trade, and geopolitical data to understand how New Zealand’s import dependency evolves over time.


## Overview  

To understand how trade operates between New Zealand and its international partners, this project focuses on the **demand side of trade** — specifically, **who New Zealand relies on for imports**.

The analysis was built on a core international trade dataset, which was enriched by integrating additional external datasets to provide broader context.

Data sources include:
- International trade data (WTO, OEC)  
- GDP per capita (World Bank)  
- Political stability index (World Bank)  
- Geographic distance data (CEPII)    

We analyzed trade relationships using four key metrics:

- **Global Export Value** – proxy for global trade influence  
- **NZ Import Share (%)** – level of dependency on each partner  
- **GDP per Capita** – economic strength and development level  
- **Political Stability & Distance** – contextual factors affecting trade reliability  

After data cleaning and transformation, we applied **unsupervised machine learning (clustering, PCA, anomaly detection)** to group countries with similar trade characteristics.

This was performed **year by year**, allowing us to track how trade relationships evolve and identify shifting vulnerabilities.


## Key Findings  

### 1. New Zealand is highly dependent on a small group  

- Over **80% of imports consistently come from a small set of partners**  
- Key imports include machinery, transport, fuel, and chemicals  

While many of these partners are supported by **Free Trade Agreements**, this concentration introduces **systemic risk**:
- Policy changes  
- Supply chain disruptions  
- Geopolitical or environmental shocks  


### 2. Trade relationships can be segmented into four distinct groups  

Using clustering, 150+ countries were grouped based on shared trade characteristics:

- **Primary Partners**  
  High import share, strong economies, and stable — e.g., China, Australia, USA  

- **Emerging Partners**  
  Growing economies with increasing trade potential — e.g., Vietnam, Indonesia  

- **Low Impact Partners**  
  Minimal contribution to NZ imports  

- **Niche Partners**  
  Smaller or specialised relationships (regional or aid-based)  

This segmentation provides a **data-driven framework** to understand both **dependency and diversification opportunities**.


### 3. Trade relationships are dynamic, not fixed  

- Countries **move between clusters over time**  
- More than **10 countries shifted groups (2019–2023)**  
- Emerging partners show increasing stability and trade relevance  

This indicates that:
> Future key trade partners may already be developing within the system.


### 4. COVID-19 reshaped trade patterns  

- The **Niche group separated from Low Impact during disruption periods**  
- By **2023, trade structures begin stabilising again**  

This suggests a **critical window to rethink trade strategy** before patterns fully lock in.


## Strategy Implications  

### Diversify to reduce systemic risk  
Heavy reliance on a small group of partners creates structural vulnerability.  
A more diversified import base is essential for long-term resilience.


### Prioritise high-potential Emerging partners  
Countries such as:
- Vietnam  
- Indonesia  
- Philippines  

Offer strong opportunities due to:
- Existing trade agreements (ASEAN, EU–NZ)  
- Improving political stability  
- Strategic geographic positioning  


### Use clustering as a decision framework  
Trade partner segmentation can support:
- Trade prioritisation  
- Policy negotiation  
- Supply chain planning  


## Data Model  

![Model View](./screenshots/model-view.png)

The data model integrates multiple datasets across **country and year dimensions**, enabling a unified analysis of New Zealand’s trade system.

A central fact table (`Trade_Data`) captures:
- Export value  
- Import value  
- NZ import share  

This table is connected via **Country_Code and Country_Year** to:

- GDP per capita (economic context)  
- Political stability (risk factors)  
- Distance to New Zealand (logistics constraints)  

Clustering outputs generated in R were re-integrated into Power BI, enabling **dynamic segmentation and time-based analysis**.


## Dashboard Preview  

![Cover](./screenshots/cover.png)

![Summary](./screenshots/summary.png)

![Clusters](./screenshots/global-trade-clusters.png)

![Trends](./screenshots/trade-group-trends-and-transitions.png)

![Characteristics](./screenshots/trade-cluster-characteristics.png)

![Conclusion](./screenshots/conclusion.png)


## Tools and Technologies  

- Power BI (Data modelling, DAX, dashboard design)  
- R (Clustering, PCA, anomaly detection)  
- Excel / CSV (data preparation)  


## Important Note  

The screenshots in this repository are static and may not capture all available interactions or detailed views from the Power BI dashboard.  

To explore the full interactive report, download the `.pbix` file below:

👉 [Download Power BI Dashboard](./nz-trade-resilience-dashboard.pbix)


## My Role and Contribution  

- Designed and developed the **full Power BI dashboard** (layout, visuals, storytelling)  
- Performed **data transformation and preparation** across multiple datasets  
- Conducted **Exploratory Data Analysis (EDA)**  
- Built the **data model in Power BI**  
- Implemented **DAX measures** for key metrics  
- Performed **machine learning analysis in R**:
  - Clustering (k-means)  
  - PCA  
  - Anomaly detection  


## Academic Use Notice

This project was completed as part of a group assignment at the University of Auckland and is shared for educational and portfolio purposes only.
The work presented reflects collaborative academic effort. Unauthorised use, reproduction, or redistribution may violate academic integrity policies.
