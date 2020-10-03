# Jaeger Tap Machine Lottery Automation

Automate the application process of the *Jaeger Tap Machine Lottery*.

## Requirements

1. Docker
2. Julia 1.5

## Usage

```bash
## 1. Start Selenium Chrome inside Docker container
docker run -d -p 4444:4444 -p 5900:5900 -v /dev/shm:/dev/shm selenium/standalone-chrome:4.0.0-alpha-7-prerelease-20200921
## 2. Create config from template
cp config_example.yml config.yml
## 3. Insert your data into config.yml
vi config.yaml
## 4. Start automation
julia jaeger-automation.jl

## [Debug: VNC into localhost:5900 and observe Browser session]
# ./bin/vncview 127.0.0.1:5900
```
