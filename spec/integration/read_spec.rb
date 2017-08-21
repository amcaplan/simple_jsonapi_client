require 'spec_helper'

RSpec.describe 'reading models' do
  let(:client) { JSONAPIAppClient.new }
  let(:connection) { client.connection }

  def fetch_author(id, includes: [])
    JSONAPIAppClient::Author.fetch(
      connection: connection,
      url_opts: { id: id },
      includes: includes
    )
  end

  def create_author
    JSONAPIAppClient::Author.create(
      name: name,
      connection: connection
    )
  end

  def fetch_post(id)
    JSONAPIAppClient::Post.fetch(
      connection: connection,
      url_opts: { id: id }
    )
  end

  def create_post(author:, title:, text:)
    JSONAPIAppClient::Post.create(
      title: title,
      text: text,
      author: author,
      connection: connection
    )
  end

  def create_comment(author:, post:, text:)
    JSONAPIAppClient::Comment.create(
      text: text,
      author: author,
      post: post,
      connection: connection
    )
  end

  context 'fetching an individual model' do
    context 'using a nonexistent id' do
      let(:id) { 'foobar' }

      it 'raises a NotFoundError' do
        expect { fetch_author(id) }.to raise_error { SimpleJSONAPIClient::Errors::NotFoundError }
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

          context 'Leveraging includes' do
            let!(:comment) { create_comment(author: author, post: post, text: 'What a silly article!') }
            let(:returned_author) { fetch_author(id, includes: ['posts.comments']) }

            it 'uses includes to avoid creating new objects' do
              returned_author
              expect(connection).not_to receive(:get)
              expect(returned_author.posts.first.comments.first.text).to eq(comment.text)
            end
          end
        end
      end
    end
  end

  context 'fetching a relationship that does not exist' do
    let(:post) { create_post(author: nil, title: 'Title', text: 'Content!') }

    it 'returns nil' do
      expect(fetch_post(post.id).author).to be_nil
    end
  end
end
