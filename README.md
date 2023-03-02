# installation

## Usage of script_front.sh

`./script_front.sh -t <token> -d <domain> [-p]`

- token: GithubUsername:GithubToken, ex Foobar:ghp_dsq5F6ug775zHjif975
- domain: url of the server, ex myctf.fr
- if `-p` is set, your instance will be protected by a basic auth

default user: **Can't be changed for now**
`2600`
`54F5d2emPdFUCKLESJALOUXd1rD11fmlf`

  ## Usage of script_deployer.sh

`./script_deployer.sh -t <token> -d <domain>`

- token: GithubUsername:GithubToken, ex Foobar:ghp_dsq5F6ug775zHjif975
- domain: url or ip of the server, ex 56.43.32.55

> At the end of installation, there is a token printed. You need to save, and set it in the ctf config

  ## Usage of script_bot-xss.sh

`./script_bot-xss.sh -t <token>`

- token: GithubUsername:GithubToken, ex Foobar:ghp_dsq5F6ug775zHjif975

> At the end of installation, there is a token printed. You need to save, and set it in the ctf config
