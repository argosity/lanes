module Lanes
    module Concerns

        # @see ClassMethods
        module VisibleIdIdentifier

            extend ActiveSupport::Concern

            module InstanceMethods

                # setup the visible id to the next available #{Lanes::SequentialId}
                # @return [Integer] the assigned ID
                def assign_visible_id!
                    self.visible_id = Lanes::SequentialId.next_for( self.class )
                end
            end


            # ### Visible ID Identifier Concern
            # This adds the {#has_visible_id} class methods
            module ClassMethods

                # An auto-incrementing number that's user-visible.
                # The visible_id is stored as an integer, but a string index is generated for
                # querying by the sql like operator. The **with_visible_id** scope is available for this purpose
                #
                # The next number an also be adjusted by the end-user by setting {Lanes::SequentialId}
                # so they can set the numbers to start at
                # a specific point, which is useful for getting Invoice and other
                # numbers to match up to a legacy system
                def has_visible_id
                    include InstanceMethods
                    validates :visible_id, :presence=>{
                                  :message=>"ID was not set (should be automatically chosen)"
                              }
                    alias_attribute :record_identifier, :visible_id
                    before_validation :assign_visible_id!, :on=>:create

                    export_scope :with_visible_id, lambda{ | visid |
                        if visid.to_s =~/%/
                            where( 'cast(visible_id as varchar) like ?', visid.to_s )
                        else
                            where( 'cast(visible_id as varchar) = ?',    visid.to_s )
                        end
                    }

                end

            end
        end

    end
end