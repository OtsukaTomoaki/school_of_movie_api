require 'rails_helper'

RSpec.describe "Api::V1::User", type: :request, authentication: :skip  do
  extend ActiveSupport::Concern
  RSpec::Matchers.define_negated_matcher :not_change, :change

  let!(:avatar_image) {
    fixture_file_upload("images/sample_1.jpeg", 'image/jpeg')
  }
  before {
    5.times do |i|
      FactoryBot.create(:user,
        name: 'Foo婆バズ',
        email: "#{User.count}_bar@gmail.com")
    end
  }
  let!(:user) {
    user = FactoryBot.create(:user,
      name: 'FOO_BAR_テスト',
      email: "foo_bar_baz@sample.com")
    user
  }

  describe "/profile" do
    subject {
      get '/api/v1/users/profile'
    }
    it 'プロフィールを取得する' do
      subject
      json = JSON.parse(response.body)

      expect(response.status).to eq(200)
      expect(json['name']).to eq('user')
      expect(json['email']).to eq('user@gmail.com')
    end
  end

  describe "/update" do
    subject {
      put "/api/v1/users/#{user.id}", params: params
    }
    before {
      user.avatar_image.attach(io: avatar_image, filename: "#{Time.now.to_i}_#{user.id}.jpg" , content_type: "image/jpg" )
    }

    context "正常系" do
      context "プロフィール画像の更新を含まない場合" do
        let!(:params) {
          {
            user: {
              name: '更新テスト'
            }
          }
        }
        let!(:avatar_image_sum) {
          user.avatar_image.checksum
        }
        it "レスポンスが200になり、プロフィールも更新されること" do
          subject
          expect(response).to have_http_status 200
          json = JSON.parse(response.body)
          expect(json['name']).to eq params[:user][:name]
          expect(user.avatar_image.checksum).to eq avatar_image_sum
        end
      end

      context "プロフィール画像の更新を含む場合" do
        let!(:params) {
          {
            user: {
              name: '更新テスト',
              avatar_image: base64_avatar_image
            }
          }
        }
        let!(:new_avatar_image) {
          fixture_file_upload("images/sample_2.jpeg", 'image/jpeg').read
        }
        let!(:base64_avatar_image) {
          Base64.strict_encode64(new_avatar_image)
        }
        it "レスポンスが200になり、プロフィールも更新されること" do
          subject
          expect(response).to have_http_status 200
          json = JSON.parse(response.body)
          expect(json['name']).to eq params[:user][:name]
          updated_user = User.find_by_id(user.id)
          expect(updated_user.avatar_image.download).to eq new_avatar_image
        end
      end
    end
  end

  describe "/download_avatar_image" do
    let!(:user_1) {
      FactoryBot.create(:user,
        name: 'avatar_image',
        email: "avatar_image@sample.com")
    }
    subject {
      get "/api/v1/users/download_avatar_image/#{user_1.id}"
    }
    context "アバターが設定されている場合" do
      before {
        user_1.avatar_image.attach(io: avatar_image, filename: "#{Time.now.to_i}_#{user.id}.jpg" , content_type: "image/jpg" )
      }
      it "設定済みの画像がダウンロードできること" do
        allow(TokenService).to receive(:authorization).and_return(user)
        subject
        expect(response).to have_http_status 200
        expect(response.body.size).to eq avatar_image.size
      end
    end

    context "アバターが設定されていない場合" do
      let!(:default_avatar_image) {
        File.open('app/assets/images/default_avatar_image.png') do |file|
          file.read
        end
      }
      it "未設定の場合の画像がダウンロードできること" do
        allow(TokenService).to receive(:authorization).and_return(user)
        subject
        expect(response).to have_http_status 200
        expect(response.body.size).to eq default_avatar_image.size
      end
    end
  end
end
