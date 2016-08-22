# Screeps ELK

Screeps ELK is a service that mirrors what good folks at [Screep Stats](https://github.com/screepers/screeps-stats)
are doing, but instead having the data from screeps pulled by python
scripts that handle inputs, filtering and outputs, I've broken
it down to use logstash pipeline for processing. It can be easily
deployed either via vagrant or to most ubuntu boxes.

# Features

* Integrated [screeps-stats](https://github.com/screepers/screeps-stats)
* Integrated processing of data coming from enhanced logger
* Binding profiler outputs into single documents (search for `Avg`)
* Easy to modify and extend processing pipeline allowing for easy 
creation of parsers to extract data from your logs.
* All the fluff that comes with Kibana (pretty graphs!).

## Enhanced logger
The default processing pipeline is set to extract values from contextual
logger in this repo (installation details down below). What it does is 
provide a `log` function to all objects/rooms with the idea of it 
replacing the need for `console.log`. 
For example calling it on a creep with: `creep.log('Hello')` will 
generate:

```13037522 (Debug)[E32S35][creep][57bb30eb3d1bca354681271f]: Hello```

Adding to the message, in the right order, current tick, severity
(which defaults to Debug when none specified), room name in which the
creep was, type of the caller, it's ID and, finally the actuall message
that was called.

Similarly if we call `Game.rooms['E34S32'].log('hello')` it will produce
similar log entry, but with one notable difference that ID will remain
as `undefined` because rooms don't have IDs.

```13037559 (Debug)[E34S32][room][undefined]: hello```

This data format is automatically parsed by logstash into useful bits, 
so those messages are then parsed into a following document:

```  
  "_source": {
    "message": "13037522 (Debug)[E32S35][creep][57bb30eb3d1bca354681271f]: Hello",
    "@version": "1",
    "@timestamp": "2016-08-22T17:59:17.342Z",
    "host": "screeps-elk",
    "command": "/usr/bin/python /opt/screeps-elk/log_stream.py",
    "type": "screeps-console",
    "message_type": "logline",
    "tick": 13037522,
    "severity": "Debug",
    "room": "E32S35",
    "caller_type": "creep",
    "caller_id": "57bb30eb3d1bca354681271f",
    "content": "Hello"
  },
```

Which will then allow for us to do quick searches and visualisation of
those messages, without having to remember to include that in message
itself.

### Extending enhanced logger
Big benefit of going with logstash rather than the python import scripts
is it's flexibility of processing data. Let's say that your spawners
log something like this: `Spawning new 'builder', creeps in queue: 9`
where builder is a role and 9 is queue length and you want this data
extracted, searchable and to be able to filter by it. 
And we can do that, very easily. All it would take is to create a file
`15-filter-spawnlogs.conf` with content:

```
filter {
    if [message_type] == "screeps-console" {
        grok {
            patterns_dir => "/opt/screeps-elk/patterns"
            match => [ "content", "\ASpawning new '%{WORD:role}', creeps in queue: %{BASE10NUM:queueLength:int}" ]
        }
    }
}
```

Save it in `/etc/logstash/conf.d` directory, restart logstash with 
`sudo service logstash restart` and from now on those messages will be 
broken down and variables extracted according to the pattern.
This data can be then, for example, used in kibana to [put on a graph
with just few clicks, but for that check the documentation](https://www.elastic.co/guide/en/kibana/current/introduction.html).

## Setup

### Configuration

Copy the file `settings.py.template` into `settings.py` and fill it in
with your screeps credentials.

#### Optional: change the default http credentials
By default you will be able to login to kibana with:
username: `screepskibana`
password: `7PHOJee9dsSQx1taEVTIeGgGO9coUx`

This isn't exactly secureas this repository is public, so you should 
generate your own `htpasswd` to protect kibana with safer login and 
password. You can generate it with [help of online tools](http://www.htaccesstools.com/htpasswd-generator/)
and then simply replace content of `/etc/nginx/htpasswd` in this project
with the newly generated one.

### Installation
At current state of affairs I highly recommend the vagrant route as the
bash script has absolutely zero error handling, or even printing whether
it all worked fine. It will receive proper ansible provisioning in near
future that will improve the situation greatly.

It's worth noting that this will require at least 2 gb of ram to perform
properly due to heavy java footprint (squeeze in 1gb may be possible
but it is not recommended).

#### Vagrant
1. Install [vagrant](https://www.vagrantup.com/) and [virtualbox](https://www.virtualbox.org/) 
or [hyper-v](https://technet.microsoft.com/en-us/library/mt169373%28v=ws.11%29.aspx?f=255&MSPPError=-2147217396).
2. Run `vagrant up` and wait for it to finish.
3. Navigate to [http://127.0.0.1:8080](http://127.0.0.1:8080) and login
 with whatever details were used to generate `htpasswd` file, or the
 default ones, as outlined in the optional section above.
 
#### Ubuntu box installer
1. Copy over the entire project into `/opt/screeps-elk` (flexibility
coming soon™).
2. Navigate to `/opt/screeps-elk` and run `bash installer.sh`
3. Wait for it to finish, hoping that nothing crashed.
4. Try to navigate to servers public ip at port 8080, should be asked
for credentials, and then see kibana.

### Screeps-side set-up

#### Enhanced Screeps Stats
Please follow the [guide in screep stats repository](https://github.com/screepers/screeps-stats/blob/master/README.md#enhanced-screeps-stats-collection)

#### Enhanced logging
In order to fully leverage the existing pipeline you should install and
use the enchanced logger. To do that copy file `utils.logger.js` from 
`js` directory into your screeps folder and ad the top of your main file
add `require('utils.logger');`.

With that done every single in game object will have a command `log()`
available which it is recommended to use in lieu of `console.log` as
it provides contextual data on object which called it.
