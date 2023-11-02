package main

import (
	"bufio"
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"
)

type EzproxyComponents struct {
	Urls    map[string]bool
	Hosts   map[string]bool
	Domains map[string]bool
}

var e EzproxyComponents

func init() {
	var err error
	e.Urls, err = populateMap("config/urls.txt")
	if err != nil {
		log.Fatal("Unable to load urls")
	}
	e.Hosts, err = populateMap("config/hosts.txt")
	if err != nil {
		log.Fatal("Unable to load hosts")
	}
	e.Domains, err = populateMap("config/domains.txt")
	if err != nil {
		log.Fatal("Unable to load domains")
	}
}

func main() {
	http.HandleFunc("/proxyUrl", checkUrl)

	log.Println("Server listening on :8080")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		panic(err)
	}
}

func populateMap(f string) (map[string]bool, error) {
	m := make(map[string]bool)
	file, err := os.Open(f)
	if err != nil {
		log.Printf("Error opening file: %v", err)
		return nil, err
	}
	defer file.Close()

	log.Println("Loading EZProxy config", f)
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		m[line] = true
	}

	if err := scanner.Err(); err != nil {
		log.Printf("Error reading file: %v", err)
		return nil, err
	}

	return m, nil
}

func checkUrl(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "GET":
		url := r.URL.Query().Get("url")
		if url == "" {
			http.Error(w, "url parameter not provided.", http.StatusBadRequest)
			return
		}
		log.Println("Checking", url)

		w.Header().Set("Content-Type", "text/plain")
		if e.Hosts[url] || e.Urls[url] {
			log.Println("Found in hosts or urls")
			w.WriteHeader(http.StatusOK)
			fmt.Fprint(w, "1")
			return
		}

		// check for wildcard domains
		domainParts := strings.Split(url, ".")
		for i := len(domainParts); i >= 2; i-- {
			subdomain := strings.Join(domainParts[len(domainParts)-i:], ".")
			if e.Domains[subdomain] {
				log.Printf("Found in domains %s\n", subdomain)

				w.WriteHeader(http.StatusOK)
				fmt.Fprint(w, "1")
				return
			}
		}

		w.WriteHeader(http.StatusNotFound)
		fmt.Fprint(w, "0")
	default:
		http.Error(w, "Method not allowed.", http.StatusMethodNotAllowed)
	}
}
