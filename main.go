package main

import (
	"bufio"
	"fmt"
	"log"
	"net/http"
	"net/url"
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
		u := r.URL.Query().Get("url")
		if u == "" {
			http.Error(w, "url parameter not provided.", http.StatusBadRequest)
			return
		}

		p, err := url.Parse(u)
		if err != nil {
			log.Printf("Error parsing URL for %s: %v\n", u, err)
			http.Error(w, "url parameter not valid.", http.StatusBadRequest)
			return
		}

		httpStatus := http.StatusNotFound

		// normalize the URL so we are always dealing with a domain
		domain := p.Hostname()
		// but also handle just passing the domain to the endpoint
		if p.Scheme == "" || p.Host == "" {
			domain = u
		}

		if e.Hosts[domain] || e.Urls[domain] {
			httpStatus = http.StatusOK
		} else {
			// check for wildcard domains set in EZProxy
			domainParts := strings.Split(domain, ".")
			for i := len(domainParts); i >= 2; i-- {
				subdomain := strings.Join(domainParts[len(domainParts)-i:], ".")
				if e.Domains[subdomain] {
					httpStatus = http.StatusOK
					break
				}
			}
		}

		log.Printf("GET /check?url=%s HTTP/1.1 %d\n", u, httpStatus)

		w.WriteHeader(httpStatus)
		w.Header().Set("Content-Type", "text/plain")
		if httpStatus == http.StatusOK {
			fmt.Fprint(w, "1")
		} else {
			fmt.Fprint(w, "0")
		}
	default:
		log.Printf("%s /check HTTP/1.1 %d\n", r.Method, http.StatusMethodNotAllowed)
		http.Error(w, "Method not allowed.", http.StatusMethodNotAllowed)
	}
}
