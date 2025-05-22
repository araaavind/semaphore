package data

import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"strings"

	"github.com/aravindmathradan/semaphore/internal/validator"
)

var (
	ErrInvalidCursor = errors.New("invalid cursor")
)

type Filters struct {
	Page         int
	PageSize     int
	Sort         string
	SortSafeList []string
}

type Metadata struct {
	CurrentPage  int `json:"current_page"`
	PageSize     int `json:"page_size"`
	FirstPage    int `json:"first_page"`
	LastPage     int `json:"last_page"`
	TotalRecords int `json:"total_records"`
}

func ValidateFilters(v *validator.Validator, f Filters) {
	v.Check(f.Page > 0, "page", "Page must be greater than zero")
	v.Check(f.Page < 10_000_000, "page", "Page must be a maximum of 1000000")
	v.Check(f.PageSize > 0, "page_size", "Page size must be greater than zero")
	v.Check(f.PageSize <= 100, "page_size", "Page size must be a maximum of 100")
	v.Check(validator.PermittedValue(f.Sort, f.SortSafeList...), "sort", fmt.Sprintf("Available sort parameters: %s", strings.Join(f.SortSafeList, ", ")))
}

func getEmptyMetadata(page, pageSize int) Metadata {
	return Metadata{
		CurrentPage:  page,
		PageSize:     pageSize,
		FirstPage:    1,
		LastPage:     1,
		TotalRecords: 0,
	}
}

func calculateMetadata(totalRecords, page, pageSize int) Metadata {
	if totalRecords == 0 {
		return getEmptyMetadata(page, pageSize)
	}

	return Metadata{
		CurrentPage:  page,
		PageSize:     pageSize,
		FirstPage:    1,
		LastPage:     (totalRecords + pageSize - 1) / pageSize,
		TotalRecords: totalRecords,
	}
}

// sortColumnMapping is a map of sort keys to database columns.
// It is used to map the sort keys to the correct database columns along with the table prefix if applicable.
type sortColumnMapping map[string]string

func (f Filters) sortColumn(columnMapping sortColumnMapping) string {
	for _, safeValue := range f.SortSafeList {
		if f.Sort == safeValue {
			sortKey := strings.TrimPrefix(f.Sort, "-")
			// If the sort key is in the column mapping, use the mapped column (along with the table prefix).
			if column, ok := columnMapping[sortKey]; ok {
				return column
			}
			// Else it's the column name itself
			return sortKey
		}
	}

	// the Sort value should have already been checked by calling the ValidateFilters() function.
	// Hence, panicking is a sensible failsafe to help stop a SQL injection attack occurring.
	panic("unsafe sort parameter: " + f.Sort)
}

func (f Filters) sortDirection() string {
	if strings.HasPrefix(f.Sort, "-") {
		return "DESC"
	}

	return "ASC"
}

func (f Filters) limit() int {
	return f.PageSize
}

func (f Filters) offset() int {
	return (f.Page - 1) * f.PageSize
}

/// Cursor based pagination

type SortMode string

const (
	SortModeNew SortMode = "new"
	SortModeHot SortMode = "hot"
)

type CursorFilters struct {
	SessionID    string
	After        string
	PageSize     int
	SortMode     SortMode
	SortSafeList []SortMode
}

type CursorMetadata struct {
	SessionID  string `json:"session_id,omitempty"`
	PageSize   int    `json:"page_size"`
	NextCursor string `json:"next_cursor"`
	HasMore    bool   `json:"has_more"`
}

func ValidateCursorFilters(v *validator.Validator, f CursorFilters) {
	v.Check(f.PageSize > 0, "page_size", "Page size must be greater than zero")
	v.Check(f.PageSize <= 100, "page_size", "Page size must be a maximum of 100")
	v.Check(validator.PermittedValue(f.SortMode, f.SortSafeList...), "sort_mode", "Invalid sort mode")
}

func getEmptyCursorMetadata(pageSize int) CursorMetadata {
	return CursorMetadata{
		SessionID:  "",
		PageSize:   pageSize,
		NextCursor: "",
		HasMore:    false,
	}
}

func calculateCursorMetadata(nextCursor any, pageSize int, hasMore bool, sessionID string) CursorMetadata {
	if nextCursor == "" || !hasMore {
		return getEmptyCursorMetadata(pageSize)
	}

	return CursorMetadata{
		SessionID:  sessionID,
		PageSize:   pageSize,
		NextCursor: encodeCursor(nextCursor),
		HasMore:    hasMore,
	}
}

func encodeCursor(c any) string {
	b, err := json.Marshal(c)
	if err != nil {
		panic(err)
	}
	return base64.URLEncoding.EncodeToString(b)
}

func decodeCursor(s string, c any) error {
	b, err := base64.URLEncoding.DecodeString(s)
	if err != nil {
		return err
	}
	dec := json.NewDecoder(bytes.NewReader(b))
	dec.DisallowUnknownFields()

	err = dec.Decode(c)
	if err != nil {
		var syntaxError *json.SyntaxError
		var unmarshalTypeError *json.UnmarshalTypeError
		var invalidUnmarshalError *json.InvalidUnmarshalError

		switch {
		case errors.As(err, &syntaxError):
			return ErrInvalidCursor

		// In some circumstances Decode() may also return an io.ErrUnexpectedEOF error
		// for syntax errors in the JSON. So we check for this using errors.Is() and
		// return a generic error message. There is an open issue regarding this at
		// https://github.com/golang/go/issues/25956.
		case errors.Is(err, io.ErrUnexpectedEOF):
			return ErrInvalidCursor

		// *json.UnmarshalTypeError errors occur when the JSON value is the wrong type for
		// the target destination.
		case errors.As(err, &unmarshalTypeError):
			if unmarshalTypeError.Field != "" {
				return ErrInvalidCursor
			}
			return ErrInvalidCursor

		// An io.EOF error will be returned by Decode() if the request body is empty.
		case errors.Is(err, io.EOF):
			return ErrInvalidCursor

		// If the JSON contains a field which cannot be mapped to the target destination
		// then Decode() will now return an error message in the format "json: unknown
		// field "<name>"".
		case strings.HasPrefix(err.Error(), "json: unknown field "):
			return ErrInvalidCursor

		// A json.InvalidUnmarshalError error will be returned if we pass something
		// that is not a non-nil pointer to Decode(). We catch this and panic,
		// rather than returning an error to our handler.
		case errors.As(err, &invalidUnmarshalError):
			panic(err)

		default:
			return err
		}
	}

	// Call Decode() again, using a pointer to an empty anonymous struct as the
	// destination. If the request body only contained a single JSON value this will
	// return an io.EOF error. So if we get anything else, we know that there is
	// additional data in the request body and we return our own custom error message.
	err = dec.Decode(&struct{}{})
	if !errors.Is(err, io.EOF) {
		return ErrInvalidCursor
	}

	return nil
}
