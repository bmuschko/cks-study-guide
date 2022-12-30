package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strings"
)

func main() {
	http.HandleFunc("/validate", validate)
	log.Fatal(http.ListenAndServeTLS(":8080", "certs/image-validation-webhook.crt", "certs/image-validation-webhook.key", nil))
}

type ImageWebhookReq struct {
	Spec Spec `json:"spec"`
}

type Spec struct {
	Containers []Container `json:"containers"`
}

type Container struct {
	Image string `json:"image"`
}

func validate(w http.ResponseWriter, req *http.Request) {
	AllowedRepos := make([]string, 1)
	AllowedRepos[0] = "gcr.io/"

	var reqData ImageWebhookReq
	err := json.NewDecoder(req.Body).Decode(&reqData)

	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	var failureMessages []string

	for i, container := range reqData.Spec.Containers {
		image := container.Image
		log.Printf("Validating container %v with image %v", i+1, image)

		if !hasAllowedRepoPrefix(image, AllowedRepos) {
			failureMessages = append(failureMessages, fmt.Sprintf("container %v has an invalid image repo %v, allowed repos are %v", i+1, image, AllowedRepos))
		}
	}

	message := ""
	passed := len(failureMessages) == 0

	if !passed {
		message = fmt.Sprintf("Denied request: %v", failureMessages)
	}

	output := fmt.Sprintf("{\"apiVersion\": \"imagepolicy.k8s.io/v1alpha1\", \"kind\": \"ImageReview\", \"status\": {\"allowed\": %v,\"reason\": \"%v\"}}", passed, message)
	log.Printf("Response %v", output)
	fmt.Fprintf(w, output)
}

func hasAllowedRepoPrefix(image string, allowedRepos []string) bool {
	for _, repo := range allowedRepos {
		if strings.HasPrefix(image, repo) {
			return true
		}
	}

	return false
}
