require_relative 'spec_helper'
require_relative '../lib/log_helpers'

describe 'LogHelpers' do

  context 'when provided an invalid log hash input' do
    tests = [
      '',
      123,
      nil,
      true,
      []
    ]
    tests.each do |test|
      it "it throws an error when given a #{test.class}" do
        msg = "log_hash must be a Hash, got: #{test.class}"
        expect { LogHelpers.validate_log_hash(test) }.to raise_error(msg)
      end
    end
  end

  it 'throws an error when no static_text is provided' do
    msg = 'log_hash must contain a :static_text key'
    expect { LogHelpers.validate_log_hash({}) }.to raise_error(msg)
  end

  context 'when the static_text is not a string' do
    tests = [
      nil,
      true,
      123,
      [],
      {}
    ]
    tests.each do |test|
      it "throws an error when given static_text as a #{test.class}" do
        test_hash = { static_text: test }
        msg = "static_text must be a String, got: #{test.class}"
        expect { LogHelpers.validate_log_hash(test_hash) }.to raise_error(msg)
      end
    end
  end

  it 'throws an error if the static_text is empty' do
    test_hash = { static_text: '' }
    msg = 'static_text must not be empty'
    expect { LogHelpers.validate_log_hash(test_hash) }.to raise_error(msg)
  end

  context 'throws an error if the wait_text is provided but is not a string' do
    tests = [
      nil,
      true,
      123,
      [],
      {}
    ]
    tests.each do |test|
      it "throws an error when given wait_text as a #{test.class}" do
        test_hash = { static_text: 'a', wait_text: test }
        msg = "wait_text must be a String if provided, got: #{test.class}"
        expect { LogHelpers.validate_log_hash(test_hash) }.to raise_error(msg)
      end
    end
  end

  it 'throws an error if the wait_text is provided but is empty' do
    test_hash = { static_text: 'a', wait_text: '' }
    msg = 'wait_text must not be empty'
    expect { LogHelpers.validate_log_hash(test_hash) }.to raise_error(msg)
  end

  context 'throws an error if the done_text is provided but is not a string' do
    tests = [
      nil,
      true,
      123,
      [],
      {}
    ]
    tests.each do |test|
      it "throws an error when given done_text as a #{test.class}" do
        test_hash = { static_text: 'a', done_text: test }
        msg = "done_text must be a String if provided, got: #{test.class}"
        expect { LogHelpers.validate_log_hash(test_hash) }.to raise_error(msg)
      end
    end
  end

  it 'throws an error if the done_text is provided but is empty' do
    test_hash = { static_text: 'a', done_text: '' }
    msg = 'done_text must not be empty'
    expect { LogHelpers.validate_log_hash(test_hash) }.to raise_error(msg)
  end

end
