require 'test_helper'

class FirebaseCloudMessenger::AuthClientTest < Minitest::Spec
  describe "::new" do
    it "throws an ArgumentError if credentials_path, client_email and private-key vars aren't set" do
      ENV.stubs(:[]).with('GOOGLE_CLIENT_EMAIL').returns(nil)

      assert_raises ArgumentError do
        FirebaseCloudMessenger::AuthClient.new(nil)
      end
    end

    it "throws no error if env vars are set" do
      ENV.stubs(:[]).with('GOOGLE_PRIVATE_KEY').returns("1")
      ENV.stubs(:[]).with('GOOGLE_CLIENT_EMAIL').returns("2")

      Google::Auth::ServiceAccountCredentials.stubs(:make_creds)

      FirebaseCloudMessenger::AuthClient.new(nil)
    end
  end

  describe "::fetch_access_token_info" do
    it "calls out to the Google::Auth service and returns access token info hash with creds file" do
      credentials_path = "path/to/credentials.json"
      authorizer = mock('authorizer')
      creds_file = mock('creds_file')
      File.expects(:open).with(credentials_path).returns(creds_file)
      creds_file.expects(:close)

      Google::Auth::ServiceAccountCredentials.expects(:make_creds).with(json_key_io: creds_file, scope: FirebaseCloudMessenger::AuthClient::AUTH_SCOPE).returns(authorizer)

      token_response = { "access_token" => "12345", "token_type" => "Bearer", "expires_in" => "soon" }
      authorizer.expects(:fetch_access_token!).returns(token_response)

      access_token_info = FirebaseCloudMessenger::AuthClient.new(credentials_path).fetch_access_token_info

      assert_equal "12345", access_token_info["access_token"]
    end

    it "calls out to the Google::Auth service and returns access token info with env vars" do
      ENV.stubs(:[]).with('GOOGLE_PRIVATE_KEY').returns("1")
      ENV.stubs(:[]).with('GOOGLE_CLIENT_EMAIL').returns("2")

      authorizer = mock('authorizer')
      token_response = { "access_token" => "12345", "token_type" => "Bearer", "expires_in" => "soon" }
      authorizer.expects(:fetch_access_token!).returns(token_response)

      Google::Auth::ServiceAccountCredentials.expects(:make_creds).with(scope: FirebaseCloudMessenger::AuthClient::AUTH_SCOPE).returns(authorizer)

      access_token_info = FirebaseCloudMessenger::AuthClient.new.fetch_access_token_info

      assert_equal "12345", access_token_info["access_token"]
    end
  end
end
