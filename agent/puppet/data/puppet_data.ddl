metadata    :name        => "puppet",
            :description => "Information about Puppet agent state",
            :author      => "R.I.Pienaar <rip@devco.net>",
            :license     => "ASL 2.0",
            :version     => "1.1",
            :url         => "http://puppetlabs.com/",
            :timeout     => 1

dataquery :description => "Puppet Agent state" do
    output :applying,
           :description => "Is a catalog being applied",
           :display_as  => "Applying",
           :default     => false

    output :enabled,
           :description => "Is the agent currently locked",
           :display_as  => "Enabled",
           :default     => false

    output :daemon_present,
           :description => "Is the Puppet agent daemon running on this system",
           :display_as  => "Daemon Running",
           :default     => false

    output :lastrun,
           :description => "When the Agent last applied a catalog in local time",
           :display_as  => "Last Run",
           :default     => 0

    output :since_lastrun,
           :description => "How long ago did the Agent last apply a catalog in local time",
           :display_as  => "Since Last Run",
           :default     => "Unknown"

    output :status,
           :description => "Current status of the Puppet agent",
           :display_as  => "Status",
           :default     => "unknown"

    output :disable_message,
           :description => "Message supplied when agent was disabled",
           :display_as  => "Lock Message",
           :default     => ""
end
