# Use this code snippet in your app.
# If you need more information about configurations or implementing the sample code, visit the AWS docs:
# https://aws.amazon.com/developer/language/ruby/

class SecretKeyService
  require 'aws-sdk-secretsmanager'

  class << self
    def get_secret
      begin
        secret = get_secret_from_current_key
        return secret if secret

        get_secret_from_ssm
      rescue StandardError => e
        raise e
      end
    end

    private
      def get_secret_from_ssm
        client = Aws::SecretsManager::Client.new(region: 'ap-northeast-1')

        begin
          get_secret_value_response = client.get_secret_value(secret_id: 'sandbox/school-of-movie-authkey')
        rescue StandardError => e
          # For a list of exceptions thrown, see
          # https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
          raise e
        end
        secret = get_secret_value_response.secret_string['school-of-movie-service-key']

        secret = JSON.parse(get_secret_value_response.secret_string.gsub("\n", '\\n'))['school-of-movie-service-key'].split("\n").join("\n")
        OpenSSL::PKey::RSA.new(secret)
      end

      def get_secret_from_current_key
        path = Rails.root.join('auth/service.key')

        return unless File.exist?(path)
        OpenSSL::PKey::RSA.new(File.read(path))
      end
  end
end
