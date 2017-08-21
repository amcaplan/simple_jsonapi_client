require 'spec_helper'

RSpec.describe 'deleting models' do
  let(:client) { JSONAPIAppClient.new }
  let(:connection) { client.connection }

  def create_author(name)
    JSONAPIAppClient::Author.create(
      name: name,
      connection: connection
    )
  end

  def fetch_author(id)
    JSONAPIAppClient::Author.fetch(
      connection: connection,
      url_opts: { id: id }
    )
  end

  describe 'deleting an Author' do
    context 'Given the Author already exists' do
      let!(:author) { create_author('Filbert') }

      context 'deleting on the model level' do
        it 'deletes the Author' do
          expect(author.delete).to eq(true)
          expect { fetch_author(author.id) }.to raise_error(SimpleJSONAPIClient::Errors::NotFoundError)
        end
      end

      context 'deleting on the class level' do
        it 'deletes the Author' do
          expect(JSONAPIAppClient::Author.delete(
            url_opts: { id: author.id },
            connection: connection
          )).to eq(true)
          expect { fetch_author(author.id) }.to raise_error(SimpleJSONAPIClient::Errors::NotFoundError)
        end
      end
    end

    context 'Given the Author does not exist' do
      let(:author) {
        JSONAPIAppClient::Author.new(id: 'nonexistent', connection: connection)
      }

      context 'deleting on the model level' do
        it 'deletes the Author' do
          expect { author.delete }.to raise_error(SimpleJSONAPIClient::Errors::BadRequestError)
        end
      end

      context 'deleting on the class level' do
        it 'deletes the Author' do
          expect {
            JSONAPIAppClient::Author.delete(
              url_opts: { id: author.id },
              connection: connection
            )
          }.to raise_error(SimpleJSONAPIClient::Errors::BadRequestError)
        end
      end
    end
  end
end
