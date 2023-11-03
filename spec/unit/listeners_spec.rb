# frozen_string_literal: true

require 'spec_helper'

describe 'listeners' do
  describe 'by default' do
    before(:context) do
      @plan = plan(role: :root)
    end

    it 'does not create any listeners' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_lb_listener'))
    end

    it 'outputs an empty map of listeners' do
      expect(@plan)
        .to(include_output_creation(name: 'listeners')
              .with_value({}))
    end
  end

  describe 'when one listener specified' do
    before(:context) do
      @key = 'default'
      @port = 443
      @protocol = 'TLS'
      @ssl_policy = 'ELBSecurityPolicy-TLS-1-2-Ext-2018-06'
      @certificate_arn = output(role: :prerequisites, name: 'certificate_arn')
      @default_action_type = 'forward'
      @default_action_target_group_key = 'default'

      @plan = plan(role: :root) do |vars|
        vars.listeners = [
          {
            key: @key,
            port: @port,
            protocol: @protocol,
            ssl_policy: @ssl_policy,
            certificate_arn: @certificate_arn,
            default_action: {
              type: @default_action_type,
              target_group_key: @default_action_target_group_key
            }
          }
        ]
        vars.target_groups = [
          {
            key: 'default',
            port: 80,
            protocol: 'TCP',
            target_type: 'instance',
            deregistration_delay: nil,
            health_check:
              {
                port: 'traffic-port',
                protocol: 'TCP',
                interval: 30,
                healthy_threshold: 5,
                unhealthy_threshold: 5
              }
          }
        ]
      end
    end

    it 'creates a listener' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_lb_listener')
              .once)
    end

    it 'uses the specified port' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_lb_listener')
              .with_attribute_value(:port, @port))
    end

    it 'uses the specified protocol' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_lb_listener')
              .with_attribute_value(:protocol, @protocol))
    end

    it 'uses the specified SSL policy' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_lb_listener')
              .with_attribute_value(:ssl_policy, @ssl_policy))
    end

    it 'uses the specified certificate ARN' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_lb_listener')
              .with_attribute_value(:certificate_arn, @certificate_arn))
    end

    it 'uses the specified default action type' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_lb_listener')
              .with_attribute_value(
                [:default_action, 0, :type], @default_action_type
              ))
    end
  end

  describe 'when many listeners specified' do
    before(:context) do
      @certificate_arn = output(role: :prerequisites, name: 'certificate_arn')

      @key1 = 'first'
      @port1 = 443
      @protocol1 = 'TLS'
      @ssl_policy1 = 'ELBSecurityPolicy-TLS-1-2-Ext-2018-06'
      @default_action_type1 = 'forward'
      @default_action_target_group_key1 = 'first'

      @key2 = 'second'
      @port2 = 8443
      @protocol2 = 'TLS'
      @ssl_policy2 = 'ELBSecurityPolicy-TLS-1-2-Ext-2018-06'
      @default_action_type2 = 'forward'
      @default_action_target_group_key2 = 'second'

      @listener1 = {
        key: @key1,
        port: @port1,
        protocol: @protocol1,
        ssl_policy: @ssl_policy1,
        certificate_arn: @certificate_arn,
        default_action: {
          type: @default_action_type1,
          target_group_key: @default_action_target_group_key1
        }
      }
      @listener2 = {
        key: @key2,
        port: @port2,
        protocol: @protocol2,
        ssl_policy: @ssl_policy2,
        certificate_arn: @certificate_arn,
        default_action: {
          type: @default_action_type2,
          target_group_key: @default_action_target_group_key2
        }
      }

      @listeners = [@listener1, @listener2]

      @plan = plan(role: :root) do |vars|
        vars.listeners = [
          @listener1,
          @listener2
        ]
        vars.target_groups = [
          {
            key: 'first',
            port: 80,
            protocol: 'TCP',
            target_type: 'instance',
            deregistration_delay: nil,
            health_check:
              {
                port: 'traffic-port',
                protocol: 'TCP',
                interval: 30,
                healthy_threshold: 5,
                unhealthy_threshold: 5
              }
          },
          {
            key: 'second',
            port: 8080,
            protocol: 'TCP',
            target_type: 'instance',
            deregistration_delay: nil,
            health_check:
              {
                port: 'traffic-port',
                protocol: 'TCP',
                interval: 30,
                healthy_threshold: 5,
                unhealthy_threshold: 5
              }
          }
        ]
      end
    end

    it 'creates each listener' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_lb_listener')
              .exactly(@listeners.count).times)
    end

    it 'uses the specified ports' do
      @listeners.each do |listener|
        expect(@plan)
          .to(include_resource_creation(type: 'aws_lb_listener')
                .with_attribute_value(:port, listener[:port]))
      end
    end

    it 'uses the specified protocols' do
      @listeners.each do |listener|
        expect(@plan)
          .to(include_resource_creation(type: 'aws_lb_listener')
                .with_attribute_value(:port, listener[:port])
                .with_attribute_value(:protocol, listener[:protocol]))
      end
    end

    it 'uses the specified SSL policies' do
      @listeners.each do |listener|
        expect(@plan)
          .to(include_resource_creation(type: 'aws_lb_listener')
                .with_attribute_value(:port, listener[:port])
                .with_attribute_value(:ssl_policy, listener[:ssl_policy]))
      end
    end

    it 'uses the specified certificate ARN' do
      @listeners.each do |listener|
        expect(@plan)
          .to(include_resource_creation(type: 'aws_lb_listener')
                .with_attribute_value(:port, listener[:port])
                .with_attribute_value(
                  :certificate_arn, listener[:certificate_arn]
                ))
      end
    end

    it 'uses the specified default action types' do
      @listeners.each do |listener|
        expect(@plan)
          .to(include_resource_creation(type: 'aws_lb_listener')
                .with_attribute_value(:port, listener[:port])
                .with_attribute_value(
                  [:default_action, 0, :type], listener[:default_action][:type]
                ))
      end
    end
  end

  describe 'when certificate ARN and SSL policy not specified' do
    before(:context) do
      @key = 'first'
      @port = 80
      @protocol = 'TCP'
      @default_action_type = 'forward'
      @default_action_target_group_key = 'first'

      @listener = {
        key: @key,
        port: @port,
        protocol: @protocol,
        default_action: {
          type: @default_action_type,
          target_group_key: @default_action_target_group_key
        }
      }

      @plan = plan(role: :root) do |vars|
        vars.listeners = [@listener]
        vars.target_groups = [
          {
            key: 'first',
            port: 80,
            protocol: 'TCP',
            target_type: 'instance',
            deregistration_delay: nil,
            health_check:
              {
                port: 'traffic-port',
                protocol: 'TCP',
                interval: 30,
                healthy_threshold: 5,
                unhealthy_threshold: 5
              }
          }
        ]
      end
    end

    it 'creates a listener' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_lb_listener')
              .once)
    end

    it 'uses the specified port' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_lb_listener')
              .with_attribute_value(:port, @port))
    end

    it 'uses the specified protocol' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_lb_listener')
              .with_attribute_value(:protocol, @protocol))
    end

    it 'does not set an SSL policy' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_lb_listener')
              .with_attribute_value(:ssl_policy, a_nil_value))
    end

    it 'does not set a certificate ARN' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_lb_listener')
              .with_attribute_value(:certificate_arn, a_nil_value))
    end

    it 'uses the specified default action type' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_lb_listener')
              .with_attribute_value(
                [:default_action, 0, :type], @default_action_type
              ))
    end
  end
end
