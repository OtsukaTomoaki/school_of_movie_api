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
        email: "#{User.count}_bar@gmail.com",
        password: 'Bar1234')
    end
  }
  let!(:user) {
    user = FactoryBot.create(:user,
      name: 'FOO_BAR_テスト',
      email: "foo_bar_baz@sample.com",
      password: 'pass1234')
    user
  }

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
end
