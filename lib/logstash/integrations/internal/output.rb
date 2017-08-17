class ::LogStash::Integrations::Internal::Output < ::LogStash::Outputs::Base
  config_name "internal"

  config :send_to, :validate => :string, :required => true, :list => true

  def register
    ::LogStash::Integrations::Internal.register_sender(self, @send_to)
  end

  BLOCKED_LOG_MESSAGE = "Internal output to address waiting for listener to start"
  def multi_receive(events)
    @send_to.each do |address|
      while !::LogStash::Integrations::Internal.send_to(address, events)
        sleep 1
        @logger.info(
          BLOCKED_LOG_MESSAGE,
          :destination_address => address,
          :registered_addresses => ::LogStash::Integrations::Internal.addresses_by_run_state
        )
      end
    end
  end

  def close
    ::LogStash::Integrations::Internal.unregister_sender(self, @send_to)
  end
end