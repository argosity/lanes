module AppyApp

    # All models in AppyApp will inherit from
    # this common base class.
    class Model < Lanes::Model

        self.abstract_class = true

    end

    autoload :TestTest, "appy-app/models/test_test"
end
