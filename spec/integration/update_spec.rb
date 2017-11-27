require 'spec_helper'

RSpec.describe 'updating models' do
  let(:client) { JSONAPIAppClient.new }
  let(:connection) { client.connection }

  def fetch_authors
    JSONAPIAppClient::Author.fetch_all(connection: connection)
  end

  def fetch_author(id)
    JSONAPIAppClient::Author.fetch(
      connection: connection,
      url_opts: { id: id }
    )
  end

  def create_author(name)
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

  context 'Given an Author' do
    let(:author) { create_author(original_name) }
    let(:original_name) { 'Walnut' }
    let(:changed_name) { 'Pistachio' }

    it "updates the Author's name from the model" do
      expect { author.update(name: changed_name) }.
        to change { fetch_author(author.id).name }.
        from(original_name).to(changed_name)
    end

    it "updates the Author's name from the class" do
      expect { JSONAPIAppClient::Author.update(
        id: author.id,
        url_opts: { id: author.id },
        name: changed_name,
        connection: connection
      ) }.
        to change { fetch_author(author.id).name }.
        from(original_name).to(changed_name)
    end

    describe 'passing attributes and relationships explicitly' do
      let(:post) { create_post(author: author, title: original_title, text: 'I love everything!') }
      let(:original_title) { 'Love' }
      let(:changed_title) { 'Looooove' }
      let(:author2) { create_author('Hazelnut') }

      it "updates the Post's title" do
        expect { post.update(attributes: { title: changed_title }) }.
          to change { fetch_post(post.id).title }.
          from(original_title).to(changed_title)
      end

      it "updates the Post's author" do
        expect { post.update(relationships: { author: author2 }) }.
          to change { fetch_post(post.id).author.id }.
          from(author.id).to(author2.id)
      end

      context 'a relationship is changed to null' do
        it "updates the Posts's author to null" do
          expect { post.update(relationships: { author: nil }) }.
            to change { fetch_post(post.id).author.as_json }.
            from(post.author.as_json).to(nil)
        end
      end
    end
  end
end
