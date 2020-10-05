# Jaeger Tap Machine Lottery Automation

Automate the application process of the *Jaeger Tap Machine Lottery*.

## Requirements

1. Either:
    1. Docker
    2. Installed `selenium-server` with either `chromedriver` or `geckodriver`
2. Julia 1.5

## Usage

```bash
## 1.1. Either start Selenium Chrome inside Docker container
docker run -d -p 4444:4444 -p 5900:5900 -v /dev/shm:/dev/shm selenium/standalone-chrome:4.0.0-alpha-7-prerelease-20200921
## 1.2. Or start selenium-server after installing (e.g. for macOS)
# brew cask install chromedriver
# brew install selenium-server-standalone
# selenium-server -port 4445
## 2. Create config from template
cp config_example.yml config.yml
## 3. Insert your data into config.yml
vi config.yaml
## 4. Start automation
julia jaeger-automation.jl

## [Debug: VNC into localhost:5900 and observe Browser session]
# ./bin/vncview 127.0.0.1:5900
```
