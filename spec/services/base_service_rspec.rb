# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BaseService do
  before(:all) do
    class TestService < BaseService
      with_error_processing

      string :input, default: nil

      class << self
        def set_test_error(error)
          @test_error = error
        end

        def set_test_result(result)
          @test_result = result
        end

        attr_reader :test_error, :test_result
      end

      def execute
        raise self.class.test_error if self.class.test_error

        self.class.test_result
      end
    end

    class ChildTestService < TestService
      def execute
        raise self.class.test_error if self.class.test_error

        'child success'
      end
    end
  end

  after(:all) do
    Object.send(:remove_const, :TestService)
    Object.send(:remove_const, :ChildTestService)
  end

  let(:base_params) { { input: 'test' } }

  describe '.with_error_processing' do
    context 'when no error occurs' do
      before do
        TestService.set_test_result('success')
        TestService.set_test_error(nil)
      end

      it 'returns the original result' do
        outcome = TestService.run(base_params)
        expect(outcome.result).to eq('success')
      end

      it 'does not add any errors' do
        outcome = TestService.run(base_params)
        expect(outcome.errors).to be_empty
      end
    end

    context 'when StandardError occurs' do
      let(:error_message) { 'Something went wrong' }

      before do
        TestService.set_test_result(nil)
        TestService.set_test_error(StandardError.new(error_message))
      end

      it 'catches the error and adds it to errors' do
        outcome = TestService.run(base_params)
        expect(outcome.errors.full_messages).to include("Service error #{error_message}")
      end

      it 'marks the interaction as invalid' do
        outcome = TestService.run(base_params)
        expect(outcome).not_to be_valid
      end
    end

    context 'with different types of errors' do
      error_classes = [
        RuntimeError,
        ArgumentError
      ]

      error_classes.each do |error_class|
        context "when #{error_class} occurs" do
          let(:error_message) { "#{error_class} occurred" }

          before do
            TestService.set_test_result(nil)
            TestService.set_test_error(error_class.new(error_message))
          end

          it 'handles the error and adds it to errors' do
            outcome = TestService.run(base_params)
            expect(outcome.errors.full_messages).to include("Service error #{error_message}")
          end
        end
      end

      context 'when NoMethodError occurs' do
        let(:error_message) { 'NoMethodError occurred' }

        before do
          TestService.set_test_result(nil)
          error = NoMethodError.new(error_message)
          allow(error).to receive(:message).and_return(error_message)
          TestService.set_test_error(error)
        end

        it 'handles the error and adds it to errors' do
          outcome = TestService.run(base_params)
          expect(outcome.errors.full_messages).to include("Service error #{error_message}")
        end
      end
    end

    context 'error message formatting' do
      let(:error_message) { 'test error' }

      before do
        TestService.set_test_result(nil)
        TestService.set_test_error(StandardError.new(error_message))
      end

      it 'adds error with correct key' do
        outcome = TestService.run(base_params)
        expect(outcome.errors[:service_error]).to include(error_message)
      end
    end
  end

  describe 'inheritance behavior' do
    context 'when child service raises error' do
      let(:error_message) { 'Child service error' }

      before do
        ChildTestService.set_test_result(nil)
        ChildTestService.set_test_error(StandardError.new(error_message))
      end

      it 'inherits error processing behavior' do
        outcome = ChildTestService.run(base_params)
        expect(outcome.errors.full_messages).to include("Service error #{error_message}")
      end
    end

    context 'when child service succeeds' do
      before do
        ChildTestService.set_test_error(nil)
      end

      it 'executes successfully' do
        outcome = ChildTestService.run(base_params)
        expect(outcome.result).to eq('child success')
      end
    end
  end
end
