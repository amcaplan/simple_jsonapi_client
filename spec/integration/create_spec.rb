require 'spec_helper'

RSpec.describe 'creating models' do
  let(:client) { JSONAPIAppClient.new }

  def authors
    client.fetch_authors
  end

  describe 'creating an Author' do
    context 'Given valid parameters' do
      let(:name) { 'Filbert' }

      it 'creates the Author' do
        expect { client.create_author(name: name) }.to change { client.fetch_authors.size }.by(1)
      end

      it "preserves the Author's attributes" do
        author = client.create_author(name: name)
        expect(author.name).to eq(name)
        reloaded_author = client.fetch_author(author.id)
        expect(reloaded_author.name).to eq(name)
      end
    end
  end
end
