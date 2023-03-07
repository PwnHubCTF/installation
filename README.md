# installation

## Usage of script_front.sh

`./script_front.sh -t <token> -d <domain> [-p]`

- token: GithubUsername:GithubToken, ex Foobar:ghp_dsq5F6ug775zHjif975
- domain: url of the server, ex myctf.fr
- if `-p` is set, your instance will be protected by a basic auth. User is `pwnhub`, and password is printed at the end

  ## Usage of script_deployer.sh

`./script_deployer.sh -t <token> -d <domain>`

- token: GithubUsername:GithubToken, ex Foobar:ghp_dsq5F6ug775zHjif975
- domain: url or ip of the server, ex 56.43.32.55

> At the end of installation, a token will be printed. You need to keep it and set it in the ctf configuration

  ## Usage of script_bot-xss.sh

`./script_bot-xss.sh -t <token>`

- token: GithubUsername:GithubToken, ex Foobar:ghp_dsq5F6ug775zHjif975

> At the end of installation, a token will be printed. You need to keep it and set it in the ctf configuration
