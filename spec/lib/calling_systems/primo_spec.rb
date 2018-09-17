require 'spec_helper'

describe CallingSystems::Primo do

<<<<<<< HEAD
  let(:local_id) { 'nyu_aleph000455174' }
=======
  let(:local_id) { 'nyu_aleph004508721' }
>>>>>>> Make existing specs pass
  let(:institution) { 'NYU' }
  let(:primo) { CallingSystems::Primo.new(local_id, institution) }

  describe '.new' do
    subject { primo }
    it { is_expected.to be_an_instance_of CallingSystems::Primo }
    its(:local_id) { is_expected.to eql local_id }
    its(:institution) { is_expected.to eql institution }
  end

  describe '#get_pnx_json' do
    subject { primo.get_pnx_json }
    context 'when link field is populated' do
      its(['pnxId']) { is_expected.to eql local_id }
    end
  end

end
