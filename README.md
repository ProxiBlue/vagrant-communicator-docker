# Vagrant::Communicator::Docker

This is a communicator plugin allowing vagrant to access docker instances as if they have SSH.

This was created to facilitate host file management using a vagrant host file manager plugin, which requires SSH to fetch, 
edit, and put back container hosts files. The assumption that vagrant SSH communicator makes, is that all containers
have SSH - They do not.

This communicator will make vagrant tasks that require SSH, to interact with the docker instances, as if SSH exists.

## Installation

Needs to be installed as a vagrant plugin

* fetch the built package located here: 

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install communicatordocker

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/vagrant-communicator-docker.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
