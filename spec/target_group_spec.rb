require 'spec_helper'

describe 'Target Group' do
  let(:component) {vars.component}
  let(:deployment_identifier) {vars.deployment_identifier}

  let(:name) {output_for(:harness, 'target_group_name')}
  let(:arn) {output_for(:harness, 'target_group_arn')}
  let(:vpc) {output_for(:harness, 'vpc_id')}
  let(:nlb) {output_for(:harness, 'name')}

  subject {nlb_target_group(name)}

  it {should exist}

  # it { should belong_to_nlb(nlb) }
  it {should belong_to_vpc(vpc)}

  its(:protocol) {should eq vars.target_group_protocol}
  its(:port) {should eq vars.target_group_port.to_i}
  its(:target_type) {should eq vars.target_group_type}

  context 'healthcheck' do
    its(:health_check_protocol) {should eq vars.health_check_protocol}
    its(:health_check_port) {should eq vars.health_check_port.to_i}
    its(:health_check_interval_seconds) {should eq vars.health_check_interval}
  end

  context 'tags' do
    subject do
      elbv2_client
          .describe_tags(resource_arns: [arn])
          .tag_descriptions[0]
          .tags
          .map(&:to_h)
    end

    it {should include({key: 'Name',
                        value: "tg-#{component}-#{deployment_identifier}"})}
    it {should include({key: 'Component', value: component})}
    it {should include({key: 'DeploymentIdentifier',
                        value: deployment_identifier})}
  end
end
