# frozen_string_literal: true

require 'spec_helper'

describe 'security groups' do
  describe 'by default when no listeners specified' do
    let(:component) do
      var(role: :root, name: 'component')
    end
    let(:deployment_identifier) do
      var(role: :root, name: 'deployment_identifier')
    end
    let(:vpc_id) do
      output(role: :prerequisites, name: 'vpc_id')
    end

    before(:context) do
      @plan = plan(role: :root)
    end

    it 'creates a default security group' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group')
              .once)
    end

    it 'derives the security group name from the component and ' \
       'deployment identifier' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group')
              .with_attribute_value(
                :name, "#{component}-#{deployment_identifier}"
              ))
    end

    it 'includes the component in the security group description' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group')
              .with_attribute_value(:description, including(component)))
    end

    it 'includes the deployment identifier in the security group description' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group')
              .with_attribute_value(
                :description, including(deployment_identifier)
              ))
    end

    it 'uses the provided VPC ID for the security group' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group')
              .with_attribute_value(:vpc_id, vpc_id))
    end

    it 'adds tags to the security group' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group')
              .with_attribute_value(
                :tags, {
                  Name: "#{component}-#{deployment_identifier}",
                  Component: component,
                  DeploymentIdentifier: deployment_identifier
                }
              ))
    end

    it 'does not create a default ingress rule' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_security_group_rule')
                  .with_attribute_value(:type, 'ingress'))
    end

    it 'creates a default egress rule' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'egress')
              .once)
    end

    it 'uses a protocol of tcp for the egress rule' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'egress')
              .with_attribute_value(:protocol, 'tcp'))
    end

    it 'uses a from port of 0 for the egress rule' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'egress')
              .with_attribute_value(:from_port, 0))
    end

    it 'uses a to port of 65535 for the egress rule' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'egress')
              .with_attribute_value(:to_port, 65_535))
    end

    it 'uses the VPC CIDR for the egress rule' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'egress')
              .with_attribute_value(
                :cidr_blocks, [output(role: :prerequisites, name: 'vpc_cidr')]
              ))
    end
  end

  describe 'by default when one listener provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.listeners = [listener(port: 443)]
        vars.target_groups = [target_group]
      end
    end

    it 'creates a default ingress rule for the listener' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'ingress'))
    end

    it 'uses the listener port as the from port' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'ingress')
              .with_attribute_value(:from_port, 443))
    end

    it 'uses the listener port as the to port' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'ingress')
              .with_attribute_value(:to_port, 443))
    end

    it 'uses the VPC CIDR for the ingress rule' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'ingress')
              .with_attribute_value(
                :cidr_blocks, [output(role: :prerequisites, name: 'vpc_cidr')]
              ))
    end
  end

  describe 'by default when many listeners provided' do
    before(:context) do
      @listener1 = listener(
        key: 'first',
        port: 443,
        default_action: default_action(target_group_key: 'first')
      )
      @listener2 = listener(
        key: 'second',
        port: 8443,
        default_action: default_action(target_group_key: 'second')
      )
      @listeners = [@listener1, @listener2]

      @plan = plan(role: :root) do |vars|
        vars.listeners = @listeners
        vars.target_groups = [
          target_group(key: 'first'),
          target_group(key: 'second')
        ]
      end
    end

    it 'creates a default ingress rule for each listener' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'ingress')
              .exactly(@listeners.count).times)
    end

    it 'uses the listener ports as the from ports' do
      @listeners.each do |listener|
        expect(@plan)
          .to(include_resource_creation(type: 'aws_security_group_rule')
                .with_attribute_value(:type, 'ingress')
                .with_attribute_value(:from_port, listener[:port]))
      end
    end

    it 'uses the listener port as the to port' do
      @listeners.each do |listener|
        expect(@plan)
          .to(include_resource_creation(type: 'aws_security_group_rule')
                .with_attribute_value(:type, 'ingress')
                .with_attribute_value(:to_port, listener[:port]))
      end
    end

    it 'uses the VPC CIDR for the ingress rule' do
      @listeners.each do |listener|
        expect(@plan)
          .to(include_resource_creation(type: 'aws_security_group_rule')
                .with_attribute_value(:type, 'ingress')
                .with_attribute_value(:from_port, listener[:port])
                .with_attribute_value(
                  :cidr_blocks, [output(role: :prerequisites, name: 'vpc_cidr')]
                ))
      end
    end
  end

  describe 'when nil values are provided for the default security group' do
    let(:component) do
      var(role: :root, name: 'component')
    end
    let(:deployment_identifier) do
      var(role: :root, name: 'deployment_identifier')
    end
    let(:vpc_id) do
      output(role: :prerequisites, name: 'vpc_id')
    end

    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.listeners = [listener(port: 443)]
        vars.target_groups = [target_group]
        vars.security_groups = {
          default: {
            associate: nil,
            ingress_rule: {
              include: nil,
              cidrs: nil
            },
            egress_rule: {
              include: nil,
              from_port: nil,
              to_port: nil,
              cidrs: nil
            }
          }
        }
      end
    end

    it 'creates a default security group' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group')
              .once)
    end

    it 'creates a default ingress rule for each listener' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
                  .with_attribute_value(:type, 'ingress')
                  .once)
    end

    it 'uses the listener port as the from port' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'ingress')
              .with_attribute_value(:from_port, 443))
    end

    it 'uses the listener port as the to port' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'ingress')
              .with_attribute_value(:to_port, 443))
    end

    it 'uses the VPC CIDR for the ingress rule' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'ingress')
              .with_attribute_value(
                :cidr_blocks, [output(role: :prerequisites, name: 'vpc_cidr')]
              ))
    end

    it 'creates a default egress rule' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'egress')
              .once)
    end

    it 'uses a from port of 0 for the egress rule' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'egress')
              .with_attribute_value(:from_port, 0))
    end

    it 'uses a to port of 65535 for the egress rule' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'egress')
              .with_attribute_value(:to_port, 65_535))
    end

    it 'uses the VPC CIDR for the egress rule' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'egress')
              .with_attribute_value(
                :cidr_blocks, [output(role: :prerequisites, name: 'vpc_cidr')]
              ))
    end
  end

  describe 'when security group should not be associated' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.security_groups = {
          default: {
            associate: false,
            ingress_rule: {
              include: nil,
              cidrs: nil
            },
            egress_rule: {
              include: nil,
              from_port: nil,
              to_port: nil,
              cidrs: nil
            }
          }
        }
      end
    end

    it 'does not create a default security group' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_security_group'))
    end

    it 'does not create a default ingress rule' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_security_group_rule')
                  .with_attribute_value(:type, 'ingress'))
    end

    it 'does not create a default egress rule' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_security_group_rule')
                  .with_attribute_value(:type, 'egress'))
    end
  end

  describe 'when egress rule should not be included' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.security_groups = {
          default: {
            associate: true,
            ingress_rule: {
              include: nil,
              cidrs: nil
            },
            egress_rule: {
              include: false,
              from_port: nil,
              to_port: nil,
              cidrs: nil
            }
          }
        }
      end
    end

    it 'does not create a default egress rule' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_security_group_rule')
                  .with_attribute_value(:type, 'egress'))
    end
  end

  describe 'when egress rule should be included' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.security_groups = {
          default: {
            associate: true,
            ingress_rule: {
              include: nil,
              cidrs: nil
            },
            egress_rule: {
              include: true,
              from_port: nil,
              to_port: nil,
              cidrs: nil
            }
          }
        }
      end
    end

    it 'creates a default egress rule' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'egress'))
    end
  end

  describe 'when ingress rule should not be included and no ' \
           'listeners provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.security_groups = {
          default: {
            associate: true,
            ingress_rule: {
              include: false,
              cidrs: nil
            },
            egress_rule: {
              include: nil,
              from_port: nil,
              to_port: nil,
              cidrs: nil
            }
          }
        }
      end
    end

    it 'does not create a default ingress rule' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_security_group_rule')
                  .with_attribute_value(:type, 'ingress'))
    end
  end

  describe 'when ingress rule should not be included and ' \
           'listeners provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.security_groups = {
          default: {
            associate: true,
            ingress_rule: {
              include: false,
              cidrs: nil
            },
            egress_rule: {
              include: nil,
              from_port: nil,
              to_port: nil,
              cidrs: nil
            }
          }
        }
        vars.listeners = [listener]
        vars.target_groups = [target_group]
      end
    end

    it 'does not create a default ingress rule' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_security_group_rule')
                  .with_attribute_value(:type, 'ingress'))
    end
  end

  describe 'when ingress rule should be included and one listener provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.security_groups = {
          default: {
            associate: true,
            ingress_rule: {
              include: true,
              cidrs: nil
            },
            egress_rule: {
              include: nil,
              from_port: nil,
              to_port: nil,
              cidrs: nil
            }
          }
        }
        vars.listeners = [listener(port: 443)]
        vars.target_groups = [target_group]
      end
    end

    it 'creates a default ingress rule for the listener' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'ingress'))
    end

    it 'uses the listener port as the from port' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'ingress')
              .with_attribute_value(:from_port, 443))
    end

    it 'uses the listener port as the to port' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'ingress')
              .with_attribute_value(:to_port, 443))
    end

    it 'uses the VPC CIDR for the ingress rule' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'ingress')
              .with_attribute_value(
                :cidr_blocks, [output(role: :prerequisites, name: 'vpc_cidr')]
              ))
    end
  end

  describe 'when ingress rules should be included and many ' \
           'listeners provided' do
    before(:context) do
      @listener1 = listener(
        key: 'first',
        port: 443,
        default_action: default_action(target_group_key: 'first')
      )
      @listener2 = listener(
        key: 'second',
        port: 8443,
        default_action: default_action(target_group_key: 'second')
      )
      @listeners = [@listener1, @listener2]

      @plan = plan(role: :root) do |vars|
        vars.security_groups = {
          default: {
            associate: true,
            ingress_rule: {
              include: true,
              cidrs: nil
            },
            egress_rule: {
              include: nil,
              from_port: nil,
              to_port: nil,
              cidrs: nil
            }
          }
        }
        vars.listeners = @listeners
        vars.target_groups = [
          target_group(key: 'first'),
          target_group(key: 'second')
        ]
      end
    end

    it 'creates a default ingress rule for each listener' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'ingress')
              .exactly(@listeners.count).times)
    end

    it 'uses the listener ports as the from ports' do
      @listeners.each do |listener|
        expect(@plan)
          .to(include_resource_creation(type: 'aws_security_group_rule')
                .with_attribute_value(:type, 'ingress')
                .with_attribute_value(:from_port, listener[:port]))
      end
    end

    it 'uses the listener port as the to port' do
      @listeners.each do |listener|
        expect(@plan)
          .to(include_resource_creation(type: 'aws_security_group_rule')
                .with_attribute_value(:type, 'ingress')
                .with_attribute_value(:to_port, listener[:port]))
      end
    end

    it 'uses the VPC CIDR for the ingress rule' do
      @listeners.each do |listener|
        expect(@plan)
          .to(include_resource_creation(type: 'aws_security_group_rule')
                .with_attribute_value(:type, 'ingress')
                .with_attribute_value(:from_port, listener[:port])
                .with_attribute_value(
                  :cidr_blocks, [output(role: :prerequisites, name: 'vpc_cidr')]
                ))
      end
    end
  end

  describe 'when ingress CIDRs provided' do
    before(:context) do
      @ingress_cidrs = %w[10.0.0.0/16 10.1.0.0/16]

      @plan = plan(role: :root) do |vars|
        vars.security_groups = {
          default: {
            associate: nil,
            ingress_rule: {
              include: nil,
              cidrs: @ingress_cidrs
            },
            egress_rule: {
              include: nil,
              from_port: nil,
              to_port: nil,
              cidrs: nil
            }
          }
        }
        vars.listeners = [listener]
        vars.target_groups = [target_group]
      end
    end

    it 'uses the provided CIDRs on the ingress rule' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'ingress')
              .with_attribute_value(:cidr_blocks, @ingress_cidrs))
    end
  end

  describe 'when egress from port provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.security_groups = {
          default: {
            associate: nil,
            ingress_rule: {
              include: nil,
              cidrs: nil
            },
            egress_rule: {
              include: nil,
              from_port: 1024,
              to_port: nil,
              cidrs: nil
            }
          }
        }
      end
    end

    it 'uses the provided from port on the egress rule' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'egress')
              .with_attribute_value(:from_port, 1024))
    end
  end

  describe 'when egress to port provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.security_groups = {
          default: {
            associate: nil,
            ingress_rule: {
              include: nil,
              cidrs: nil
            },
            egress_rule: {
              include: nil,
              from_port: nil,
              to_port: 1024,
              cidrs: nil
            }
          }
        }
      end
    end

    it 'uses the provided from port on the egress rule' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'egress')
              .with_attribute_value(:to_port, 1024))
    end
  end

  describe 'when egress CIDRs provided' do
    before(:context) do
      @egress_cidrs = %w[10.0.0.0/16 10.1.0.0/16]

      @plan = plan(role: :root) do |vars|
        vars.security_groups = {
          default: {
            associate: nil,
            ingress_rule: {
              include: nil,
              cidrs: nil
            },
            egress_rule: {
              include: nil,
              from_port: nil,
              to_port: nil,
              cidrs: @egress_cidrs
            }
          }
        }
      end
    end

    it 'uses the provided from port on the egress rule' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'egress')
              .with_attribute_value(:cidr_blocks, @egress_cidrs))
    end
  end

  def listener(overrides = {})
    {
      key: 'default',
      port: 443,
      protocol: 'HTTPS',
      ssl_policy: 'ELBSecurityPolicy-TLS-1-2-Ext-2018-06',
      certificate_arn:
        output(role: :prerequisites, name: 'certificate_arn'),
      default_action:
    }.merge(overrides)
  end

  def default_action(overrides = {})
    {
      type: 'forward',
      target_group_key: 'default'
    }.merge(overrides)
  end

  def target_group(overrides = {})
    {
      key: 'default',
      port: 80,
      protocol: 'HTTP',
      target_type: 'instance',
      deregistration_delay: nil,
      health_check:
    }.merge(overrides)
  end

  def health_check(overrides = {})
    {
      path: '/health',
      port: 'traffic-port',
      protocol: 'HTTP',
      interval: 30,
      healthy_threshold: 5,
      unhealthy_threshold: 5
    }.merge(overrides)
  end
end
