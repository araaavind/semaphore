package cache

import (
	"fmt"
	"time"
)

const (
	KeyItemScoresPrefix = "item_scores:"
)

func GenerateItemScoresKey(wallID int64, sortMode string) string {
	return fmt.Sprintf("%s%d:%s:%s", KeyItemScoresPrefix, wallID, sortMode, time.Now().Format("20060102150405"))
}
