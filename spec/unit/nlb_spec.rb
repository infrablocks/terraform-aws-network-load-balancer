# frozen_string_literal: true

require 'spec_helper'

describe 'NLB' do
  let(:subnet_ids) do
    output(role: :prerequisites, name: 'subnet_ids')
  end
  let(:component) do
    var(role: :root, name: 'component')
  end
  let(:deployment_identifier) do
    var(role: :root, name: 'deployment_identifier')
  end

  describe 'by default' do
    before(:context) do
      @plan = plan(role: :root)
    end

    it 'creates a load balancer' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_lb')
              .once)
    end

    it 'uses a load balancer type of network' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_lb')
              .with_attribute_value(:load_balancer_type, 'network'))
    end

    it 'uses the provided subnets' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_lb')
              .with_attribute_value(:subnets, match_array(subnet_ids)))
    end

    it 'marks the load balancer as internal' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_lb')
              .with_attribute_value(:internal, true))
    end

    it 'disables cross zone load balancing' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_lb')
              .with_attribute_value(:enable_cross_zone_load_balancing, false))
    end

    it 'does not enable deletion protection' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_lb')
              .with_attribute_value(:enable_deletion_protection, false))
    end

    it 'does not enable access logs' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_lb')
                  .with_attribute_value([:access_logs, 0, :enabled], true))
    end

    it 'adds tags to the load balancer' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_lb')
              .with_attribute_value(
                :tags, {
                  Name: "nlb-#{component}-#{deployment_identifier}",
                  Component: component,
                  DeploymentIdentifier: deployment_identifier
                }
              ))
    end

    it 'outputs the load balancer name' do
      expect(@plan)
        .to(include_output_creation(name: 'name'))
    end

    it 'outputs the load balancer ARN' do
      expect(@plan)
        .to(include_output_creation(name: 'arn'))
    end

    it 'outputs the load balancer ARN suffix' do
      expect(@plan)
        .to(include_output_creation(name: 'arn_suffix'))
    end

    it 'outputs the load balancer ID' do
      expect(@plan)
        .to(include_output_creation(name: 'id'))
    end

    it 'outputs the load balancer VPC ID' do
      expect(@plan)
        .to(include_output_creation(name: 'vpc_id'))
    end

    it 'outputs the load balancer zone ID' do
      expect(@plan)
        .to(include_output_creation(name: 'zone_id'))
    end

    it 'outputs the load balancer DNS name' do
      expect(@plan)
        .to(include_output_creation(name: 'dns_name'))
    end
  end

  describe 'when expose_to_public_internet is true' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.expose_to_public_internet = true
      end
    end

    it 'marks the load balancer as internet-facing' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_lb')
              .with_attribute_value(:internal, false))
    end
  end

  describe 'when expose_to_public_internet is false' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.expose_to_public_internet = false
      end
    end

    it 'marks the load balancer as internal' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_lb')
              .with_attribute_value(:internal, true))
    end
  end

  describe 'when enable_cross_zone_load_balancing is true' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.enable_cross_zone_load_balancing = true
      end
    end

    it 'enables cross zone load balancing' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_lb')
              .with_attribute_value(:enable_cross_zone_load_balancing, true))
    end
  end

  describe 'when enable_cross_zone_load_balancing is false' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.enable_cross_zone_load_balancing = false
      end
    end

    it 'disables cross zone load balancing' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_lb')
              .with_attribute_value(:enable_cross_zone_load_balancing, false))
    end
  end

  describe 'when enable_deletion_protections is true' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.enable_deletion_protection = true
      end
    end

    it 'enables deletion protection' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_lb')
              .with_attribute_value(:enable_deletion_protection, true))
    end
  end

  describe 'when enable_deletion_protection is false' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.enable_deletion_protection = false
      end
    end

    it 'does not enable deletion protection' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_lb')
              .with_attribute_value(:enable_deletion_protection, false))
    end
  end

  describe 'when enable_access_logs is true' do
    let(:access_logs_bucket_name) do
      output(role: :prerequisites, name: 'access_logs_bucket_name')
    end

    let(:access_logs_bucket_prefix) do
      output(role: :prerequisites, name: 'access_logs_bucket_prefix')
    end

    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.enable_access_logs = true
        vars.access_logs_bucket_name =
          output(role: :prerequisites, name: 'access_logs_bucket_name')
        vars.access_logs_bucket_prefix =
          output(role: :prerequisites, name: 'access_logs_bucket_prefix')
      end
    end

    it 'enables deletion protection' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_lb')
              .with_attribute_value([:access_logs, 0, :enabled], true))
    end

    it 'uses the provided access logs bucket name' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_lb')
              .with_attribute_value(
                [:access_logs, 0, :bucket], access_logs_bucket_name
              ))
    end

    it 'uses the provided access logs bucket prefix' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_lb')
              .with_attribute_value(
                [:access_logs, 0, :prefix], access_logs_bucket_prefix
              ))
    end
  end

  describe 'when enable_access_logs is false' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.enable_access_logs = false
      end
    end

    it 'does not enable deletion protection' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_lb')
              .with_attribute_value([:access_logs, 0, :enabled], true))
    end
  end
end
