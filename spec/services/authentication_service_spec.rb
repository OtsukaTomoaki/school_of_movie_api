require 'rails_helper'

RSpec.describe AuthenticationService, type: :service do
  let!(:user) do
    FactoryBot.create(:user,
      name: 'Nancy Molgan',
      email: 'nancy-pancy-denpcy@gmail.com',
      password: 'saikyounoP@ssw0rd')
  end
  let!(:email_that_does_not_exist) {
    'email_that_does_not_exist@gmail.com'
  }

  describe 'authenticate_user_with_token' do
    context "正しいjwtが引数に指定された場合" do
      let!(:jwt) { jwt = TokenService.issue_by_password!(user.email, user.password) }
      it "ユーザの情報を取得できる" do
        expect(AuthenticationService.authenticate_user_with_token!(jwt)).to eq user
      end
    end

    context "期限切れのjwtが引数に指定された場合" do
      let!(:expired_jwt) { 'eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiI5MTE1Y2M3Ny0zMDQ3LTQ2YTItYTA1My0xNWRhMDA3YmY3ZTUiLCJuYW1lIjoidG9tb2FraSIsImV4cCI6MTY3MjcyMjQyMH0.CDIk-ljuhlhIrGWsGer6V1gajRopv07t6JsJ3WwKjNtMbgrYSzyipDvrOrr9xktnVGFVVz4c7mxocPzfAHVFe4jR9xa32rODQXxSlaOTPjBPqlL-fyTrkvTVRXpFoW_0GzOGukqqwY0r0Ucr7aYxn-iN0JARJ9S15O5JLVH4s56XwL5i2QXpT35grwIhb3fwHPLpZhMAQ-auXCFr0MKV390y8t4Nm0shASqaT14hTuQ2DdpGm31eZ-1tEvPKNj5nGmvGDQGQgNgnSJhNaIrUtYi8HAjfLnasxvnKkSckTLo08TMw6O29P77ZS7mJjynzMgKZC--KJbIG3l6ZCQ' }
      it "UnAuthorizationErrorが取得できる" do
        expect do
          AuthenticationService.authenticate_user_with_token!(expired_jwt)
        end.to raise_error(CustomException::UnAuthorizationError)
      end
    end

    context "署名が誤っているjwtが引数に指定された場合" do
      let!(:invalid_signature_jwt) {
        jwt = TokenService.issue_by_password!(user.email, user.password)
        jwt[0..-3]
      }
      it "UnAuthorizationErrorが取得できる" do
        expect do
          AuthenticationService.authenticate_user_with_token!(invalid_signature_jwt)
        end.to raise_error(CustomException::UnAuthorizationError)
      end
    end
  end

  describe "authenticate_user_with_password!" do
    context "email, passwordが正しい場合" do
      it "Userのインスタンスが返される" do
        expect(AuthenticationService.authenticate_user_with_password!(
          user.email,
          user.password)).to eq user
      end
    end

    context "存在しないユーザのemailの場合" do
      it "UnAuthorizationErrorが返される" do
        expect do
          AuthenticationService.authenticate_user_with_password!(email_that_does_not_exist, user.password)
        end.to raise_error(CustomException::UnAuthorizationError)
      end
    end

    context "passwordが誤っている場合" do
      it "UnAuthorizationErrorが返される" do
        expect do
          AuthenticationService.authenticate_user_with_password!(user.email, 'password')
        end.to raise_error(CustomException::UnAuthorizationError)
      end
    end
  end

  describe 'authenticate_user_with_remenber_token' do
    context "email, remember_tokenが正しい場合" do
      it "Userのインスタンスが返される" do
        user.remember
        expect(AuthenticationService.authenticate_user_with_remenber_token!(
          'nancy-pancy-denpcy@gmail.com',
          user.remember_token)).to eq user
      end
    end

    context "存在しないユーザのemailの場合" do
      let!(:valid_remember_token) {
        user.remember
        user.remember_token
      }
      it "UnAuthorizationErrorが返される" do
        expect do
          AuthenticationService.authenticate_user_with_remenber_token!(email_that_does_not_exist, valid_remember_token)
        end.to raise_error(CustomException::UnAuthorizationError)
      end
    end

    context "remember_tokenが誤っている場合" do
      let!(:outdated_remember_token) {
        user.remember
        remember_token = user.remember_token
        user.remember
        remember_token
      }
      it "UnAuthorizationErrorが返される" do
        expect do
          AuthenticationService.authenticate_user_with_remenber_token!(user.email, outdated_remember_token)
        end.to raise_error(CustomException::UnAuthorizationError)
      end
    end
  end

  describe 'authenticate_user_with_social_account' do
    let!(:social_account_id) {
      '12345'
    }
    let!(:social_account_mapping) {
      FactoryBot.create(:social_account_mapping,
        email: user.email,
        social_account_id: social_account_id,
        social_id: SocialAccountMapping.social_ids[:google]
      )
    }
    let!(:social_account_id_that_does_not_exist) {
      '9876'
    }
    context "email, social_account_id, social_typeが正しい場合" do
      it "Userのインスタンスが返される" do
        user.remember
        expect(AuthenticationService.authenticate_user_with_social_account!(
          user.email,
          social_account_mapping.social_account_id,
          :google)).to eq user
      end
    end

    xcontext "存在しないユーザのemailの場合" do
      it "UnAuthorizationErrorが返される" do
        expect do
          AuthenticationService.authenticate_user_with_social_account!(
            email_that_does_not_exist,
            social_account_mapping.social_account_id,
            :google)
        end.to raise_error(CustomException::UnAuthorizationError)
      end
    end

    xcontext "存在しないユーザのsocial_account_idの場合" do
      it "UnAuthorizationErrorが返される" do
        expect do
          AuthenticationService.authenticate_user_with_social_account!(
            user.email,
            social_account_id_that_does_not_exist,
            :google)
        end.to raise_error(CustomException::UnAuthorizationError)
      end
    end

    xcontext "存在しないユーザのsocial_idの場合" do
      it "UnAuthorizationErrorが返される" do
        expect do
          AuthenticationService.authenticate_user_with_social_account!(
            user.email,
            social_account_mapping.social_account_id,
            :service_that_does_not_exist)
        end.to raise_error(CustomException::UnAuthorizationError)
      end
    end
  end
end