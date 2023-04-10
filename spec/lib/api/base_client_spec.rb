require 'rails_helper'
require 'webmock/rspec'
require_relative "#{Rails.root}/lib/api/base_client"

RSpec.describe Api::BaseClient do

  describe '#initialize' do
    context 'initializeに引数が指定されない場合' do
      subject {
        described_class.new
      }
      it 'max_retry_countに3がセットされること' do
        expect(subject.instance_variable_get(:@max_retry_count)).to eq(3)
      end
      it 'retry_sleep_secondsに5がセットされること' do
        expect(subject.instance_variable_get(:@retry_sleep_seconds)).to eq(5)
      end
    end

    context 'initializeに引数 max_retry_count のみが指定された場合' do
      subject {
        described_class.new(max_retry_count: 10)
      }
      it 'max_retry_countに10がセットされること' do
        expect(subject.instance_variable_get(:@max_retry_count)).to eq(10)
      end
      it 'retry_sleep_secondsに5がセットされること' do
        expect(subject.instance_variable_get(:@retry_sleep_seconds)).to eq(5)
      end
    end

    context 'initializeに引数 retry_sleep_seconds のみが指定された場合' do
      subject {
        described_class.new(retry_sleep_seconds: 10)
      }
      it 'max_retry_countに3がセットされること' do
        expect(subject.instance_variable_get(:@max_retry_count)).to eq(3)
      end
      it 'retry_sleep_secondsに10がセットされること' do
        expect(subject.instance_variable_get(:@retry_sleep_seconds)).to eq(10)
      end
    end

    context 'initializeに引数 max_retry_count, retry_sleep_seconds が指定された場合' do
      subject {
        described_class.new(max_retry_count: 1, retry_sleep_seconds: 1)
      }
      it 'max_retry_countに3がセットされること' do
        expect(subject.instance_variable_get(:@max_retry_count)).to eq(1)
      end
      it 'retry_sleep_secondsに10がセットされること' do
        expect(subject.instance_variable_get(:@retry_sleep_seconds)).to eq(1)
      end
    end
  end

  describe '#get' do
    let!(:base_client) { described_class.new }
    let!(:stub_dummy_url) { 'https://dummy.org/api/dummy?api_key=dummy_api_key&language=ja&page=1' }

    describe 'リクエストの妥当性' do
      before do
        stub_request(:get, stub_dummy_url)
          .to_return(status: 200, body: '', headers: { 'Content-Type' => 'application/json' })
      end
      let!(:url) { 'https://dummy.org/api/dummy' }
      let!(:params) {
        {
          api_key: 'dummy_api_key',
          language: 'ja',
          page: 1,
        }
      }

      subject { base_client.send(:get, url: url, params: params) }
      it '正しいURLにリクエストできていること' do
        subject
        expect(WebMock).to have_requested(:get, url).with(query: params)
      end
    end

    describe 'リトライ処理の検証' do
      let!(:url) { 'https://dummy.org/api/dummy' }
      let!(:params) {
        {
          api_key: 'dummy_api_key',
          language: 'ja',
          page: 1,
        }
      }
      let(:response_body) do
        {
          results: [
            {
              id: 1,
              title: 'The Shawshank Redemption'
            },
            {
              id: 2,
              title: 'The Godfather'
            }
          ]
        }
      end
      context 'ステータスコード: 200がレスポンスされる場合' do
        before do
          stub_request(:get, stub_dummy_url)
            .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })
        end

        let!(:excepted_body) { JSON.parse(response_body.to_json) }

        subject { base_client.send(:get, url: url, params: params) }
        it 'レスポンス結果が取得できる' do
          expect(subject).to eq(excepted_body)
        end
      end

      context '2回のリクエストで503, 3回目のリクエストで200がレスポンスされる場合' do
        before do
          stub_request(:get, stub_dummy_url)
            .to_return(status: 500).times(2)
            .then.to_return(status: 200, body: response_body.to_json, headers: {})
        end

        let!(:excepted_body) { JSON.parse(response_body.to_json) }
        subject { base_client.send(:get, url: url, params: params) }

        it '200での場合のレスポンスが返されること' do
          expect(subject).to eq(excepted_body)
        end
      end

      context '3回のリクエストで500がレスポンスされる場合' do
        let(:response_body) do
          {
            errors: [
                "page must be less than or equal to 500"
            ],
            success: false
          }
        end

        before do
          stub_request(:get, stub_dummy_url)
            .to_return(status: 500, body: response_body.to_json, headers: {})
            .times(3)
            .then.to_return(status: 200, body: response_body.to_json, headers: {})
        end

        subject { base_client.send(:get, url: url, params: params) }

        it 'nilがレスポンスされること' do
          expect(subject).to be_nil
        end
      end
    end
  end
end
