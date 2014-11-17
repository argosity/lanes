module Lanes
    module Concerns

        # @see ClassMethods
        module LockedFields
            extend ActiveSupport::Concern

            module ClassMethods
                # Mark fields as locked, meaning they cannot be updated by using the
                # regular attribute update methods.  Instead it must be called in an unlock block
                # Relies on attr_readonly internally
                #
                # Is used to designate sensitive fields that we want to make sure someone's thought about before updating
                # Also solves the age old single equals vs double equals bug/typo.
                #
                #     class BankAccount < Lanes::Model
                #
                #     end
                #
                #     bank=BankAccount.find(1)
                #     b.mark_as_super if bank.account_balance = 42 # a bit contrived, but you get the idea
                #     b.save # oops, what's our balance now?
                #
                #  Now let's try it again with locked_fields
                #
                #     class BankAccount < Lanes::Model
                #         attr_readonly :account_balance
                #     end
                #
                #     bank=BankAccount.find(1)
                #     b.mark_as_super if bank.account_balance = 42
                #     b.save # Still not ideal since we marked the bank as super, but at least our balance is ok
                #
                #  To update the balance we'd need to:
                #
                #     b.unlock_fields( :account_balance ) do
                #         b.account_balance += 33
                #     end
                #     b.save
                #
                #  This is still a bit contrived since we'd actually have
                #  an audit logger that would be involved and it'd be inside a transaction.

                def locked_fields( *flds )
                    include InstanceMethods
                    attr_readonly( *flds )
                end

                def has_locks( *locks )
                    locks.each do | lock |
                        define_method( "unlock_#{lock}" ) do | &block |
                            instance_variable_set "@_lock_#{lock}_unlocked", true
                            block.call
                            remove_instance_variable "@_lock_#{lock}_unlocked"
                        end
                        define_method( "is_#{lock}_unlocked?") do
                            instance_variable_defined? "@_lock_#{lock}_unlocked"
                        end
                    end
                end

            end

            module InstanceMethods
                # Unlock the field for updates inside the block
                # yields, then restores it.
                # Is class wide, meaning it Will temporarily open all instances of the class up for access in a threaded environment
                def unlock_fields( *flds, &block )
                    attr_syms = flds.map(&:to_s)

                    self.class.attr_readonly.subtract( attr_syms )

                    yield

                    attr_syms.each do | fld |
                        self.class.attr_readonly.add( fld )
                    end

                end
            end

        end
    end
end
