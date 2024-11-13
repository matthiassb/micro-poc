<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a id="readme-top"></a>
<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Don't forget to give the project a star!
*** Thanks again! Now go create something AMAZING! :D
-->



<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->

<!-- PROJECT LOGO -->
<br />
<div align="center">

<h3 align="center">Micro POC</h3>

  <p align="center">
    Container-Based Lambda/Serverless POC
</div>




## Getting Started

This projects uses docker to stand up a language agnostiic local development environment for creating serverless functions based on containers.

### Prerequisites

* Docker
* Terraform

### Local Development 

Kong is used as an AWS Compliant API Gateway for local development


### Adding a Service

1. Create a new directory under the `services`. Include a Dockerfile and any necessary files. See `./services/customers` for an example.
2. Add the new service to the `docker-compose.yml` file.
3. Add the new service to the `kong.yml` file.
4. Restart docker compose.


### Starting the services

```sh
docker compose up --build --watch
```

### Connecting to Service

```sh
curl -i -X GET http://localhost:8000/customers
```

### Deploying the API Gateway and Microservices using Terraform

1. Navigate to the `deploy` directory.
2. Initialize Terraform:
   ```sh
   terraform init
   ```
3. Apply the Terraform configuration:
   ```sh
   terraform apply
   ```
4. Follow the prompts to confirm the deployment.

This will deploy the API Gateway and the microservices to AWS.

### Setting up Github Actions CI/CD Pipeline

1. Create a new file `.github/workflows/ci-cd.yml` in your repository.
2. Add the following content to the file:
   ```yaml
   name: CI/CD Pipeline

   on:
     push:
       branches:
         - main
     pull_request:
       branches:
         - main

   jobs:
     build:
       runs-on: ubuntu-latest

       steps:
         - name: Checkout code
           uses: actions/checkout@v2

         - name: Set up Docker Buildx
           uses: docker/setup-buildx-action@v1

         - name: Log in to Amazon ECR
           id: login-ecr
           uses: aws-actions/amazon-ecr-login@v1

         - name: Build and push Docker images
           run: |
             for service in $(ls services); do
               docker build -t ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/$service:latest services/$service
               docker push ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/$service:latest
             done

         - name: Set up Terraform
           uses: hashicorp/setup-terraform@v1

         - name: Terraform Init
           run: terraform init
           working-directory: deploy

         - name: Terraform Apply
           run: terraform apply -auto-approve
           working-directory: deploy
           env:
             AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
             AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
             AWS_REGION: ${{ secrets.AWS_REGION }}
   ```
3. Commit and push the changes to your repository.

This will set up a CI/CD pipeline using Github Actions to build and push Docker images to ECR and deploy the infrastructure using Terraform.
