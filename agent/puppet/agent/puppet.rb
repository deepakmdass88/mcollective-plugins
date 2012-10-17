module MCollective
  module Agent
    class Puppet<RPC::Agent
      activate_when do
        gem "puppet_agent_mgr", ">= 0.0.7"
        require 'puppet_agent_mgr'
        true
      end

      attr_reader :puppet_agent, :puppet_command, :puppet_splaylimit

      def startup_hook
        @puppet_agent = PuppetAgentMgr.manager
        @puppet_command = @config.pluginconf.fetch("puppet.command", "puppet agent")
        @puppet_splaylimit = Integer(@config.pluginconf.fetch("puppet.splaylimit", 30))
        @puppet_splay = @config.pluginconf.fetch("puppet.splay", "true")
      end

      action "disable" do
        begin
          msg = @puppet_agent.disable!(request.fetch(:message, "Disabled via MCollective by %s at %s local time" % [request.caller, Time.now]))
          reply[:status] = "Succesfully locked the Puppet agent: %s" % msg
        rescue => e
          reply.fail! "Could not disable Puppet: %s" % e.to_s
        end
      end

      action "enable" do
        begin
          @puppet_agent.enable!
        rescue => e
          reply.fail! "Could not enable Puppet: %s" % e.to_s
        end

        reply[:status] = "Succesfully enabled the Puppet agent"
      end

      action "last_run_summary" do
        summary = @puppet_agent.load_summary

        reply[:out_of_sync_resources] = summary["resources"].fetch("out_of_sync", 0)
        reply[:failed_resources] = summary["resources"].fetch("failed", 0)
        reply[:changed_resources] = summary["resources"].fetch("changed", 0)
        reply[:total_resources] = summary["resources"].fetch("total", 0)
        reply[:total_time] = summary["time"].fetch("total", 0)
        reply[:config_retrieval_time] = summary["time"].fetch("config_retrieval", 0)
        reply[:lastrun] = Integer(summary["time"].fetch("last_run", 0))
        reply[:since_lastrun] = Integer(Time.now.to_i - reply[:lastrun])
        reply[:config_version] = summary["version"].fetch("config", "unknown")
        reply[:summary] = summary
      end

      action "status" do
        status = @puppet_agent.status

        @reply.data.merge!(status)
      end

      action "runonce" do
        args = {}

        args[:options_only] = true
        args[:noop] = true if request[:noop]
        args[:environment] = request[:environment] if request[:environment]
        args[:server] = request[:server] if request[:server]
        args[:tags] = request[:tags].split(",").map{|t| t.strip} if request[:tags]
        args[:splay] = true if request[:splay] == true
        args[:splay] = false if request[:splay] == false
        args[:splaylimit] = request[:splaylimit] if request[:splaylimit]

        unless args.include?(:splay)
          args[:splay] = true if @puppet_splay =~ /^1|true|yes/
          args[:splay] = false if @puppet_splay =~ /^0|false|no/
        end

        if !args.include?(:splaylimit) && args[:splay]
          args[:splaylimit] = @puppet_splaylimit
        end

        run_method, options = @puppet_agent.runonce!(args)
        command = [@puppet_command].concat(options).join(" ")

        case run_method
          when :run_in_background
            Log.debug("Initiating a background puppet agent run using the command: %s" % command)
            exitcode = run(command, :stdout => :summary, :stderr => :summary, :chomp => true)
            reply.fail!("Puppet command '%s' had exit code %d, expected 0" % [command, exitcode]) unless exitcode == 0

          when :signal_running_daemon
            Log.debug("Signaling the running Puppet agent to start an immediate run")
            @puppet_agent.signal_running_daemon

          else
            reply.fail!("Do not know how to do puppet runs using method %s" % run_method)
        end
      end
    end
  end
end
