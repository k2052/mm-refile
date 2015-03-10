require 'refile/backend/file_system'
require 'refile'

Refile.cache = Refile::Backend::FileSystem.new(File.expand_path('../../files/cache', __FILE__))
Refile.store = Refile::Backend::FileSystem.new(File.expand_path('../../files/store', __FILE__))

module Refile
  module MongoMapper
    module Attachment
      extend ActiveSupport::Concern

      module ClassMethods
        include Refile::Attachment

        def attachment(name, raise_errors: false, **options)
          super
          attacher = "#{name}_attacher"

          validate do
            errors = send(attacher).errors
            self.errors.add(name, *errors) unless errors.empty?
          end

          key "#{name}_id".to_sym, String

          before_save do
            send(attacher).store!
          end

          after_destroy do
            send(attacher).delete!
          end
        end
      end
    end
  end
end
