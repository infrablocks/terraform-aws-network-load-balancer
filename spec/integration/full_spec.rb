# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
describe 'full' do
  let(:component) do
    var(role: :full, name: 'component')
  end
  let(:deployment_identifier) do
    var(role: :full, name: 'deployment_identifier')
  end
  let(:domain_name) do
    var(role: :full, name: 'domain_name')
  end
  let(:public_zone_id) do
    var(role: :full, name: 'public_zone_id')
  end
  let(:private_zone_id) do
    var(role: :full, name: 'private_zone_id')
  end
  let(:name) do
    output(role: :full, name: 'name')
  end
  let(:arn) do
    output(role: :full, name: 'arn')
  end
  let(:subnet_ids) do
    output(role: :full, name: 'subnet_ids')
  end
  let(:vpc_cidr) do
    output(role: :full, name: 'vpc_cidr')
  end
  let(:vpc_id) do
    output(role: :full, name: 'vpc_id')
  end

  before(:context) do
    apply(role: :full)
  end

  after(:context) do
    destroy(
      role: :full,
      only_if: -> { !ENV['FORCE_DESTROY'].nil? || ENV['SEED'].nil? }
    )
  end

  describe 'NLB' do
    subject(:load_balancer) { nlb(name) }

    it { is_expected.to exist }

    it 'uses the provided subnets' do
      subnet_ids = output(role: :full, name: 'subnet_ids')
      subnet_ids.each do |subnet_id|
        expect(load_balancer).to(have_subnet(subnet_id))
      end
    end

    its(:scheme) { is_expected.to(eq('internet-facing')) }

    its(:canonical_hosted_zone_id) do
      is_expected.to(eq(output(role: :full, name: 'zone_id')))
    end

    describe 'tags' do
      subject(:tags) do
        elbv2_client
          .describe_tags(resource_arns: [arn])
          .tag_descriptions[0]
          .tags
          .map(&:to_h)
      end

      it {
        expect(tags)
          .to(include(
                key: 'Name',
                value: "nlb-#{component}-#{deployment_identifier}"
              ))
      }

      it {
        expect(tags)
          .to(include(
                key: 'Component',
                value: component
              ))
      }

      it {
        expect(tags)
          .to(include(
                key: 'DeploymentIdentifier',
                value: deployment_identifier
              ))
      }
    end

    describe 'attributes' do
      subject(:attributes) do
        elbv2_client
          .describe_load_balancer_attributes(load_balancer_arn: arn)
          .map(&:to_h)[0][:attributes]
          .map { |x| { x[:key] => x[:value] } }
          .reduce({}, :merge)
      end

      it 'does not enable cross zone load balancing' do
        expect(attributes['load_balancing.cross_zone.enabled'])
          .to(eq('false'))
      end
    end
  end

  describe 'DNS records' do
    let(:load_balancer) { nlb(name) }

    let(:public_hosted_zone) do
      route53_hosted_zone(public_zone_id)
    end

    let(:private_hosted_zone) do
      route53_hosted_zone(private_zone_id)
    end

    it 'outputs the address' do
      expect(output(role: :full, name: 'address'))
        .to(eq("#{component}-#{deployment_identifier}.#{domain_name}"))
    end

    it 'creates a public DNS entry' do
      expect(public_hosted_zone)
        .to(have_record_set(
          "#{component}-#{deployment_identifier}.#{domain_name}."
        )
              .alias(
                "#{load_balancer.dns_name}.",
                load_balancer.canonical_hosted_zone_id
              ))
    end

    it 'creates a private DNS entry' do
      expect(private_hosted_zone)
        .to(have_record_set(
          "#{component}-#{deployment_identifier}.#{domain_name}."
        )
              .alias(
                "#{load_balancer.dns_name}.",
                load_balancer.canonical_hosted_zone_id
              ))
    end
  end

  describe 'listener' do
    subject(:listener) { nlb_listener(listener_arn) }

    let(:listener_arn) do
      listeners = output(role: :full, name: 'listeners')
      listeners[:default][:arn]
    end
    let(:certificate_arn) do
      output(role: :full, name: 'certificate_arn')
    end

    it { is_expected.to(exist) }

    its(:port) do
      is_expected.to(eq(443))
    end

    its(:protocol) do
      is_expected.to(eq('TLS'))
    end

    it 'uses the provided certificate' do
      expect(listener.certificates.collect(&:certificate_arn))
        .to(eq([certificate_arn]))
    end
  end

  describe 'target group' do
    subject(:target_group) { nlb_target_group(target_group_name) }

    let(:load_balancer) { nlb(name) }
    let(:target_group_details) do
      output(role: :full, name: 'target_groups')
    end
    let(:target_group_name) { target_group_details[:default][:name] }
    let(:target_group_arn) { target_group_details[:default][:arn] }

    it { is_expected.to exist }

    it { is_expected.to belong_to_nlb(name) }
    it { is_expected.to belong_to_vpc(vpc_id) }

    its(:protocol) do
      is_expected.to(eq('TCP'))
    end

    its(:port) do
      is_expected.to(eq(80))
    end

    its(:target_type) do
      is_expected.to(eq('instance'))
    end

    describe 'healthcheck' do
      its(:health_check_protocol) do
        is_expected.to(eq('HTTP'))
      end

      its(:health_check_port) do
        is_expected.to(eq('80'))
      end

      its(:health_check_interval_seconds) do
        is_expected.to(eq(30))
      end
    end

    describe 'tags' do
      subject(:tags) do
        elbv2_client
          .describe_tags(resource_arns: [target_group_arn])
          .tag_descriptions[0]
          .tags
          .map(&:to_h)
      end

      it {
        expect(tags)
          .to(include(
                key: 'Name',
                value: "#{component}-#{deployment_identifier}-80-TCP"
              ))
      }

      it {
        expect(tags)
          .to(include(
                key: 'Component',
                value: component
              ))
      }

      it {
        expect(tags)
          .to(include(
                key: 'DeploymentIdentifier',
                value: deployment_identifier
              ))
      }
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
