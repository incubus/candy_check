require 'spec_helper'

describe CandyCheck::PlayStore::Subscription do
  subject { CandyCheck::PlayStore::Subscription.new(attributes) }

  describe 'expired and canceled subscription' do
    let(:attributes) do
      {
        kind: 'androidpublisher#subscriptionPurchase',
        start_time_millis: 1_459_540_113_244,
        expiry_time_millis: 1_462_132_088_610,
        auto_renewing: false,
        developer_payload: 'payload that gets stored and returned',
        cancel_reason: 0,
        payment_state: 1
      }
    end

    it 'is expired?' do
      subject.expired?.must_be_true
    end

    it 'is canceled by user' do
      subject.canceled_by_user?.must_be_true
    end

    it 'returns the payment_state' do
      subject.payment_state.must_equal 1
    end

    it 'considers a payment as valid' do
      subject.payment_received?.must_be_true
    end

    it 'checks that auto renewal status is false' do
      subject.auto_renewing?.must_be_false
    end

    it 'returns the developer_payload' do
      subject.developer_payload.must_equal \
        'payload that gets stored and returned'
    end

    it 'returns the kind' do
      subject.kind.must_equal 'androidpublisher#subscriptionPurchase'
    end

    it 'returns the start_time_millis' do
      subject.start_time_millis.must_equal 145_954_011_324_4
    end

    it 'returns the expiry_time_millis' do
      subject.expiry_time_millis.must_equal 146_213_208_861_0
    end

    it 'returns the starts_at' do
      expected = DateTime.new(2016, 4, 1, 19, 48, 33)
      subject.starts_at.must_equal expected
    end

    it 'returns the expires_at' do
      expected = DateTime.new(2016, 5, 1, 19, 48, 8)
      subject.expires_at.must_equal expected
    end
  end

  describe 'unexpired and renewing subscription' do
    two_days_from_now = DateTime.now + 2
    let(:attributes) do
      {
        expiry_time_millis: two_days_from_now.to_time.to_i * 1000,
        auto_renewing: true
      }
    end

    it 'is expired?' do
      subject.expired?.must_be_false
    end

    it 'is two days left until it is overdue' do
      subject.overdue_days.must_equal(-2)
    end
  end

  describe 'expired due to payment failure' do
    let(:attributes) do
      {
        expiry_time_millis: 1_462_132_088_610,
        auto_renewing: true,
        cancel_reason: 1
      }
    end

    it 'is expired?' do
      subject.expired?.must_be_true
    end

    it 'is payment_failed?' do
      subject.payment_failed?.must_be_true
    end
  end

  describe 'expired with pending payment' do
    let(:attributes) do
      {
        expiry_time_millis: 1_462_132_088_610,
        auto_renewing: true,
        payment_state: 0
      }
    end

    it 'is expired?' do
      subject.expired?.must_be_true
    end

    it 'is payment_pending?' do
      subject.payment_pending?.must_be_true
    end
  end

  describe 'trial' do
    let(:attributes) do
      {
        payment_state: 1,
        price_currency_code: 'SOMECODE',
        price_amount_micros: 0
      }
    end

    it 'is trual?' do
      subject.trial?.must_be_true
    end

    it 'returns the price_currency_code' do
      subject.price_currency_code.must_equal 'SOMECODE'
    end
  end
end
