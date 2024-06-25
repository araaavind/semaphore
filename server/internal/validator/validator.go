package validator

import (
	"regexp"
	"slices"
	"strings"
	"unicode/utf8"
)

var (
	// Regex for checking sanity of email address. Source: https://html.spec.whatwg.org/#valid-e-mail-address
	EmailRX = regexp.MustCompile("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$")
	// Regex for checking sanity of username. Source: https://stackoverflow.com/a/12019115
	UsernameBasicRX = regexp.MustCompile(`(?i)^[a-zA-Z0-9._]+$`)
	HasLowerRX      = regexp.MustCompile(`[a-z]`)
	HasUpperRX      = regexp.MustCompile(`[A-Z]`)
	HasDigitRX      = regexp.MustCompile(`\d`)
	HasSpecialRX    = regexp.MustCompile(`[!@#$&*]`)
)

type Validator struct {
	Errors map[string]string
}

func New() *Validator {
	return &Validator{Errors: make(map[string]string)}
}

func (v *Validator) Valid() bool {
	return len(v.Errors) == 0
}

func (v *Validator) AddError(key, message string) {
	if _, exists := v.Errors[key]; !exists {
		v.Errors[key] = message
	}
}

func (v *Validator) Check(ok bool, key, message string) {
	if !ok {
		v.AddError(key, message)
	}
}

func PermittedValue[T comparable](value T, permittedValues ...T) bool {
	return slices.Contains(permittedValues, value)
}

func SafeSubstrings(s string, forbiddenSubstrings ...string) bool {
	for _, v := range forbiddenSubstrings {
		if strings.Contains(s, v) {
			return false
		}
	}
	return true
}

func SafePrefix(s string, forbiddenPrefixes ...string) bool {
	for _, v := range forbiddenPrefixes {
		if strings.HasPrefix(s, v) {
			return false
		}
	}
	return true
}

func SafeSuffix(s string, forbiddenSuffixes ...string) bool {
	for _, v := range forbiddenSuffixes {
		if strings.HasSuffix(s, v) {
			return false
		}
	}
	return true
}

func Matches(value string, rx *regexp.Regexp) bool {
	return rx.MatchString(value)
}

func NotBlank(value string) bool {
	return strings.TrimSpace(value) != ""
}

func MaxChars(value string, n int) bool {
	return utf8.RuneCountInString(value) <= n
}

func MinChars(value string, n int) bool {
	return utf8.RuneCountInString(value) >= n
}

func MaxBytes(value string, n int) bool {
	return len(value) <= n
}

func Unique[T comparable](values []T) bool {
	uniqueValues := make(map[T]bool)

	for _, value := range values {
		uniqueValues[value] = true
	}

	return len(values) == len(uniqueValues)
}
