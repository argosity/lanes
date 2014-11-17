class Lanes::User
end

module Lanes::Concerns

    # Extends Rails updated_by and created_by timestamps to also track who created and updated the model.
    # It reads the current user's id from User.current_id when saving and updating the record
    # The class_name for the created_by and updated_by is set to {Lanes::Configuration#user_model}
    module TrackModifications
        extend ActiveSupport::Concern

        included do
            class_attribute :record_modifications, :instance_writer=>false
            self.record_modifications = true

            belongs_to :created_by, :class_name=>Lanes::User
            belongs_to :updated_by, :class_name=>Lanes::User

            self.blacklist_attributes :created_at, :updated_at, :created_by_id, :updated_by_id
            before_update :record_update_modifications
            before_create :record_create_modifications
        end

        private

        def _record_user_to_column( column )
            user_id = Lanes::User.current_id ? Lanes::User.current_id : 0
            write_attribute( column, user_id ) if self.class.column_names.include?( column )
        end

        def record_create_modifications
            if self.record_modifications
                _record_user_to_column('updated_by_id')
                _record_user_to_column('created_by_id')
            end
            true
        end

        def record_update_modifications
            if self.record_modifications && should_record_timestamps?
                _record_user_to_column('updated_by_id')
            end
            true
        end

        def change_tracking_fields
            %w{updated_by_id created_by_id updated_at created_at}
        end
    end

end
