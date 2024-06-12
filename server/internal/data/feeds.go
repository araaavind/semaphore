package data

import (
	"time"

	"github.com/aravindmathradan/semaphore/internal/validator"
)

type Feed struct {
	ID          int64     `json:"id"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
	Title       string    `json:"title"`
	Description string    `json:"description"`
	Link        string    `json:"link"`
	FeedLink    string    `json:"feed_link,omitempty"`
	PubUpdated  time.Time `json:"pub_updated,omitempty"`
	PubDate     time.Time `json:"pub_date,omitempty"`
	FeedType    string    `json:"feed_type,omitempty"`
	FeedVersion string    `json:"feed_version,omitempty"`
	Language    string    `json:"language,omitempty"`
	Version     int32     `json:"version,omitempty"`
}

func ValidateLink(v *validator.Validator, link string) {
	v.Check(validator.NotBlank(link), "link", "link must not be empty")
}
