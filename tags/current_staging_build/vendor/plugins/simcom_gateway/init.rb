require 'simcom/device'
require 'simcom/device_config'
require 'simcom/command_request'

simcom_spec = YAML::load_file("#{RAILS_ROOT}/config/simcom_gateway.yml")[ENV["RAILS_ENV"]]
Simcom::Device.establish_connection(simcom_spec)
Simcom::DeviceConfig.establish_connection(simcom_spec)
Simcom::CommandRequest.establish_connection(simcom_spec)
