# Image Validation Webhook

This is a sample program written in Go that implements a image validation webhook configurable as backend for a Kubernetes ImagePolicyWebhook admission plugin. Be aware that the code is not considered to be production-ready. Feel free to use the code as starting point for writing your own admission plugin backend.

The functionality validates the provided image. It will only allow images that start with the prefix `gcr.io/`. The registry is hard-coded in the program and cannot be changed from the outside right now.

## Running the Application

If you have the Go binary installed, you can run the application locally. The application exposes the port 8080. The context path for the validation logic is `/validate`.

```
$ go run main.go
```

To build the container image for the application locally, run the following command.

```
$ docker build . -t image-validation-webhook:0.0.1
```

I already pushed the [container image to Docker Hub](https://hub.docker.com/repository/docker/bmuschko/image-validation-webhook). You can start a Docker container of the application with the following command.

```
$ docker run -p 8080:8080 -d bmuschko/image-validation-webhook:0.0.1
```

## Calling the Endpoint

The following `curl` command calls the validation logic for the container image `nginx:1.19.0`. As you can see in the JSON response, the image is not denied.

```
$ curl -X POST -H "Content-Type: application/json" -d '{"spec": {"containers": [{"image": "nginx:1.19.0"}]}}' -k https://localhost:8080/validate
{"apiVersion": "imagepolicy.k8s.io/v1alpha1","kind": "ImageReview","status": {"allowed": false,"reason": "Denied request: [container 1 has an invalid image repo nginx:1.19.0, allowed repos are [gcr.io/]]"}}
```

The following `curl` command calls the validation logic for the container image `gcr.io/nginx:1.19.0`. As you can see in the JSON response, the image is allowed.

```
$ curl -X POST -H "Content-Type: application/json" -d '{"spec": {"containers": [{"image": "gcr.io/nginx:1.19.0"}]}}' -k https://localhost:8080/validate
{"apiVersion": "imagepolicy.k8s.io/v1alpha1","kind": "ImageReview","status": {"allowed": true,"reason": ""}}
```