# frozen_string_literal: true

# Copyright 2017 Liqwyd Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'octokit'

# Top level module for the core Cyclid code.
module Cyclid
  # Module for the Cyclid API
  module API
    # Module for Cyclid Plugins
    module Plugins
      # Post a comment to a Github plugin (including Pull Requests)
      class GithubComment < Action
        Cyclid.logger.debug 'in the Github Comment plugin'

        def initialize(args = {})
          args.symbolize_keys!

          # There must be a repository name.
          raise 'a github comment action requires a repository' unless args.include? :repo

          # There must be an issue number.
          raise 'a github comment action requires an issue number' unless args.include? :number

          @repo = args[:repo]
          @number = args[:number].to_s

          @comment = args[:comment] if args.include? :comment
          @path = args[:path] if args.include? :path

          # There must be either a comment or a file to read as a comment
          raise 'a github comment action requires a comment or file' if @comment.nil? && @path.nil?
        end

        def perform(_log)
          raise 'no OAuth token is available' if oauth_token.nil?

          # If a path was given, read the file and use it as the comment
          if @path
            content = StringIO.new
            @transport.download(content, @path**@ctx)
            @comment = content.string
          end

          # Insert context
          repo = @repo**@ctx
          number = @number**@ctx
          comment = @comment**@ctx

          # Append the comment
          client = Octokit::Client.new(access_token: oauth_token)
          client.add_comment(repo, number, comment)
        end

        # Register this plugin
        register_plugin 'github_comment'

        private

        def config
          # Retrieve the configuration
          plugin_config = Cyclid::API::Plugins::Github.get_config(@ctx[:organization])
          plugin_config['config']
        end

        def oauth_token
          @token ||= config['oauth_token']
        end
      end
    end
  end
end
