# Vagrant::Communicator::Docker

This is a communicator plugin allowing vagrant to access docker instances as if they have SSH.

This was created to facilitate host file management using a vagrant host file manager plugin, which requires SSH to fetch, 
edit, and put back container hosts files. The assumption that vagrant SSH communicator makes, is that all containers
have SSH - They do not.

This communicator will make vagrant tasks that require SSH, interact with the docker instances, as if SSH exists, by 
using the Docker API.

Shell scripts used during provisioning will also be executed, so will facilitate provisioning shel scripts as well (from 1.0.8).
Please note that these will always run as root inside the docker instance.

This has only been used in a Linux environment.

## Requirements

* Docker API gem, which will install as a dependency.

## Installation

Needs to be installed as a vagrant plugin

```
vagrant plugin install vagrant-communicator-docker
```

### Manual install

* install using: ```vagrant plugin install vagrant-communicator-docker-[version].gem```
* install dependency ```vagrant plugin install docker-api``` (must be version 2.0.0 or greater)


## Usage

* You need to set your vagrant instance to have SSH using ```has_ssh```
* You need to set the communicator using ```vm.communicator = 'docker'```
* You can set the shell to use with ```vm.communicator.bash_shell```
* You can set the shell wait with ```vm.communicator.bash_wait```

Example vagrant definition:

```
config.vm.define "database", primary: false do |database|
        database.hostmanager.aliases = [ "database."+dev_domain ]
        database.vm.network :private_network, ip: "172.20.0.208", subnet: "172.20.0.0/16"
        database.vm.hostname = "database"
        database.vm.communicator = 'docker'
        database.vm.provider 'docker' do |d|
            d.image = "mysql:5.7"
            d.has_ssh = true
            d.name = "database"
            d.remains_running = true
        end
    end
```

## Communication over TCP with remote Docker

By default the communicator connects with Docker over a local socket. You can override this, and allow remote Docker connection by setting an environment variable:

```DOCKER_HOST=tcp://[DOCKER HOST]:[PORT]```

example:

```DOCKER_HOST=tcp://127.0.0.1:2375``` vagrant up

## Shell

The default shell will be /bin/bash inside the docker container. You can override this using : ```vm.communicator.bash_shell = '/bin/sh';``` to use /bin/sh (or any other shell)

If you get the error:

```
The guest operating system of the machine could not be detected!
Vagrant requires this knowledge to perform specific tasks such
as mounting shared folders and configuring networks. Please add
the ability to detect this guest operating system to Vagrant
by creating a plugin or reporting a bug.

```

you likely need to change the shell to /bin/sh OR increase the shell_wait (default is 10)

## shell_wait

I have found some docker instances need a little extra time to initialise, before docker can send commands
The default wait timeout is 10s. Increase in increments of 5 to see if you can overcome issue.

## Solved issues?

Not had this for some time, so I think solved due to ongoing changes.

### Problems with some docker images, failing with message that image is not running

I have not managed to spend time on this, to pin it down, but some (random) docker images will fail if you set ```d.has_ssh = true``` - The only fix is to set that to false, which can stop other functions (example usage of a hostmanager plugin)

You can run a global trigger to overcome this, allowing hostmanagers to update after it was completed:

```
config.trigger.after :up do |trigger|
   trigger.run = {inline: "bash -c 'vagrant hostmanager --provider docker'"}
end
```

## Debug

```vagrant halt database && vagrant up database --debug &>/tmp/debug.log``` then view the debug log.

You will see debug entries with the string: ```DOCKER COMMUNICATOR``` 

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ProxiBlue/vagrant-communicator-docker.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
