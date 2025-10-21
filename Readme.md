# Tracksuit Application

A full-stack TypeScript application built with Deno, featuring a React frontend and RESTful API backend. Includes deployment configurations for Kubernetes and AWS ECS/Fargate with CI for automation.

<!-- Link definitions -->

[DenoInstall]: https://docs.deno.com/runtime/getting_started/installation/
[mise.toml]: ./mise.toml
[Instructions]: ./Instructions.md

## Setup

Install Deno 2.4 using your preferred method--typically this would be your
system's package manager. See [Deno's installation instructions][DenoInstall] to find the
command that's right for you.

<!-- deno-fmt-ignore-start -->

> [!Tip]
> If you happen to use Mise for version management, this repo's got you.
>
> ```sh
> mise trust && mise install
> ```

<!-- deno-fmt-ignore-end -->

This repo was developed against Deno 2.4.2.

### Common tasks

Most of the commands you'll need are provided by the Deno toolchain. You can run
tasks either from the repo root or within each package

#### Building the server

```sh
cd server
deno task build
```

This is set up to output an x86_64 Linux ELF at `server/build/server`. You can
override the target architecture if necessary by setting the `ARCH` environment
variable; [see the docs here](https://docs.deno.com/runtime/reference/cli/compile/#supported-targets) for possible values.

#### Building the frontend

While you don't have to worry too much about it for this exercise, you might
want to try building the frontend:

```sh
cd client
deno task build
```

#### Type Checking

```sh
deno check .
```

## Building with Docker

To build the Docker image locally:

```bash
make build
```

This will:
- Auto-detect your architecture (ARM64 or x86_64)
- Build the image with mise


## Deploy to Kubernetes ( Local Minikube )

To deploy the service to Kubernetes:

1. Clone the repository and navigate to the project directory (if not already done so):
   ```bash
   git clone https://github.com/saedabdu/gotracksuit.git
   cd gotracksuit
   ```

2. Check prerequisites:
   ```bash
   make check
   ```

3. Deploy to Minikube:
   ```bash
   make deploy
   ```

4. Set up port forwarding to access the service:
   ```bash
   make port-forward
   ```

5. Access the service at http://localhost:8080


## Deploy to AWS ECS/Fargate

For minimal operational overhead deployments, we can also use ECS/Fargate for a fully managed, serverless container orchestration on AWS.

The Terraform stack deploys:
- **Backend**: ECS/Fargate containers with auto-scaling
- **Frontend**: S3 + CloudFront CDN for static assets


**Manual Deployment (without Terraform):**

```bash
# 1. Register task definition
aws ecs register-task-definition \
  --cli-input-json file://ecs/task-definition.json

# 2. Create ECS cluster
aws ecs create-cluster --cluster-name tracksuit-prod

# 3. Create service
aws ecs create-service \
  --cli-input-json file://ecs/service-definition.json
```


## Troubleshooting

- **Connection issues**
  ```bash
  # Ensure Docker and Minikube are running
  make check
  ```

- **Port conflicts**
  If port 8080 is already in use, the `make port-forward` command will automatically kill existing processes using that port.

- **Container logs**
  ```bash
  # Check container logs
  kubectl logs -l app=tracksuit-backend
  ```


# On Observability & Monitoring and what we might need ?


### 1. Logging
- We need a structured JSON logging ( middleware) in our app.
- Include request IDs, timestamps (to enable distributed tracing and use Xray, Datadog, etc.)

### 2. Metrics
- If we expose /_metrics endpoint (something Prometheus can understand if we are using prometheus)
- Track: request count, latency, error rate (Talking 5 vital signs os SRE here)

### 3. Monitoring Stack ?
- Option 1: Prometheus + Grafana (self-hosted)
- Option 2: DataDog (SaaS, faster setup)

### 4. Key Metrics ( for SLIs / SLO Dashboards, etc)
- Availability (99.9% target)
- P95 latency < 200ms
- Error rate < 1%

### 5. Alerting
- Critical: API down, high error rate
- Warning: Increased latency, memory usage, etc