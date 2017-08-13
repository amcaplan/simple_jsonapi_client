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

    context 'Given invalid parameters' do
      let(:name) { 'TOOLONGNAME' * 500 }

      it 'fails to create the Author' do
        expect { client.create_author(name: name) }.to raise_error { SimpleJSONAPIClient::Base::UnprocessableEntityError }
      end
    end
  end

  describe 'creating a Post' do
    context 'Given an Author already exists' do
      let!(:author) { client.create_author(name: 'Filbert') }
      let(:title) { 'A Very Proper Post Title' }
      let(:text) { 'I am absolutely incensed about something.' }

      it 'creates a Post associated with that Author' do
        post = client.create_post(author: author, title: title, text: text)
        expect(author.posts.first.id).to eq(post.id)
      end
    end
  end
end
