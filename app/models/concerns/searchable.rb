module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    mapping do
        indexes :content, type: 'text'
    end

    def self.search(query_str, chat_id)
        params = {
            query: {
                bool: {
                    must: [
                    {
                        terms: {
                        chat_id: [chat_id]
                        }
                    },
                    {
                        wildcard: {
                            content: "*#{query_str}*"
                        }
                    }
                    ]
                }
            }
        }

         self.__elasticsearch__.search(params).response.hits.to_a
    end
  end
end
