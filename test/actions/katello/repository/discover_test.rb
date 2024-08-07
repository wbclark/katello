require 'katello_test_helper'

module EncryptionKey
  ENCRYPTION_KEY = nil
end

module Actions
  describe Katello::Repository::Discover do
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

    let(:action_class) { ::Actions::Katello::Repository::Discover }

    def setup
      get_organization #ensure we have an org label
    end

    def test_discovers_without_encryption
      EncryptionKey.const_set(:ENCRYPTION_KEY, nil)

      mock_discovery = mock
      url = 'http://foo.com'
      repo_discovery_class = mock
      ::Katello::RepoDiscovery.expects(:class_for).with('yum').returns(repo_discovery_class)
      repo_discovery_class.expects(:new).with(url, [], [], [url], {upstream_username: 'admin', upstream_password: 'secret', search: nil}).returns(mock_discovery)
      mock_discovery.expects(:run).with(url).once

      task = ForemanTasks.sync_task(action_class, url, 'yum', 'admin', 'secret', nil)

      refute_empty task.input[:upstream_password]
      assert_equal task.input[:upstream_password], 'secret'
    end

    def test_discovers_with_hidden_password
      EncryptionKey.const_set(:ENCRYPTION_KEY, 'ebf26a286b3edec3d31ac10e8e97bd60')

      mock_discovery = mock
      url = 'http://foo.com'
      repo_discovery_class = mock
      ::Katello::RepoDiscovery.expects(:class_for).with('yum').returns(repo_discovery_class)
      repo_discovery_class.expects(:new).with(url, [], [], [url], {upstream_username: 'admin', upstream_password: 'secret', search: nil}).returns(mock_discovery)
      mock_discovery.expects(:run).with(url).once

      task = ForemanTasks.sync_task(action_class, url, 'yum', 'admin', 'secret', nil)

      refute_empty task.input[:upstream_password]
      refute_equal task.input[:upstream_password], 'secret'
    end
  end
end
