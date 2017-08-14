require 'spec_helper'

RSpec.describe 'reading models' do
  let(:client) { JSONAPIAppClient.new }
  let(:connection) { client.connection }

  def fetch_author(id)
    JSONAPIAppClient::Author.fetch(
      connection: connection,
      url_opts: { id: id }
    )
  end

  def create_author
    JSONAPIAppClient::Author.create(
      attributes: { name: name },
      connection: connection
    )
  end

  context 'fetching an individual model' do
    context 'using a nonexistent id' do
      let(:id) { 'foobar' }

      it 'raises a NotFoundError' do
        expect { fetch_author(id) }.to raise_error { SimpleJSONAPIClient::Base::NotFoundError }
      end
    end

    context 'using an id that exists' do
      let(:id) { create_author.id }
      let(:name) { 'Macadamia' }

      it 'finds the model' do
        expect(fetch_author(id).name).to eq(name)
      end
    end
  end
end
