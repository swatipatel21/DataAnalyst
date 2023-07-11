/*Which videos have the highest combined number of likes and comments?*/

SELECT video_id, title, SUM(likes+comments) as combined_number_of_likes_comments
FROM videos_stats 
GROUP BY video_id
ORDER BY combined_number_of_likes_comments DESC
LIMIT 10

/*What is the average number of likes per video for each keyword?*/
  
SELECT keyword, AVG(likes) AS avg_number_of_likes 
FROM videos_stats 
GROUP BY keyword

/*Find the videos that have more than 10,000 views and sort them by the number of comments in descending order.*/
  
SELECT * FROM videos_stats 
WHERE views > 10000.0
ORDER BY comments DESC


/*How many videos have the same keyword and were published on the same day?*/
  
SELECT keyword, published_at, COUNT(*) AS videos 
FROM videos_stats 
GROUP BY keyword, published_at
HAVING COUNT(*) > 1


/*Create a view that displays the top five videos with the highest views for each keyword.*/
  
CREATE VIEW top_videos_per_keyword AS
SELECT keyword, video_id, title, views
FROM (
  SELECT keyword, video_id, title, views,
         ROW_NUMBER() OVER (PARTITION BY keyword ORDER BY views DESC) AS row_num
  FROM videos_stats
) AS ranked
WHERE row_num <= 5;



/*Calculate the total number of comments and likes for videos published in the last month.*/

SELECT SUM(comments) AS total_comments, SUM(likes) AS total_likes
FROM videos_stats
WHERE published_at >= DATE_TRUNC('MONTH', CURRENT_DATE - INTERVAL '1' MONTH)
  AND published_at < DATE_TRUNC('MONTH', CURRENT_DATE)



/*find videos with negative sentiment in the comments and sort them by the number of likes.*/
  
SELECT vs.video_id, vs.title, vs.likes
FROM videos_stats vs
JOIN comments c
ON vs.video_id = c.video_id
WHERE c.sentiment = 0
ORDER BY vs.likes

/*How many videos have more comments than the average number of comments for all videos?*/
  
SELECT COUNT(*) AS videos_with_more_comments
FROM videos_stats
WHERE comments > (
    SELECT AVG(comments)
    FROM videos_stats
)

/*Create an index on the "Keyword" column in the "videos-stats.csv" table to improve the performance of keyword-based queries.*/
  
CREATE INDEX idx_keyword
ON videos_stats (keyword);

/* Create a view that shows the sentiment distribution (count of negative, neutral, and positive sentiments) for each keyword, along with the total number of comments. */
CREATE VIEW sentiment_distribution AS
SELECT vs.keyword, COUNT(*) AS total_comments, 
      COUNT(CASE WHEN c.sentiment = 0 THEN 1 END) AS negative_sentiments,
      COUNT(CASE WHEN c.sentiment = 1 THEN 1 END) AS neutral_sentiments,
      COUNT(CASE WHEN c.sentiment = 2 THEN 1 END) AS positive_sentiments
FROM videos_stats vs
JOIN comments c
ON vs.video_id = c.video_id
GROUP BY vs.keyword

