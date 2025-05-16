package fetchers

import (
	"encoding/json"
	"image"
	"io"
	"net/http"
	"net/url"
	"os"
	"path"
)

const (
	UserAgent string = "foodogsquared-flock-of-feathers/0.1.0 <foodogsquared@foodogsquared.one>"
)

type fetcherRequestFunc func(c *http.Client, p, m string, body io.Reader) (*http.Response, error)
type downloadFileFunc func(dlOpts map[string]string, o string) error
type jsonRequestFunc func(p string, o *Downloadable) (*Downloadable, error)

type ClientInterface interface {
	Request(p, method string, body io.Reader) (*http.Response, error)
	APIEndpoint() (*url.URL, error)
}

type Downloadable interface {
	// The automatically assigned filename template associated with the
	// downloadable object.
	FilenameTemplate() string

	// Create an HTTP request for the downloadable object.
	RequestFile(dlOpts map[string]string) (*http.Response, error)

	// Download the file associated with the downloadable object into the
	// filesystem.
	DownloadFile(dlOpts map[string]string, outputDir string) error
}

// The default implementation for downloading a file.
func DefaultDownloadFile(dlable Downloadable) downloadFileFunc {
	return func(dlOpts map[string]string, outputDir string) error {
		fn := dlable.FilenameTemplate()
		f, err := os.Create(path.Join(outputDir, fn))
		if err != nil {
			return err
		}
		defer f.Close()

		res, err := dlable.RequestFile(dlOpts)
		if err != nil {
			return err
		}
		defer res.Body.Close()

		if _, err := f.ReadFrom(res.Body); err != nil {
			return err
		}

		return nil
	}
}

// Common implementation for using an HTTP API service that returns a JSON
// response.
func DefaultJsonRequestImpl[T Downloadable](c ClientInterface) func(p string, body io.Reader) (T, error) {
	return func(p string, body io.Reader) (T, error) {
		var v T

		res, err := c.Request(p, "GET", body)
		if err != nil {
			return v, err
		}
		defer res.Body.Close()

		dec := json.NewDecoder(res.Body)
		if err := dec.Decode(&v); err != nil {
			return v, err
		}

		return v, nil
	}
}

type TwoDimensional interface {
	GetWidth() float64
	GetHeight() float64
	Rectangle() image.Rectangle
}

type Attribution interface {
	GetAttributionLine() string
}
