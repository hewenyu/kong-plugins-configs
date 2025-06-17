package main

import (
	"net/http"
	"os"
	"strings"

	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()

	r.GET("/config", func(c *gin.Context) {
		configs := make(map[string]string)
		for _, e := range os.Environ() {
			pair := strings.SplitN(e, "=", 2)
			if strings.HasPrefix(strings.ToUpper(pair[0]), "KONG_") {
				configs[pair[0]] = pair[1]
			}
		}
		c.JSON(http.StatusOK, configs)
	})

	// Default to port 8080 if PORT environment variable is not set
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	r.Run(":" + port)
}
