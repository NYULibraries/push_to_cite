require 'spec_helper'

describe 'ApplicationController' do
  def app() ApplicationController end

  let(:external_id) { 'nyu_aleph004508721' }
  let(:calling_system) { 'primo' }
  let(:cite_to) { 'ris' }
  let(:institution) { 'NYU' }
  let(:params) do
    {
    calling_system: calling_system,
    cite_to: cite_to,
    institution: institution
    }
  end
  let(:missing_params_message) {
    'We could not export or download this citation because of missing or incorrect data in the parameters. Please use the link below to report this problem.'
  }
  let(:bad_data_message) {
    'We could not export or download this citation because of missing or incomplete data in the catalog record. Please use the link below to report this problem.'
  }
  let(:include_id_message) {
    'Make sure to include the following ID in your report:'
  }
  let(:too_many_records_message) {
    'You have requested too many records to be exported/downloaded. Please limit your request to 10 records at a time.'
  }

  describe "GET /healthcheck" do
    before { get "/healthcheck" }
    subject { last_response }
    its(:status) { is_expected.to eq 200 }
    its(:body) { is_expected.to eq "{\"success\":true}" }
  end

  describe 'GET /m/:identifier', vcr: true do
    before { get "/m/#{external_id}", params }
    subject { last_response }
    its(:status) { is_expected.to eq 200 }
    its(:body) { is_expected.to include 'Refworks Tagged Format' }
    its(:body) { is_expected.to include 'RIS' }
    its(:body) { is_expected.to include 'BibTeX' }
    its(:body) { is_expected.to include 'OpenURL' }
    its(:body) { is_expected.to include '<textarea aria-label="Export data" class="raw-data">' }
    its(:body) { is_expected.to include 'https://nyu.qualtrics.com/jfe/form/SV_8AnbZWUryVfpWXH' }
    its(:body) { is_expected.to include 'Report a mapping or metadata problem' }
    its(:body) { is_expected.to include "http://bobcatdev.library.nyu.edu/primo_library/libweb/webservices/rest/v1/pnxs/L/#{external_id}?inst=#{institution}" }
    its(:body) { is_expected.to include 'View the raw PNX JSON (IP restricted)' }
  end

  describe "GET /:identifier", vcr: true do
    before do
      get "/#{external_id}", params
    end

    describe 'error messages when required params are missing' do
      subject { last_response.body }
      context 'when external_id is missing' do
        let(:external_id) { nil }
        it { is_expected.to include missing_params_message }
      end
      context 'when cite_to is missing' do
        let(:cite_to) { nil }
        it { is_expected.to include missing_params_message }
      end
      context 'when institution is missing' do
        let(:institution) { nil }
        it { is_expected.to include 'TY  - BOOK' }
      end
      context 'when calling_system is missing' do
        let(:calling_system) { nil }
        it { is_expected.to include 'TY  - BOOK' }
      end
    end

    describe 'error message when external_id cannot be found in primo API' do
      subject { last_response.body }
      context 'when external_id returns an error from the API' do
        let(:external_id) { 'nyu_aleph' }
        it { is_expected.to include bad_data_message }
        it { is_expected.to include include_id_message }
        it { is_expected.to include external_id }
      end
    end

    describe 'responses when all required parameters are present' do
      subject { last_response }
      context 'and cite_to is RIS' do
        let(:cite_to) { 'ris' }
        its(:body) { is_expected.to include 'TY  - BOOK' }
        its(:body) { is_expected.to include 'Pinsker, Sanford' }
        its(:body) { is_expected.to include 'ER' }
      end
      context 'and cite_to is EndNote' do
        let(:cite_to) { 'endnote' }
        its(:status) { is_expected.to eql 303 }
      end
      context 'and cite_to is BibTex' do
        let(:cite_to) { 'bibtex' }
        its(:body) { is_expected.to include 'Pinsker, Sanford' }
      end
      context 'and cite_to is RefWorks' do
        let(:cite_to) { 'refworks' }
        its(:body) { is_expected.to include 'RT Book, Whole' }
        its(:body) { is_expected.to include 'Pinsker, Sanford' }
        its(:body) { is_expected.not_to include 'ER' }
      end
      context 'and cite_to is OpenURL' do
        let(:cite_to) { 'openurl' }
        its(:status) { is_expected.to eql 303 }
        its(:body) { is_expected.to eql '' }
      end
    end
  end

  describe "POST /", vcr: true do
    let(:cite_to) { 'ris'}
    let(:external_id_array) {
      ['nyu_aleph005399773','nyu_aleph000802014']
    }
    let(:params) {
      {
        external_id: external_id_array,
        calling_system: calling_system,
        cite_to: cite_to,
        institution: institution
      }
    }
    before do
      post "/", params
    end
    subject { last_response }

    context 'when fewer than 10 ids are posted' do
      its(:body) { is_expected.to include 'TY  - BOOK' }
      its(:body) { is_expected.to include 'A1  - Gilroy, Beryl' }
      its(:body) { is_expected.to include 'ER' }
      its(:body) { is_expected.to include 'TY  - SOUND' }
      its(:body) { is_expected.to include 'A1  - Thelonious Monk Quintet, performe' }
    end
    context 'when greater than 10 ids are posted' do
      let(:external_id_array) {
        ['1','2','3','4','5','6','7','8','9','10','11']
      }
      its(:body) { is_expected.to include too_many_records_message }
    end

    context 'when external_id is missing' do
      let(:params) {
        {
          calling_system: calling_system,
          cite_to: cite_to,
          institution: institution
        }
      }
      its(:body) { is_expected.to include missing_params_message }
    end

  end
end
