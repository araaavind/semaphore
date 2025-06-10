package data

import "fmt"

func buildHotItemsScoreCalculationQuery(likeCountColumn, saveCountColumn, pubDateColumn, alternateDateColumn string) string {
	// Base score prevents the numerator from being 0 if there are no likes or saves
	// Increasing the base score will boost score for recent items
	baseScore := 1.0

	// Like weight is the multiplier for the like count
	likeWeight := 1.0

	// Save weight is the multiplier for the save count
	saveWeight := 3.0

	// SmoothFactor is the time smoothing factor
	// Adding a positive smoothing factor will prevent:
	//   1. Division by 0 for new items (when hours since published is 0)
	//   2. Over-boosting brand new items with even a single like or save
	smoothFactor := 10.0

	// Gravity exponent is the time based decay factor
	// It controls the rate at which scores decrease over time
	// A higher gravity exponent will cause scores to decrease faster with age
	// Reddit uses 1.8, Hacker News uses 1.5 (Source: chatGPT)
	gravity := 1.5

	// Formula:
	// score = (baseScore + log(likeCount + 1) * likeWeight + log(saveCount + 1) * saveWeight) / (timeFactor)
	// timeFactor = (timeSincePublished + smoothFactor) ^ gravity

	return fmt.Sprintf(`
		(
			(
				%f +
				LOG(COALESCE(%s, 0) + 1) * %f +
				LOG(COALESCE(%s, 0) + 1) * %f
			)::float /
			POWER(EXTRACT(EPOCH FROM (now() - LEAST(COALESCE(%s, %s), %s)))/3600 + %f, %f)
		)`,
		baseScore,
		likeCountColumn, likeWeight,
		saveCountColumn, saveWeight,
		pubDateColumn, alternateDateColumn, alternateDateColumn, smoothFactor, gravity,
	)
}
