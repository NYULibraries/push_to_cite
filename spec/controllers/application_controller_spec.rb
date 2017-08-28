require 'spec_helper'

describe 'ApplicationController' do
  def app() ApplicationController end

  let(:local_id) { 'nyu_aleph004934609' }
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
    'Missing parameter(s): All parameters are required (institution, local_id, cite_to, calling_system)'
  }

  describe "GET /:identifier", vcr: true do
    subject { last_response.body }
    before do
      get "/", params
    end
    context 'when all required parameters are present' do
      it { is_expected.to include 'action="http://web1.bobst.nyu.edu' }
      context 'but local_id is an invalid record' do
        let(:local_id) { 'somenonsense' }
        it { is_expected.to include "Invalid record: The local_id is either invalid or cannot be found." }
      end
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
