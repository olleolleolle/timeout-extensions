require 'spec_helper'

describe Timeout::Extensions do
  describe "timeout" do
    let(:dummy_timeout) { double(:meta_timeout) }
    let(:exception) { double(:exception) }
    let(:action) { Proc.new{ |t|  } }
    context "inside and outside of actor" do
      it "hits the proper timeout handler" do
        within_actor do
          Thread.enhance_for_concurrency! do |t|
            t.timeout_handler = dummy_timeout
          end
          expect(dummy_timeout).to receive(:call).with(2, exception, &action)
          timeout(2, exception, &action)
        end
        expect(Timeout).to receive(:timeout_without_handler)
        timeout(2, exception, &action)
      end
    end
  end

  describe "sleep" do
    let(:dummy_sleep) { double(:meta_sleep) }
    context "inside and outside of actor" do
      it "hits the proper sleep handler" do
        within_actor do
          Thread.enhance_for_concurrency! do |t|
            t.sleep_handler = dummy_sleep
          end
          expect(dummy_sleep).to receive(:call).with(2)
          sleep(2)
        end
        expect(self).to receive(:sleep_without_handler)
        sleep(2)
      end
    end
  end 
end
