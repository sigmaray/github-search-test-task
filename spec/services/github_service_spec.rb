require 'rails_helper'

RSpec.describe GithubSearchService, type: :model do
  before(:each) do
    WebMock.disable_net_connect!
    stub_request(:get, /api.github.com/)
      .to_return(status: status, body: body)
  end

  subject { -> { GithubSearchService.search('Paris') } }

  context '200' do
    let(:status) { 200 }

    context 'valid json' do
      let(:body) { File.read('spec/fixtures/github.valid.json') }

      it { expect(subject.call.count).to eq(30) }
      it { expect(subject.call.first).to respond_to(:name, :html_url, :stargazers_count, :owner) }
    end

    context 'no results' do
      let(:body) { File.read('spec/fixtures/github.no_results.json') }

      it { expect(subject.call).to eq([]) }
    end

    context 'invalid json' do
      let(:body) { File.read('spec/fixtures/github.invalid.json') }

      it { expect { subject.call }.to raise_error(GithubSearchService::ParsingError) }
    end

    context 'flickr json' do
      let(:body) { File.read('spec/fixtures/flickr.json') }

      it { expect { subject.call }.to raise_error(GithubSearchService::ParsingError) }
    end

    context 'empty object' do
      let(:body) { '{}' }

      it { expect { subject.call }.to raise_error(GithubSearchService::ParsingError) }
    end

    context 'zero' do
      let(:body) { '' }

      it { expect { subject.call }.to raise_error(GithubSearchService::ParsingError) }
    end
  end

  context '403' do
    let(:status) { 403 }
    let(:body) { File.read('spec/fixtures/github.exceed.json') }

    it { expect { subject.call }.to raise_error(GithubSearchService::RateLimitExceededError) }
  end

  context '500' do
    let(:status) { 500 }
    let(:body) { 'Internal Server Error' }

    it { expect { subject.call }.to raise_error(GithubSearchService::ServerError) }
  end
end
