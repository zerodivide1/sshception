# sshception
Simple utility to spawn an SSH session to a system through another SSH tunnel, then tear down the tunnel when the session ends.

## Requirements
* `shuf` or `gshuf` (if installed on a OSX system via the `coreutils` package in Homebrew)
* `lsof`
* `seq`
* `ssh` (obviously)

## Usage

```
sshception [<tunnel username>@]<tunnel host>[:<tunnel port>] [<target username>@]<target host[:<target port>]
```

* `tunnel username` - The username used to create the SSH tunnel (default: current username) (optional)
* `tunnel host` - The FQDN or IP address of the SSH tunnel host (required)
* `tunnel port` - The port number of the SSH tunnel host (default: `22`) (optional)
* `target username` - The username of the host to establish the SSH session on (default: current username) (optional)
* `target host` - The FQDN or IP address of the SSH target host (required) (_Note_: This is the IP address or FQDN from the perspective of the tunnel host)
* `target port` - The port number of the SSH target host (default: `22`) (optional)

### Example

```
batman@batcave $ sshception cyborg@mainframe.justiceleague.org:12345 brainiac
```

This example creates a SSH tunnel on `mainframe.justiceleague.org` and port `12345` with username `cyborg`, then uses that tunnel to create an SSH session to host `brainiac` in the internal network of the tunnel host with the default username (which is the current user, which is `batman`) using the default SSH port `22`.
