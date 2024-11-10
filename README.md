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

