require 'spec_helper'

describe 'ApplicationController' do
  def app() ApplicationController end

  let(:local_id) { 'nyu_aleph004508721' }
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
  let(:missing_params_error_message) {
    'We could not export or download this citation because of missing data in the parameters. Please use the link below to report this problem.'
  }
  let(:bad_data_message) {
    'We could not export or download this citation because of missing or incomplete data in the catalog record. Please use the link below to report this problem.'
  }
  let(:include_id_message) {
    'Make sure to include the following ID in your report:'
  }

  describe "GET /healthcheck" do
    before { get "/healthcheck" }
    subject { last_response }
    its(:status) { is_expected.to eq 200 }
    its(:body) { is_expected.to eq "{\"success\":true}" }
  end

  describe "GET /:identifier", vcr: true do
    before do
      get "/#{local_id}", params
    end

    describe 'error messages when required params are missing' do
      subject { last_response.body }
      context 'when local_id is missing' do
        let(:local_id) { nil }
        it { is_expected.to include missing_params_error_message }
      end
      context 'when cite_to is missing' do
        let(:cite_to) { nil }
        it { is_expected.to include missing_params_error_message }
      end
      context 'when institution is missing' do
        let(:institution) { nil }
        it { is_expected.to include missing_params_error_message }
      end
      context 'when calling_system is missing' do
        let(:calling_system) { nil }
        it { is_expected.to include missing_params_error_message }
      end
    end

    describe 'error message when local_id cannot be found in primo API' do
      subject { last_response.body }
      context 'when local_id returns an error from the API' do
        let(:local_id) { 'nyu_aleph' }
        it { is_expected.to include bad_data_message }
        it { is_expected.to include include_id_message }
        it { is_expected.to include local_id }
      end
    end

    describe 'responses when all required parameters are present' do
      subject { last_response }
      context 'and cite_to is RIS' do
        let(:cite_to) { 'ris' }
        its(:body) { is_expected.to include 'Pinsker, Sanford' }
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
        its(:body) { is_expected.to include 'Pinsker, Sanford' }
      end
      context 'and cite_to is OpenURL' do
        let(:cite_to) { 'openurl' }
        its(:status) { is_expected.to eql 303 }
        its(:body) { is_expected.to eql '' }
      end
    end
  end
end
