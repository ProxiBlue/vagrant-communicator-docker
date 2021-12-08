# Vagrant::Communicator::Docker

This is a communicator plugin allowing vagrant to access docker instances as if they have SSH.

This was created to facilitate host file management using a vagrant host file manager plugin, which requires SSH to fetch, 
edit, and put back container hosts files. The assumption that vagrant SSH communicator makes, is that all containers
have SSH - They do not.

This communicator will make vagrant tasks that require SSH, interact with the docker instances, as if SSH exists, by 
using the Docker API.

This has only been used in a Linux environment.

## Requirements

* Docker API gem: ```vagrant plugin install docker-api```

If you get an error noted as: ```undefined method `copy' for...``` please use : ```vagrant plugin install docker-api --plugin-version=1.34.2```

## Installation

Needs to be installed as a vagrant plugin

```
vagrant plugin install vagrant-communicator-docker
```

### Manual install

* fetch the built gem package located here: ```https://raw.githubusercontent.com/ProxiBlue/vagrant-communicator-docker/master/communicator-docker-1.0.6.gem```
* install using: ```vagrant plugin install communicator-docker-1.0.6.gem```

```
curl https://raw.githubusercontent.com/ProxiBlue/vagrant-communicator-docker/master/communicator-docker-1.0.6.gem > communicator-docker-1.0.6.gem
```

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

## Limitations

Communicates with a local docker service via linux sockets. That is all I need.
Should be able to be extended to include a docker connection string to a tcp connection, but I have no need for that as yet, so not implemented.

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
