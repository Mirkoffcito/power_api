require "rails_helper"

describe PowerApi::VersionGeneratorHelper do
  let(:version_number) { "1" }
  let(:init_params) do
    {
      version_number: version_number
    }
  end

  subject { described_class.new(init_params) }

  describe "routes_line_to_inject_new_version" do
    let(:expected_line) do
      "routes.draw do\n"
    end

    def perform
      subject.routes_line_to_inject_new_version
    end

    it { expect(perform).to eq(expected_line) }

    context "when is not the first version" do
      let(:version_number) { "2" }

      let(:expected_line) do
        "'/api' do\n"
      end

      it { expect(perform).to eq(expected_line) }
    end
  end

  describe "#version_route_template" do
    let(:expected_tpl) do
      <<-ROUTE
  scope path: '/api' do
    api_version(module: 'Api::V1', path: { value: 'v1' }, defaults: { format: 'json' }) do
    end
  end
      ROUTE
    end

    def perform
      subject.version_route_template
    end

    it { expect(perform).to eq(expected_tpl) }

    context "when is not the first version" do
      let(:version_number) { "2" }

      let(:expected_tpl) do
        <<-ROUTE
    api_version(module: 'Api::V2', path: { value: 'v2' }, defaults: { format: 'json' }) do
    end

        ROUTE
      end

      it { expect(perform).to eq(expected_tpl) }
    end
  end

  describe "#base_controller_path" do
    let(:expected_path) do
      "app/controllers/api/v1/base_controller.rb"
    end

    def perform
      subject.base_controller_path
    end

    it { expect(perform).to eq(expected_path) }

    context "with another version" do
      let(:version_number) { "2" }

      let(:expected_path) do
        "app/controllers/api/v2/base_controller.rb"
      end

      it { expect(perform).to eq(expected_path) }
    end
  end

  describe "#base_controller_template" do
    let(:expected_tpl) do
      <<~CONTROLLER
        class Api::V1::BaseController < Api::BaseController
        end
      CONTROLLER
    end

    def perform
      subject.base_controller_template
    end

    it { expect(perform).to eq(expected_tpl) }

    context "with another version" do
      let(:version_number) { "2" }

      let(:expected_tpl) do
        <<~CONTROLLER
          class Api::V2::BaseController < Api::BaseController
          end
        CONTROLLER
      end

      it { expect(perform).to eq(expected_tpl) }
    end
  end

  describe "#serializers_path" do
    let(:expected_path) do
      "app/serializers/api/v1/.gitkeep"
    end

    def perform
      subject.serializers_path
    end

    it { expect(perform).to eq(expected_path) }

    context "with another version" do
      let(:version_number) { "2" }

      let(:expected_path) do
        "app/serializers/api/v2/.gitkeep"
      end

      it { expect(perform).to eq(expected_path) }
    end
  end

  describe "#swagger_helper_api_definition_line" do
    let(:expected_path) do
      "config.swagger_docs = {\n"
    end

    def perform
      subject.swagger_helper_api_definition_line
    end

    it { expect(perform).to eq(expected_path) }
  end

  describe "#swagger_helper_api_definition" do
    let(:expected_tpl) do
      <<-VERSION
    'v1/swagger.json' => API_V1
      VERSION
    end

    def perform
      subject.swagger_helper_api_definition
    end

    it { expect(perform).to eq(expected_tpl) }

    context "with another version" do
      let(:version_number) { "2" }

      let(:expected_tpl) do
        <<-VERSION
    'v2/swagger.json' => API_V2,
        VERSION
      end

      it { expect(perform).to eq(expected_tpl) }
    end
  end
end