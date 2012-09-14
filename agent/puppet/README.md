# Overview
This is an early attempt at writing a Puppet 2 and 3 compatible agent to manage
Puppet.

At present there is no application plugin yet, all interaction is via the RPC
application.

The main improvements over the old *puppetd* agent are:

  * Supports noop runs or no-noop runs
  * Supports limiting runs to certain tags
  * Support splay, no splay, splaylimits
  * Supports specifying a custom environment
  * Supports specifying a custom master host and port
  * Support Puppet 3 features like lock messages when disabling
  * Use the new summary plugins to provide convenient summaries where appropriate
  * Use the new validation plugins to provider richer input validation and better errors
  * Data sources for the current puppet agent status and the status of the most recent run

To use this agent you need:

  * MCollective 2.2.0 at least
  * Puppet 2.7 or 3.0
  * The *puppet_agent_mgr* rubygem >= 0.0.7

# TODO

  * Add an application plugin
  * Improve the formating of stats once 2.2.1 is out
  * Add aggregation for the boolean stats once 2.2.1 is out
  * Figure out what will happen with the *puppet_agent_mgr* gem

# Configuring the agent

By default it just works but there are a few settings you can tweak in *server.cfg*:

   plugin.puppet.command=puppet agent
   plugin.puppet.splay=true
   plugin.puppet.splaylimit=30

These are the defaults, adjust to taste

# Running Puppet

Most basic case is just a run:

    $ mco rpc puppet runonce

...against a specific server and port:

    $ mco rpc puppet runonce server=some_host:1234

...just some tags

    $ mco rpc puppet runonce tags=one,two,three

...a noop run

    $ mco rpc puppet runonce noop=true

...a actual run when noop is set in the config file

    $ mco rpc puppet runonce noop=false

...in a specific environment

    $ mco rpc puppet runonce environment=development

...a splay run

    $ mco rpc puppet runonce splay=true splaylimit=120

...or if you have splay on by default and do not want to splay

    $ mco rpc puppet runonce splay=false

These can all be combined to your liking

# Requesting agent status

The status of the agent can be obtained:

    $ mco rpc puppet status
    Discovering hosts using the mc method for 2 second(s) .... 1

     * [ ============================================================> ] 1 / 1


    devco.net-0
             Applying: false
       Daemon Running: false
         Lock Message:
              Enabled: true
             Last Run: 1348745262
              message: Currently stopped; last completed run 2 hours 03 minutes 19 seconds ago
              Summary: unknown
       Since Last Run: 7399
               Status: stopped


    Summary of Status:

        stopped = 1


    Finished processing 1 / 1 hosts in 46.88 ms

Note the summary at the end showing aggregated information about your daemons,
more data points will be added soon as MCollective 2.2.1 is out

# Requesting last run status

This too build aggregate stats of the status of your estate, the format will improve
when 2.2.1 is out:

    $ mco rpc puppet last_run_summary
    Discovering hosts using the mc method for 2 second(s) .... 1

     * [ ============================================================> ] 1 / 1


    devco.net-0
           Changed Resources: 0
       Config Retrieval Time: 0.040953
              Config Version: 1348745261
            Failed Resources: 0
                    Last Run: 1348745262
       Out of Sync Resources: 0
              Since Last Run: 7477
                     Summary: {"time"=>
                                {"total"=>0.041138,
                                 "config_retrieval"=>0.040953,
                                 "filebucket"=>0.000185,
                                 "last_run"=>1348745262},
                               "changes"=>{"total"=>0},
                               "resources"=>
                                {"total"=>7,
                                 "failed"=>0,
                                 "changed"=>0,
                                 "restarted"=>0,
                                 "scheduled"=>0,
                                 "failed_to_restart"=>0,
                                 "skipped"=>6,
                                 "out_of_sync"=>0},
                               "version"=>{"config"=>1348745261, "puppet"=>"2.7.17"},
                               "events"=>{"total"=>0, "success"=>0, "failure"=>0}}
             Total Resources: 7
                  Total Time: 0.041138


    Summary of Config Retrieval Time:

    Average of config_retrieval_time: 0.040953

    Summary of Total Resources:

    Average of total_resources: 7.000000

    Summary of Total Time:

    Average of total_time: 0.041138

    Finished processing 1 / 1 hosts in 45.04 ms

# Enabling and disabling

Puppet 3 supports a message when enabling and disableing

    $ mco rpc puppet disable message="doing some hand hacking"
    $ mco rpc puppet enable

The message will be displayed when requesting agent status if it is disabled,
when no message is supplied a default will be used that will include your
mcollective caller identity and the time

# Discovering based on agent status

Two data plugins are provided, to see what data is available about the running
agent do:

    $ mco rpc rpcutil get_data source=puppet query=.
    Discovering hosts using the mc method for 2 second(s) .... 1

     * [ ============================================================> ] 1 / 1


    devco.net-0
              applying: false
        daemon_present: false
       disable_message:
               enabled: true
               lastrun: 1348745262
         since_lastrun: 7776
                status: stopped

    Finished processing 1 / 1 hosts in 76.34 ms

You can then use any of this data in discovery, to restart apache on machines
with Puppet disable can now be done easily:

    $ mco rpc service restart service=httpd -S "puppet().enabled=false"

# Discovery based on most recent run

You can restart apache on all machine that has File[/srv/www] managed by Puppet:

    $ mco rpc service restart service=httpd -S "resource('file[/srv/wwww]').managed=true"

...or machines that had many changes in the most recent run:

    $ mco rpc service restart service=httpd -S "resource().changed_resources>10"

...or that had failures

    $ mco rpc service restart service=httpd -S "resource().failed_resources>0"

Other available data include config_retrieval_time, config_version, lastrun,
out_of_sync_resources, since_lastrun, total_resources and total_time


