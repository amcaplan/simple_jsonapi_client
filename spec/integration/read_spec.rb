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

  def create_post(author:, title:, text:)
    JSONAPIAppClient::Post.create(
      attributes: { title: title, text: text },
      relationships: { author: author },
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
      let(:author) { create_author }
      let(:id) { author.id }
      let(:name) { 'Macadamia' }

      it 'finds the model' do
        expect(fetch_author(id).name).to eq(name)
      end

      context 'fetching plural relationships' do
        context 'Given the relationships are absent' do
          it 'returns an empty Array' do
            expect(fetch_author(id).posts).to be_empty
          end
        end

        context 'Given the relationships are present' do
          let!(:post) { create_post(author: author, title: title, text: text) }
          let(:title) { 'The System is Down' }
          let(:text) { 'The Cheat' }

          it 'returns the related models' do
            posts = fetch_author(id).posts
            expect(posts.length).to eq(1)
            expect(posts.first).to be_same_record_as(post)
          end
        end
      end
    end
  end
end
