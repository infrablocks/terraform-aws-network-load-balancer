require 'spec_helper'

describe 'NLB' do
  let(:component) {vars.component}
  let(:deployment_identifier) {vars.deployment_identifier}

  let(:name) {output_for(:harness, 'name')}
  let(:arn) {output_for(:harness, 'arn')}

  subject {nlb(name)}

  it {should exist}
  # its(:subnets) {should contain_exactly(*output_for(:prerequisites, 'subnet_ids').split(','))}
  its(:scheme) {should eq('internal')}

  # its(:canonical_hosted_zone_name_id) {should eq output_for(:harness, 'zone_id')}

  context 'tags' do
    subject do
      elbv2_client
          .describe_tags(resource_arns: [arn])
          .tag_descriptions[0]
          .tags
          .map(&:to_h)
    end

    it {should include({key: 'Name',
                        value: "nlb-#{component}-#{deployment_identifier}"})}
    it {should include({key: 'Component', value: component})}
    it {should include({key: 'DeploymentIdentifier',
                        value: deployment_identifier})}
  end

  context 'attributes' do
    subject do
      elbv2_client
          .describe_load_balancer_attributes(load_balancer_arn: arn)
          .map(&:to_h)[0][:attributes]
          .map{|x | Hash[x[:key], x[:value]]}
          .reduce({}, :merge)
    end

    let(:cross_zone_enabled) { vars.enable_cross_zone_load_balancing == 'no' }

    it 'uses the provided flag for cross zone load balancing' do
      expect(subject['load_balancing.cross_zone.enabled']).to eq('false')
    end

    it 'uses the provided flag for cross zone load balancing' do
      expect(subject['access_logs.s3.enabled']).to eq('false')
    end
    it 'uses the provided flag for cross zone load balancing' do
      expect(subject['access_logs.s3.prefix']).to eq('')
    end

    it 'uses the provided flag for cross zone load balancing' do
      expect(subject['deletion_protection.enabled']).to eq('false')
    end
  end
end