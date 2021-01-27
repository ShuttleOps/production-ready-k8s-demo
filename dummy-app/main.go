package main

import (
	"fmt"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"log"
	"net/http"
	"os"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"time"
)

func message(w http.ResponseWriter, r *http.Request) {
	l := log.New(os.Stdout, "", 0)
	l.SetPrefix(time.Now().Format("2006-01-02 15:04:05") + " ")
	l.Printf("%s\n", r.RequestURI)
	fmt.Fprintf(w, "Hello World")
}

func recordMetrics() {
	go func() {
		for {
			opsProcessed.Inc()
			time.Sleep(2 * time.Second)
		}
	}()
}

var (
	opsProcessed = promauto.NewCounter(prometheus.CounterOpts{
		Name: "myapp_processed_ops_total",
		Help: "The total number of processed events",
	})
)

func main() {
	recordMetrics()

	http.HandleFunc("/", message)
	http.Handle("/metrics", promhttp.Handler())

	listeningPort, exists := os.LookupEnv("PORT")
	if !exists {
		listeningPort = "8080"
	}

	err := http.ListenAndServe(fmt.Sprintf(":%s", listeningPort), nil)
	if err != nil {
		log.Fatal(err)
	}
}
