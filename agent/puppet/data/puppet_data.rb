module MCollective
  module Data
    class Puppet_data<Base
      activate_when do
        gem "puppet_agent_mgr", ">= 0.0.7"
        require 'puppet_agent_mgr'
        true
      end

      query do |resource|
        puppet_agent = PuppetAgentMgr.manager
        status = puppet_agent.status

        [:applying, :enabled, :daemon_present, :lastrun, :since_lastrun, :status, :disable_message].each do |item|
          result[item] = status[item]
        end
      end
    end
  end
end


