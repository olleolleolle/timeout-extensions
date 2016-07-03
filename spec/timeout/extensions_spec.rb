require 'spec_helper'

RSpec.describe Timeout::Extensions do
  describe ".timeout" do
    let(:dummy_timeout) { double(:meta_timeout) }
    let(:exception) { double(:exception) }
    let(:action) { Proc.new{ |t|  } }
    context "inside and outside of thread" do
      it "hits the proper timeout handler" do
        within_thread do
          Thread.current.timeout_handler = dummy_timeout
          expect(dummy_timeout).to receive(:call).with(2, exception, &action)
          timeout(2, exception, &action)
        end
      end
    end
  end

  describe ".sleep" do
    let(:dummy_sleep) { double(:meta_sleep) }
    context "inside and outside of thread" do
      it "hits the proper sleep handler" do
        within_thread do
          Thread.current.sleep_handler = dummy_sleep
          expect(dummy_sleep).to receive(:call).with(2)
          sleep(2)
        end
      end
    end
  end 
end
