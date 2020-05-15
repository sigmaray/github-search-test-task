require 'rails_helper'

describe 'search', type: :feature do
  before :each do
    WebMock.disable_net_connect!
    stub_request(:get, /api.github.com/)
      .to_return(status: status, body: body)
    visit '/'
    fill_in 'Search Query', with: 'Paris'
    click_button 'Search'
  end

  context '200' do
    let(:status) { 200 }
    context 'valid json' do
      let(:body) { File.read('spec/fixtures/github.valid.json') }

      it 'should show search results' do
        expect(page).to have_content 'Showing search results for "Paris"'
        expect(page).to have_selector('table', count: 30)
        ['Name', 'Html Url', 'Stargazers Count', 'Owner'].each do |item|
          expect(page).to have_content item
        end
      end
    end

    context 'no results' do
      let(:body) { File.read('spec/fixtures/github.no_results.json') }

      it { expect(page).to have_content 'No results found' }
    end
  end

  context '403' do
    let(:status) { 403 }
    let(:body) { File.read('spec/fixtures/github.exceed.json') }

    it { expect(page).to have_content 'Too many search requests. Please wait 30 seconds' }
  end

  context '500' do
    let(:status) { 500 }
    let(:body) { 'Internal Server Error' }

    it { expect(page).to have_content 'API server error: 500' }
  end
end
