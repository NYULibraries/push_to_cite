require 'spec_helper'

describe CallingSystems::Primo do

  let(:local_id) { 'ERESDSB000140704' }
  let(:institution) { 'NYU' }
  let(:primo) { CallingSystems::Primo.new(local_id, institution) }

  describe '.new' do
    subject { primo }
    it { is_expected.to be_an_instance_of CallingSystems::Primo }
    its(:local_id) { is_expected.to eql local_id }
    its(:institution) { is_expected.to eql institution }
  end

  describe '#get_openurl' do
    subject { primo.get_openurl }
    context 'when link field is populated' do
      it { is_expected.to include "rfr_id=info:sid/primo.exlibrisgroup.com:primo-#{local_id}" }
    end
  end

end
