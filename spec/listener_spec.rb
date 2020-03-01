require 'spec_helper'

describe 'Listener' do
  let(:component) {vars.component}
  let(:deployment_identifier) {vars.deployment_identifier}

  let(:listener) {output_for(:harness, 'listener_arn')}
  let(:certificate) {output_for(:prerequisites, 'certificate_arn')}

  subject {nlb_listener(listener)}

  it {should exist}
  its(:port) {should eq vars.listener_port.to_i}
  its(:protocol) {should eq vars.listener_protocol}
  # its(:certificates) {should eq certificate}
end
