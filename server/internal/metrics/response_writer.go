package metrics

import "net/http"

type MetricsResponseWriter struct {
	Wrapped       http.ResponseWriter
	StatusCode    int
	HeaderWritten bool
}

func New(w http.ResponseWriter) *MetricsResponseWriter {
	return &MetricsResponseWriter{
		Wrapped:    w,
		StatusCode: http.StatusOK,
	}
}

// Pass-through Header
func (mw *MetricsResponseWriter) Header() http.Header {
	return mw.Wrapped.Header()
}

// Pass-through WriteHeader
func (mw *MetricsResponseWriter) WriteHeader(statusCode int) {
	mw.Wrapped.WriteHeader(statusCode)

	if !mw.HeaderWritten {
		mw.StatusCode = statusCode
		mw.HeaderWritten = true
	}
}

// Pass-through Write
func (mw *MetricsResponseWriter) Write(b []byte) (int, error) {
	mw.HeaderWritten = true
	return mw.Wrapped.Write(b)
}

func (mw *MetricsResponseWriter) Unwrap() http.ResponseWriter {
	return mw.Wrapped
}
