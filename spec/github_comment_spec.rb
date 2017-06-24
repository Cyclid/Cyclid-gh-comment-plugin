# frozen_string_literal: true

require 'spec_helper'

describe Cyclid::API::Plugins::GithubComment do
  it 'should create an instance' do
    expect do
      Cyclid::API::Plugins::GithubComment.new(repo: 'test/repo',
                                              number: 42,
                                              comment: 'comment')
    end.to_not raise_error
  end

  let :subject do
    Cyclid::API::Plugins::GithubComment.new
  end

  let :client do
    instance_double(Octokit::Client)
  end

  before do
    octokit = class_double(Octokit::Client).as_stubbed_const
    allow(octokit).to receive(:new).and_return(client)

    github = class_double(Cyclid::API::Plugins::Github).as_stubbed_const
    allow(github).to receive(:get_config)
      .with('test')
      .and_return('config' => { 'oauth_token' => '0123456789abcdef' })
  end

  context 'with a comment' do
    let :comment do
      'this is a comment'
    end

    it 'should add the comment' do
      allow(client).to receive(:add_comment).with('test/repo', '42', comment).and_return true

      plugin = Cyclid::API::Plugins::GithubComment.new(repo: 'test/repo',
                                                       number: 42,
                                                       comment: comment)
      plugin.prepare(ctx: { organization: 'test' })
      expect(plugin.perform(nil)).to match_array [true, 0]
    end
  end

  context 'with a path' do
    let :content do
      'this is a file'
    end

    let :transport do
      transport = instance_double(Cyclid::API::Plugins::Transport)
      allow(transport).to receive(:download).with(any_args, '/path/to/file') do |io, _path|
        io.write(content)
      end

      transport
    end

    it 'should read the file and add the comment' do
      allow(client).to receive(:add_comment).with('test/repo', '42', content).and_return true

      plugin = Cyclid::API::Plugins::GithubComment.new(repo: 'test/repo',
                                                       number: 42,
                                                       path: '/path/to/file')
      plugin.prepare(ctx: { organization: 'test' }, transport: transport)
      expect(plugin.perform(nil)).to match_array [true, 0]
    end
  end

  context 'without the correct arguments' do
    it 'fails if no repo is given' do
      expect do
        Cyclid::API::Plugins::GithubComment.new(number: 42,
                                                comment: 'test')
      end
        .to raise_error 'a github comment action requires a repository'
    end

    it 'fails if no number is given' do
      expect do
        Cyclid::API::Plugins::GithubComment.new(repo: 'test/repo',
                                                comment: 'test')
      end
        .to raise_error 'a github comment action requires an issue number'
    end

    it 'fails if no comment & path are given' do
      expect do
        Cyclid::API::Plugins::GithubComment.new(repo: 'test/repo',
                                                number: 42)
      end
        .to raise_error 'a github comment action requires a comment or file'
    end
  end
end
