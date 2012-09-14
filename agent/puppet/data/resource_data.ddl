metadata    :name        => "resource",
            :description => "Information about Puppet managed resources",
            :author      => "R.I.Pienaar <rip@devco.net>",
            :license     => "ASL 2.0",
            :version     => "1.1",
            :url         => "http://puppetlabs.com/",
            :timeout     => 1

dataquery :description => "Puppet Managed Resources" do
    input :query,
          :prompt => "Resource Name",
          :description => "Valid resource name",
          :type => :string,
          :validation => /^.+$/,
          :optional => true,
          :maxlength => 120

    output :managed,
           :description => "Is the resource managed",
           :display_as => "Managed",
           :default => false

    output :out_of_sync_resources,
           :description => "Resources that were not in desired state",
           :display_as  => "Out of Sync Resources",
           :default     => -1

    output :failed_resources,
           :description => "Resources that failed to apply",
           :display_as  => "Failed Resources",
           :default     => -1

    output :changed_resources,
           :description => "Resources that were changed",
           :display_as  => "Changed Resources",
           :default     => -1

    output :total_resources,
           :description => "Total resources managed on a node",
           :display_as  => "Total Resources",
           :default     => 0

    output :total_time,
           :description => "Total time taken to retrieve and process the catalog",
           :display_as  => "Total Time",
           :default     => 0

    output :config_retrieval_time,
           :description => "Time taken to retrieve the catalog from the master",
           :display_as  => "Config Retrieval Time",
           :default     => -1

    output :lastrun,
           :description => "When the Agent last applied a catalog in local time",
           :display_as  => "Last Run",
           :default     => 0

    output :since_lastrun,
           :description => "How long ago did the Agent last apply a catalog in local time",
           :display_as  => "Since Last Run",
           :default     => "Unknown"

    output :config_version,
           :description => "Puppet config version for the previously applied catalog",
           :display_as  => "Config Version",
           :default     => nil
end
