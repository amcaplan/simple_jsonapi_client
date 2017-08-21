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
      expect { author.update(attributes: { name: changed_name }) }.
        to change { fetch_author(author.id).name }.
        from(original_name).to(changed_name)
    end

    it "updates the Author's name from the class" do
      expect { JSONAPIAppClient::Author.update(
        id: author.id,
        url_opts: { id: author.id },
        attributes: { name: changed_name },
        connection: connection
      ) }.
        to change { fetch_author(author.id).name }.
        from(original_name).to(changed_name)
    end
  end
end
