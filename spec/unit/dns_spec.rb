# frozen_string_literal: true

require 'spec_helper'

describe 'DNS records' do
  describe 'by default' do
    before(:context) do
      @plan = plan(role: :root)
    end

    it 'does not create any DNS entries' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_route53_record'))
    end

    it 'outputs an empty string for the address' do
      expect(@plan)
        .to(include_output_creation(name: 'address')
              .with_value(''))
    end
  end

  describe 'when no hosted zones specified' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.dns = {
          domain_name: output(role: :prerequisites, name: 'domain_name'),
          records: []
        }
      end
    end

    it 'does not create any DNS entries' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_route53_record'))
    end

    it 'outputs an empty string for the address' do
      expect(@plan)
        .to(include_output_creation(name: 'address')
              .with_value(''))
    end
  end

  describe 'when one hosted zone specified' do
    let(:component) do
      var(role: :root, name: 'component')
    end
    let(:deployment_identifier) do
      var(role: :root, name: 'deployment_identifier')
    end

    before(:context) do
      @domain_name = output(role: :prerequisites, name: 'domain_name')
      @zone_id = output(role: :prerequisites, name: 'private_zone_id')

      @plan = plan(role: :root) do |vars|
        vars.dns = {
          domain_name: @domain_name,
          records: [
            { zone_id: @zone_id }
          ]
        }
      end
    end

    it 'creates a DNS entry in the provided hosted zone' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_route53_record')
              .with_attribute_value(:zone_id, @zone_id))
    end

    it 'uses a record type of A' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_route53_record')
              .with_attribute_value(:zone_id, @zone_id)
              .with_attribute_value(:type, 'A'))
    end

    it 'constructs the record name from the component, ' \
       'deployment identifier and supplied domain name' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_route53_record')
              .with_attribute_value(:zone_id, @zone_id)
              .with_attribute_value(
                :name, "#{component}-#{deployment_identifier}.#{@domain_name}"
              ))
    end

    it 'outputs the address' do
      expect(@plan)
        .to(include_output_creation(name: 'address')
              .with_value(
                "#{component}-#{deployment_identifier}.#{@domain_name}"
              ))
    end
  end

  describe 'when many hosted zones specified' do
    let(:component) do
      var(role: :root, name: 'component')
    end
    let(:deployment_identifier) do
      var(role: :root, name: 'deployment_identifier')
    end

    before(:context) do
      @domain_name = output(role: :prerequisites, name: 'domain_name')
      @zone_ids = [
        output(role: :prerequisites, name: 'private_zone_id'),
        output(role: :prerequisites, name: 'public_zone_id')
      ]

      @plan = plan(role: :root) do |vars|
        vars.dns = {
          domain_name: @domain_name,
          records: @zone_ids.map do |zone_id|
            { zone_id: }
          end
        }
      end
    end

    it 'creates a DNS entry in each of the provided hosted zones' do
      @zone_ids.each do |zone_id|
        expect(@plan)
          .to(include_resource_creation(type: 'aws_route53_record')
                .with_attribute_value(:zone_id, zone_id))
      end
    end

    it 'uses records of type A' do
      @zone_ids.each do |zone_id|
        expect(@plan)
          .to(include_resource_creation(type: 'aws_route53_record')
                .with_attribute_value(:zone_id, zone_id)
                .with_attribute_value(:type, 'A'))
      end
    end

    it 'constructs the record names from the component, ' \
       'deployment identifier and supplied domain name' do
      @zone_ids.each do |zone_id|
        expect(@plan)
          .to(include_resource_creation(type: 'aws_route53_record')
                .with_attribute_value(:zone_id, zone_id)
                .with_attribute_value(
                  :name, "#{component}-#{deployment_identifier}.#{@domain_name}"
                ))
      end
    end

    it 'outputs the address' do
      expect(@plan)
        .to(include_output_creation(name: 'address')
              .with_value(
                "#{component}-#{deployment_identifier}.#{@domain_name}"
              ))
    end
  end
end
