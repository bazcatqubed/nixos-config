package cmd

import (
	"errors"
	"fds-flock-of-fetchers/fetchers/unsplash"
	"fmt"
	"net/url"
	"strconv"
	"strings"

	"github.com/spf13/cobra"
)

var (
	unsplashCmd = &cobra.Command{
		Use:   "unsplash [--api-key STRING]",
		Short: "Utility for interacting with Unsplash",
		Long: `Commands for fetching assets from Unsplash.

Practically requires an API key from its configuration for most of its
operations.`,
	}

	unsplashApiKey string

	unsplashFetchByIDCmd = &cobra.Command{
		Use:   "by-id ID [ID...]",
		Short: "fetch an asset from Unsplash given its ID",
		Run:   runUnsplashFetchByIDCmd,
		Args:  cobra.MinimumNArgs(1),
	}

	unsplashFetchByEditorialFeedCmd = &cobra.Command{
		Use:   "editorial-feed",
		Short: "fetch assets from Unsplash editorial feed",
		Run:   runUnsplashFetchByEditorialFeedCmd,
	}

	unsplashFetchByRandom = &cobra.Command{
		Use:   "random",
		Short: "fetch a random asset from Unsplash",
		Run:   runUnsplashFetchByRandomCmd,
		Args: func(cmd *cobra.Command, args []string) error {
			v, err := cmd.Flags().GetUint8("count")
			if err != nil {
				return err
			}

			if v > 30 {
				return fmt.Errorf("random count is more than 30")
			}

			return nil
		},
	}
)

func runUnsplashFetchByIDCmd(cmd *cobra.Command, ids []string) {
	client := unsplash.NewClient(getUnsplashApiKey())

	photoVariant, err := cmd.Flags().GetString("photo-variant")
	if err != nil {
		cmd.PrintErrln(err)
	}

	for _, id := range ids {
		if id == "" {
			cmd.PrintErrln(errors.New("unsplash: given ID is empty, skipping request"))
			continue
		}

		photo, err := client.GetPhoto(id)
		if err != nil {
			cmd.PrintErrln(err)
			continue
		}

		dlOpts := make(map[string]string)
		dlOpts["photo-variant"] = photoVariant

		if err := photo.DownloadFile(dlOpts, outputDir); err != nil {
			cmd.PrintErrln(err)
			continue
		}

		cmd.Println(photo.GetAffiliationLine())
	}
}

func runUnsplashFetchByEditorialFeedCmd(cmd *cobra.Command, args []string) {
	client := unsplash.NewClient(getUnsplashApiKey())

	photoVariant, err := cmd.Flags().GetString("photo-variant")
	if err != nil {
		cmd.PrintErrln(err)
	}

	cmdFlags := cmd.Flags()
	query := url.Values{}

	if v, err := cmdFlags.GetUint8("count"); err == nil {
		query.Set("per_page", strconv.Itoa(int(v)))
	}

	photos, err := client.GetPhotoEditorialFeed(query)
	if err != nil { cobra.CheckErr(err) }

	for _, photo := range photos {
		dlOpts := make(map[string]string)
		dlOpts["photo-variant"] = photoVariant

		if err := photo.DownloadFile(dlOpts, outputDir); err != nil {
			cmd.PrintErrln(err)
			continue
		}

		cmd.Println(photo.GetAffiliationLine())
	}
}

func runUnsplashFetchByRandomCmd(cmd *cobra.Command, args []string) {
	client := unsplash.NewClient(getUnsplashApiKey())

	photoVariant, err := cmd.Flags().GetString("photo-variant")
	if err != nil {
		cmd.PrintErrln(err)
	}

	cmdFlags := cmd.Flags()
	query, _ := url.ParseQuery("")

	if v, err := cmdFlags.GetStringSlice("collections"); err == nil && len(v) > 0 {
		query.Set("collections", strings.Join(v, ","))
	}

	if v, err := cmdFlags.GetStringSlice("topics"); err == nil && len(v) > 0 {
		query.Set("topics", strings.Join(v, ","))
	}

	if v, err := cmdFlags.GetUint8("count"); err == nil {
		query.Set("count", strconv.Itoa(int(v)))
	}

	if v, err := cmdFlags.GetString("query"); err == nil && v != "" {
		query.Set("query", v)
	}

	if v, err := cmdFlags.GetString("username"); err == nil && v != "" {
		query.Set("username", v)
	}

	if v, err := cmdFlags.GetString("variant"); err == nil && v != "" {
		query.Set("variant", v)
	}

	if v, err := cmdFlags.GetString("orientation"); err == nil && v != "" {
		query.Set("orientation", v)
	}

	photos, err := client.GetRandomPhotos(query)
	if err != nil { cobra.CheckErr(err) }

	for _, photo := range photos {
		dlOpts := make(map[string]string)
		dlOpts["photo-variant"] = photoVariant

		if err := photo.DownloadFile(dlOpts, outputDir); err != nil {
			cmd.PrintErrln(err)
			continue
		}

		cmd.Println(photo.GetAffiliationLine())
	}
}

func getUnsplashApiKey() string {
	if v := ffofViper.GetString("unsplash.api_key"); v != "" {
		return v
	}

	return ffofViper.GetString("unsplash_api_key")
}

func init() {
	unsplashFetchByRandom.Flags().Uint8("count", 1, "number of photos to be returned (maximum of 30)")
	unsplashFetchByRandom.Flags().StringSlice("collections", []string{}, "public collections to filter selection")
	unsplashFetchByRandom.Flags().StringSlice("topics", []string{}, "public topics to filter selection")
	unsplashFetchByRandom.Flags().String("query", "", "query to match only with the specified term")
	unsplashFetchByRandom.Flags().String("username", "", "limit photos only from the given user account")
	unsplashFetchByRandom.Flags().String("variant", "", "variant of the photos to be downloaded")
	unsplashFetchByRandom.Flags().String("orientation", "", "filter by orientation (landscape, portrait, or squarish)")

	unsplashFetchByEditorialFeedCmd.Flags().Uint8("count", 10, "number of photos to be returned (maximum of 30)")

	unsplashCmd.PersistentFlags().String("photo-variant", "raw", "variant of the photos to be downloaded")
	unsplashCmd.PersistentFlags().StringVar(&unsplashApiKey, "api-key", "", "API key for Unsplash service")

	ffofViper.BindPFlag("unsplash.api_key", unsplashCmd.PersistentFlags().Lookup("api-key"))
	ffofViper.BindEnv("unsplash_api_key")

	// Set up the subcommands and its root.
	unsplashCmd.AddCommand(unsplashFetchByIDCmd)
	unsplashCmd.AddCommand(unsplashFetchByEditorialFeedCmd)
	unsplashCmd.AddCommand(unsplashFetchByRandom)

	rootCmd.AddCommand(unsplashCmd)
}
