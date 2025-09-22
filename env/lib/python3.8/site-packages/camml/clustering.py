from sklearn.cluster import KMeans

kmeans = KMeans(n_clusters=100)
kmeans.fit(embeddings)
