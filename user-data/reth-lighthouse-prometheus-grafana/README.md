### Installs a RETH client with Lighthouse, Prometheus, and Grafana for monitoring

This cloud-init user-data file is designed to help you swiftly setup and run a Reth client on a fresh Ubuntu-based instance in seconds.

**What's happening under the hood?**

Preparing the Ground: The configuration begins by updating your system's packages and installing some necessary ones. These packages will help your system interact with secure web services and manage software repositories, which is fundamental for the steps that follow.

Setting Up Docker: Docker, a platform to build, deploy, and manage containers, is then installed. This forms the cornerstone of our setup as it allows the smooth running of the Reth client and other services in isolated environments.

Docker without Superuser Rights: To make your interaction with Docker seamless, the 'ubuntu' user is granted permission to run Docker commands without the 'sudo' prefix.

Docker Compose: Docker Compose, a tool for defining and managing multi-container Docker applications, is downloaded and made executable. This simplifies the management of our services, including the Reth client.

Making Room for the Project: A new directory named 'reth_project' is carved out. This is where all the magic will happen.

Gathering the Essentials: The Docker images necessary for running the Reth client and auxiliary services are pulled down from their repositories. These include the Reth client itself, Prometheus for monitoring, Grafana for data visualization, and Lighthouse as an Ethereum client.

Paving the Way with Docker Compose: A 'docker-compose.yml' file is then created within the 'reth_project' directory. This file is the blueprint that Docker Compose uses to orchestrate our services. It ensures that all our services interact smoothly and exposes specific ports for accessing these services.

Ignition: Finally, using Docker Compose, all services, including the Reth client, are fired up and ready to go.