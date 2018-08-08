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

  def fetch_authors(filter: {}, page: {}, includes: [])
    JSONAPIAppClient::Author.fetch_all(
      connection: connection,
      filter_opts: filter,
      page_opts: page,
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

  context 'fetching a plural model' do
    let!(:authors) {
      2.times.map { create_author }
    }

    def name
      @index ||= 0
      @index += 1
      "author#{@index}"
    end

    it 'returns the models' do
      expect(fetch_authors.map(&:id)).to eq(authors.map(&:id))
    end

    context 'filtering' do
      it 'returns only the models described by the filter' do
        first_fetched = fetch_authors(filter: { name: authors.first.name })
        expect(first_fetched.length).to eq(1)
        expect(first_fetched.first.id).to eq(authors.first.id)
      end
    end

    context 'specifying pagination' do
      it 'adjusts the pagination strategy' do
        expect(connection).to receive(:get).and_call_original.twice
        fetched = fetch_authors(page: { size: 1 })
        expect(fetched.map(&:id)).to eq(authors.map(&:id))
      end
    end

    context 'leveraging includes' do
      let!(:posts) {
        authors.map { |author|
          create_post(author: author, title: "A title", text: "Some text")
        }
      }
      let!(:comments) {
        posts.map.with_index { |post, index|
          create_comment(author: authors[index], post: post, text: 'What a silly article!')
        }
      }
      let(:returned_authors) { fetch_authors(includes: ['posts.comments']) }

      it 'uses includes to avoid new HTTP requests' do
        returned_authors.first
        expect(connection).not_to receive(:get)
        expect(returned_authors.first.posts.first.comments.first.text).to eq(comments.first.text)
      end
    end
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

            it 'uses includes to avoid new HTTP requests' do
              returned_author
              expect(connection).not_to receive(:get)
              expect(returned_author.posts.first.comments.first.text).to eq(comment.text)
            end
          end
        end
      end

      context 'fetching a model with metadata' do
        let(:post) { create_post(author: author, title: 'Title', text: 'Content!') }

        it 'returns the metadata' do
          expect(fetch_post(post.id).copyright).to eq("Copyright #{Time.now.year}")
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
