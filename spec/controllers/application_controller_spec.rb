require 'spec_helper'

describe 'ApplicationController' do
  def app() ApplicationController end

  let(:local_id) { 'nyu_aleph004508721' }
  let(:calling_system) { 'primo' }
  let(:cite_to) { 'ris' }
  let(:institution) { 'NYU' }
  let(:params) do
    {
    local_id: local_id,
    calling_system: calling_system,
    cite_to: cite_to,
    institution: institution
    }
  end
  let(:missing_params_error_message) {
    'We could not export or download this citation because of missing data in the parameters. Please use the link below to report this problem.'
  }

  describe "GET /:identifier", vcr: true do
    subject { last_response.body }
    before do
      get "/", params
    end
    context 'when all required parameters are present' do
      it { is_expected.to include 'Pinsker, Sanford' }
    end
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
end
